-- ============================================================
-- Создание аккаунта admin + добавление поля email в user_profiles
-- Выполнить в SQL Editor Supabase
-- ============================================================

-- 1. Добавляем поле email в user_profiles (для отображения в списке)
ALTER TABLE user_profiles ADD COLUMN IF NOT EXISTS email TEXT;

-- 2. Обновляем триггер чтобы сохранял email
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    INSERT INTO public.user_profiles (id, full_name, role_code, email)
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'full_name', 'Пользователь'),
        COALESCE(NEW.raw_user_meta_data->>'role_code', 'viewer'),
        NEW.email
    );
    RETURN NEW;
END;
$$;

-- 3. Обновляем RLS — админ может удалять профили
DROP POLICY IF EXISTS "Admin delete profiles" ON user_profiles;
CREATE POLICY "Admin delete profiles" ON user_profiles FOR DELETE TO authenticated
    USING (EXISTS (SELECT 1 FROM user_profiles WHERE id=auth.uid() AND role_code='admin'));

-- Админ может вставлять профили
DROP POLICY IF EXISTS "Admin insert profiles" ON user_profiles;
CREATE POLICY "Admin insert profiles" ON user_profiles FOR INSERT TO authenticated
    WITH CHECK (true);

-- 4. Обновляем email в существующих профилях
UPDATE user_profiles up SET email = u.email FROM auth.users u WHERE up.id = u.id AND up.email IS NULL;

-- 5. Обновляем роль существующего пользователя на admin (если нужно)
-- Найдём первого пользователя и сделаем его админом
UPDATE user_profiles SET role_code = 'admin' WHERE id = (SELECT id FROM user_profiles ORDER BY created_at LIMIT 1);
