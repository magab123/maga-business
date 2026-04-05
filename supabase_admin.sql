-- ============================================================
-- Обновление: логины вместо email + аккаунт admin
-- Выполнить в SQL Editor Supabase
-- ============================================================

-- 1. Добавляем поля login и email в user_profiles
ALTER TABLE user_profiles ADD COLUMN IF NOT EXISTS login TEXT;
ALTER TABLE user_profiles ADD COLUMN IF NOT EXISTS email TEXT;

-- 2. Обновляем триггер
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    INSERT INTO public.user_profiles (id, full_name, role_code, email, login)
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'full_name', 'Пользователь'),
        COALESCE(NEW.raw_user_meta_data->>'role_code', 'viewer'),
        NEW.email,
        REPLACE(NEW.email, '@quality.local', '')
    );
    RETURN NEW;
END;
$$;

-- 3. RLS — админ может всё с профилями
DROP POLICY IF EXISTS "Admin delete profiles" ON user_profiles;
CREATE POLICY "Admin delete profiles" ON user_profiles FOR DELETE TO authenticated
    USING (EXISTS (SELECT 1 FROM user_profiles WHERE id=auth.uid() AND role_code='admin'));

DROP POLICY IF EXISTS "Admin insert profiles" ON user_profiles;
CREATE POLICY "Admin insert profiles" ON user_profiles FOR INSERT TO authenticated
    WITH CHECK (true);

-- 4. Обновляем существующие профили
UPDATE user_profiles up
SET email = u.email,
    login = REPLACE(u.email, '@quality.local', '')
FROM auth.users u
WHERE up.id = u.id AND up.login IS NULL;

-- 5. Делаем первого пользователя админом
UPDATE user_profiles SET role_code = 'admin', login = 'admin'
WHERE id = (SELECT id FROM user_profiles ORDER BY created_at LIMIT 1);
