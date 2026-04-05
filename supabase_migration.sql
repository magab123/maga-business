-- ============================================================
-- Supabase Migration: Система учета проблем качества
-- Выполнить в SQL Editor проекта Supabase
-- ============================================================

-- ============================================================
-- СПРАВОЧНИКИ
-- ============================================================

CREATE TABLE roles (
    id SERIAL PRIMARY KEY,
    code TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL
);

INSERT INTO roles (code, name) VALUES
    ('admin',        'Администратор системы'),
    ('quality_spec', 'Специалист службы качества цеха'),
    ('manager',      'Руководитель цеха / руководитель качества'),
    ('viewer',       'Пользователь с правом просмотра');

CREATE TABLE workshop_groups (
    id SERIAL PRIMARY KEY,
    code TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL
);

INSERT INTO workshop_groups (code, name) VALUES
    ('metallurgy',  'Металлургические цеха'),
    ('forging',     'Кузнечные цеха'),
    ('thermal',     'Термообработка, гальваника, спец. покрытия'),
    ('machining',   'Механическая обработка и смежные операции'),
    ('pipebending', 'Трубогибочный цех'),
    ('rubber',      'Изготовление РТИ'),
    ('engine_prod', 'ПТЦ вертолетных двигателей'),
    ('assembly',    'Сборочный цех'),
    ('testing',     'Испытательный цех'),
    ('shipping',    'Отгрузка');

CREATE TABLE workshops (
    id SERIAL PRIMARY KEY,
    code TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    group_id INTEGER NOT NULL REFERENCES workshop_groups(id),
    is_active BOOLEAN NOT NULL DEFAULT true
);

INSERT INTO workshops (code, name, group_id) VALUES
    ('1б',     'Цех 1б',   (SELECT id FROM workshop_groups WHERE code='metallurgy')),
    ('ЦТК_АЛ','ЦТК АЛ',   (SELECT id FROM workshop_groups WHERE code='metallurgy')),
    ('ЦТК_ТЛ','ЦТК ТЛ',   (SELECT id FROM workshop_groups WHERE code='metallurgy')),
    ('2',      'Цех 2',    (SELECT id FROM workshop_groups WHERE code='forging')),
    ('2а',     'Цех 2а',   (SELECT id FROM workshop_groups WHERE code='forging')),
    ('4',      'Цех 4',    (SELECT id FROM workshop_groups WHERE code='thermal')),
    ('4а',     'Цех 4а',   (SELECT id FROM workshop_groups WHERE code='thermal')),
    ('9а',     'Цех 9а',   (SELECT id FROM workshop_groups WHERE code='thermal')),
    ('3а1',    'Цех 3а1',  (SELECT id FROM workshop_groups WHERE code='machining')),
    ('3а2',    'Цех 3а2',  (SELECT id FROM workshop_groups WHERE code='machining')),
    ('3б',     'Цех 3б',   (SELECT id FROM workshop_groups WHERE code='machining')),
    ('3в1',    'Цех 3в1',  (SELECT id FROM workshop_groups WHERE code='machining')),
    ('3в2',    'Цех 3в2',  (SELECT id FROM workshop_groups WHERE code='machining')),
    ('8',      'Цех 8',    (SELECT id FROM workshop_groups WHERE code='machining')),
    ('8б',     'Цех 8б',   (SELECT id FROM workshop_groups WHERE code='machining')),
    ('8в',     'Цех 8в',   (SELECT id FROM workshop_groups WHERE code='machining')),
    ('11',     'Цех 11',   (SELECT id FROM workshop_groups WHERE code='machining')),
    ('13',     'Цех 13',   (SELECT id FROM workshop_groups WHERE code='machining')),
    ('22',     'Цех 22',   (SELECT id FROM workshop_groups WHERE code='machining')),
    ('22а',    'Цех 22а',  (SELECT id FROM workshop_groups WHERE code='machining')),
    ('ЦСРТК',  'ЦСРТК',   (SELECT id FROM workshop_groups WHERE code='machining')),
    ('39',     'Цех 39',   (SELECT id FROM workshop_groups WHERE code='machining')),
    ('43',     'Цех 43',   (SELECT id FROM workshop_groups WHERE code='machining')),
    ('44',     'Цех 44',   (SELECT id FROM workshop_groups WHERE code='machining')),
    ('5',      'Цех 5',    (SELECT id FROM workshop_groups WHERE code='pipebending')),
    ('38',     'Цех 38',   (SELECT id FROM workshop_groups WHERE code='rubber')),
    ('ПТЦ_1', 'ПТЦ 1',    (SELECT id FROM workshop_groups WHERE code='engine_prod')),
    ('ПТЦ_3', 'ПТЦ 3',    (SELECT id FROM workshop_groups WHERE code='engine_prod')),
    ('6б',     'Цех 6б',   (SELECT id FROM workshop_groups WHERE code='assembly')),
    ('7б',     'Цех 7б',   (SELECT id FROM workshop_groups WHERE code='testing')),
    ('40',     'Цех 40',   (SELECT id FROM workshop_groups WHERE code='shipping'));

CREATE TABLE problem_types (
    id SERIAL PRIMARY KEY,
    code TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    sort_order INTEGER NOT NULL DEFAULT 0
);

INSERT INTO problem_types (code, name, sort_order) VALUES
    ('defect',         'Производственный брак',                          1),
    ('doc_nonconf',    'Несоответствие в документации',                  2),
    ('tech_problem',   'Технологическая проблема',                       3),
    ('design_problem', 'Конструктивная проблема',                        4),
    ('material',       'Проблема материалов и комплектующих',            5),
    ('control_remark', 'Замечание контроля',                             6),
    ('test_problem',   'Проблема испытаний',                             7),
    ('operation',      'Проблема эксплуатации',                          8),
    ('recurring',      'Повторяющийся дефект',                           9),
    ('organizational', 'Организационная проблема',                       10);

CREATE TABLE lifecycle_stages (
    id SERIAL PRIMARY KEY,
    code TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    sort_order INTEGER NOT NULL DEFAULT 0
);

INSERT INTO lifecycle_stages (code, name, sort_order) VALUES
    ('production',     'Производство',  1),
    ('control',        'Контроль',      2),
    ('testing',        'Испытания',     3),
    ('assembly',       'Сборка',        4),
    ('shipping',       'Отгрузка',      5),
    ('operation_stage','Эксплуатация',  6);

CREATE TABLE detection_sources (
    id SERIAL PRIMARY KEY,
    code TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    sort_order INTEGER NOT NULL DEFAULT 0
);

INSERT INTO detection_sources (code, name, sort_order) VALUES
    ('self_control',     'Самоконтроль исполнителя',       1),
    ('otk',              'ОТК / контроль качества',        2),
    ('tech_control',     'Технологический контроль',       3),
    ('testing_lab',      'Испытательная лаборатория',      4),
    ('acceptance_test',  'Приемо-сдаточные испытания',     5),
    ('customer',         'Рекламация заказчика',           6),
    ('operation_fb',     'Обратная связь из эксплуатации',  7),
    ('audit',            'Аудит / проверка',               8),
    ('incoming_control', 'Входной контроль',               9),
    ('other',            'Прочее',                         10);

CREATE TABLE severity_levels (
    id SERIAL PRIMARY KEY,
    code TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    sort_order INTEGER NOT NULL DEFAULT 0
);

INSERT INTO severity_levels (code, name, sort_order) VALUES
    ('critical', 'Критическая',    1),
    ('major',    'Значительная',   2),
    ('minor',    'Незначительная', 3),
    ('info',     'Информационная', 4);

CREATE TABLE problem_statuses (
    id SERIAL PRIMARY KEY,
    code TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    is_open BOOLEAN NOT NULL DEFAULT true,
    sort_order INTEGER NOT NULL DEFAULT 0
);

INSERT INTO problem_statuses (code, name, is_open, sort_order) VALUES
    ('new',             'Новая',                          true,  1),
    ('in_analysis',     'На анализе причин',              true,  2),
    ('corrective',      'Корректирующие меры назначены',  true,  3),
    ('in_progress',     'В работе',                       true,  4),
    ('verification',    'На проверке эффективности',      true,  5),
    ('closed',          'Закрыта',                        false, 6),
    ('closed_ineffect', 'Закрыта — меры неэффективны',    false, 7);

-- ============================================================
-- ПРОФИЛИ ПОЛЬЗОВАТЕЛЕЙ (связь с Supabase Auth)
-- ============================================================

CREATE TABLE user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name TEXT NOT NULL,
    role_code TEXT NOT NULL DEFAULT 'viewer' REFERENCES roles(code),
    workshop_id INTEGER REFERENCES workshops(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Триггер: автосоздание профиля при регистрации
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO user_profiles (id, full_name, role_code)
    VALUES (NEW.id, COALESCE(NEW.raw_user_meta_data->>'full_name', 'Новый пользователь'), COALESCE(NEW.raw_user_meta_data->>'role_code', 'viewer'));
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- ============================================================
-- ОСНОВНАЯ ТАБЛИЦА: ПРОБЛЕМЫ
-- ============================================================

CREATE TABLE problems (
    id SERIAL PRIMARY KEY,
    registration_number TEXT NOT NULL UNIQUE,
    registration_date DATE NOT NULL DEFAULT CURRENT_DATE,
    workshop_id INTEGER NOT NULL REFERENCES workshops(id),
    section TEXT,
    problem_type_id INTEGER NOT NULL REFERENCES problem_types(id),
    lifecycle_stage_id INTEGER NOT NULL REFERENCES lifecycle_stages(id),
    detection_source_id INTEGER NOT NULL REFERENCES detection_sources(id),
    severity_id INTEGER NOT NULL REFERENCES severity_levels(id),
    is_recurring BOOLEAN NOT NULL DEFAULT false,
    is_operational BOOLEAN NOT NULL DEFAULT false,
    object_type TEXT,
    product_name TEXT,
    title TEXT NOT NULL,
    description TEXT,
    defect_manifestation TEXT,
    detection_location TEXT,
    detection_conditions TEXT,
    detected_by TEXT,
    root_cause TEXT,
    corrective_actions TEXT,
    preventive_actions TEXT,
    responsible_person TEXT,
    due_date DATE,
    status_id INTEGER NOT NULL DEFAULT 1 REFERENCES problem_statuses(id),
    resolution_result TEXT,
    effectiveness_result TEXT,
    created_by UUID REFERENCES auth.users(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE related_problems (
    id SERIAL PRIMARY KEY,
    problem_id INTEGER NOT NULL REFERENCES problems(id) ON DELETE CASCADE,
    related_problem_id INTEGER NOT NULL REFERENCES problems(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE(problem_id, related_problem_id)
);

-- ============================================================
-- ИНДЕКСЫ
-- ============================================================

CREATE INDEX idx_problems_workshop ON problems(workshop_id);
CREATE INDEX idx_problems_type ON problems(problem_type_id);
CREATE INDEX idx_problems_severity ON problems(severity_id);
CREATE INDEX idx_problems_status ON problems(status_id);
CREATE INDEX idx_problems_reg_date ON problems(registration_date);
CREATE INDEX idx_problems_recurring ON problems(is_recurring);
CREATE INDEX idx_problems_operational ON problems(is_operational);

-- ============================================================
-- SEQUENCE для номеров записей по цехам
-- ============================================================

CREATE OR REPLACE FUNCTION generate_reg_number(ws_id INTEGER)
RETURNS TEXT AS $$
DECLARE
    ws_code TEXT;
    yr TEXT;
    cnt INTEGER;
BEGIN
    SELECT code INTO ws_code FROM workshops WHERE id = ws_id;
    yr := to_char(CURRENT_DATE, 'YYYY');
    SELECT COUNT(*) + 1 INTO cnt FROM problems
        WHERE workshop_id = ws_id AND registration_date >= (yr || '-01-01')::date;
    RETURN ws_code || '-' || yr || '-' || lpad(cnt::text, 4, '0');
END;
$$ LANGUAGE plpgsql;

-- ============================================================
-- RPC-ФУНКЦИИ ДЛЯ ОТЧЁТОВ
-- ============================================================

-- Дашборд: общая статистика
CREATE OR REPLACE FUNCTION get_dashboard_stats()
RETURNS JSON AS $$
DECLARE
    result JSON;
BEGIN
    SELECT json_build_object(
        'total', (SELECT COUNT(*) FROM problems),
        'open', (SELECT COUNT(*) FROM problems p JOIN problem_statuses s ON p.status_id=s.id WHERE s.is_open=true),
        'critical_open', (SELECT COUNT(*) FROM problems p JOIN severity_levels sl ON p.severity_id=sl.id JOIN problem_statuses s ON p.status_id=s.id WHERE sl.code='critical' AND s.is_open=true),
        'overdue', (SELECT COUNT(*) FROM problems p JOIN problem_statuses s ON p.status_id=s.id WHERE s.is_open=true AND p.due_date IS NOT NULL AND p.due_date < CURRENT_DATE)
    ) INTO result;
    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Статистика по типам
CREATE OR REPLACE FUNCTION get_stats_by_type(ws_id INTEGER DEFAULT NULL, d_from DATE DEFAULT NULL, d_to DATE DEFAULT NULL)
RETURNS JSON AS $$
BEGIN
    RETURN (
        SELECT json_agg(row_to_json(t)) FROM (
            SELECT pt.name as label, COUNT(*) as value
            FROM problems p JOIN problem_types pt ON p.problem_type_id=pt.id
            WHERE (ws_id IS NULL OR p.workshop_id=ws_id)
              AND (d_from IS NULL OR p.registration_date>=d_from)
              AND (d_to IS NULL OR p.registration_date<=d_to)
            GROUP BY pt.id, pt.name ORDER BY COUNT(*) DESC
        ) t
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Статистика по критичности
CREATE OR REPLACE FUNCTION get_stats_by_severity(ws_id INTEGER DEFAULT NULL, d_from DATE DEFAULT NULL, d_to DATE DEFAULT NULL)
RETURNS JSON AS $$
BEGIN
    RETURN (
        SELECT json_agg(row_to_json(t)) FROM (
            SELECT sl.name as label, sl.code, COUNT(*) as value
            FROM problems p JOIN severity_levels sl ON p.severity_id=sl.id
            WHERE (ws_id IS NULL OR p.workshop_id=ws_id)
              AND (d_from IS NULL OR p.registration_date>=d_from)
              AND (d_to IS NULL OR p.registration_date<=d_to)
            GROUP BY sl.id, sl.name, sl.code ORDER BY sl.sort_order
        ) t
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Статистика по статусам
CREATE OR REPLACE FUNCTION get_stats_by_status(ws_id INTEGER DEFAULT NULL, d_from DATE DEFAULT NULL, d_to DATE DEFAULT NULL)
RETURNS JSON AS $$
BEGIN
    RETURN (
        SELECT json_agg(row_to_json(t)) FROM (
            SELECT ps.name as label, ps.is_open, COUNT(*) as value
            FROM problems p JOIN problem_statuses ps ON p.status_id=ps.id
            WHERE (ws_id IS NULL OR p.workshop_id=ws_id)
              AND (d_from IS NULL OR p.registration_date>=d_from)
              AND (d_to IS NULL OR p.registration_date<=d_to)
            GROUP BY ps.id, ps.name, ps.is_open ORDER BY ps.sort_order
        ) t
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Статистика по этапам ЖЦ
CREATE OR REPLACE FUNCTION get_stats_by_stage(ws_id INTEGER DEFAULT NULL, d_from DATE DEFAULT NULL, d_to DATE DEFAULT NULL)
RETURNS JSON AS $$
BEGIN
    RETURN (
        SELECT json_agg(row_to_json(t)) FROM (
            SELECT ls.name as label, COUNT(*) as value
            FROM problems p JOIN lifecycle_stages ls ON p.lifecycle_stage_id=ls.id
            WHERE (ws_id IS NULL OR p.workshop_id=ws_id)
              AND (d_from IS NULL OR p.registration_date>=d_from)
              AND (d_to IS NULL OR p.registration_date<=d_to)
            GROUP BY ls.id, ls.name ORDER BY ls.sort_order
        ) t
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Топ причин
CREATE OR REPLACE FUNCTION get_top_causes(ws_id INTEGER DEFAULT NULL, d_from DATE DEFAULT NULL, d_to DATE DEFAULT NULL, lim INTEGER DEFAULT 10)
RETURNS JSON AS $$
BEGIN
    RETURN (
        SELECT json_agg(row_to_json(t)) FROM (
            SELECT root_cause as label, COUNT(*) as value
            FROM problems p
            WHERE root_cause IS NOT NULL AND root_cause != ''
              AND (ws_id IS NULL OR p.workshop_id=ws_id)
              AND (d_from IS NULL OR p.registration_date>=d_from)
              AND (d_to IS NULL OR p.registration_date<=d_to)
            GROUP BY root_cause ORDER BY COUNT(*) DESC LIMIT lim
        ) t
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Топ цехов
CREATE OR REPLACE FUNCTION get_top_workshops(lim INTEGER DEFAULT 5)
RETURNS JSON AS $$
BEGIN
    RETURN (
        SELECT json_agg(row_to_json(t)) FROM (
            SELECT w.name as label, COUNT(*) as value
            FROM problems p JOIN workshops w ON p.workshop_id=w.id
            GROUP BY w.id, w.name ORDER BY COUNT(*) DESC LIMIT lim
        ) t
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================
-- ROW LEVEL SECURITY
-- ============================================================

ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE problems ENABLE ROW LEVEL SECURITY;
ALTER TABLE related_problems ENABLE ROW LEVEL SECURITY;

-- Справочники: все могут читать
ALTER TABLE roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE workshop_groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE workshops ENABLE ROW LEVEL SECURITY;
ALTER TABLE problem_types ENABLE ROW LEVEL SECURITY;
ALTER TABLE lifecycle_stages ENABLE ROW LEVEL SECURITY;
ALTER TABLE detection_sources ENABLE ROW LEVEL SECURITY;
ALTER TABLE severity_levels ENABLE ROW LEVEL SECURITY;
ALTER TABLE problem_statuses ENABLE ROW LEVEL SECURITY;

-- Политики чтения справочников (для всех авторизованных)
CREATE POLICY "Authenticated read roles" ON roles FOR SELECT TO authenticated USING (true);
CREATE POLICY "Authenticated read workshop_groups" ON workshop_groups FOR SELECT TO authenticated USING (true);
CREATE POLICY "Authenticated read workshops" ON workshops FOR SELECT TO authenticated USING (true);
CREATE POLICY "Authenticated read problem_types" ON problem_types FOR SELECT TO authenticated USING (true);
CREATE POLICY "Authenticated read lifecycle_stages" ON lifecycle_stages FOR SELECT TO authenticated USING (true);
CREATE POLICY "Authenticated read detection_sources" ON detection_sources FOR SELECT TO authenticated USING (true);
CREATE POLICY "Authenticated read severity_levels" ON severity_levels FOR SELECT TO authenticated USING (true);
CREATE POLICY "Authenticated read problem_statuses" ON problem_statuses FOR SELECT TO authenticated USING (true);

-- Админ может редактировать справочники
CREATE POLICY "Admin manage workshops" ON workshops FOR ALL TO authenticated
    USING (EXISTS (SELECT 1 FROM user_profiles WHERE id=auth.uid() AND role_code='admin'));
CREATE POLICY "Admin manage problem_types" ON problem_types FOR ALL TO authenticated
    USING (EXISTS (SELECT 1 FROM user_profiles WHERE id=auth.uid() AND role_code='admin'));
CREATE POLICY "Admin manage lifecycle_stages" ON lifecycle_stages FOR ALL TO authenticated
    USING (EXISTS (SELECT 1 FROM user_profiles WHERE id=auth.uid() AND role_code='admin'));
CREATE POLICY "Admin manage detection_sources" ON detection_sources FOR ALL TO authenticated
    USING (EXISTS (SELECT 1 FROM user_profiles WHERE id=auth.uid() AND role_code='admin'));
CREATE POLICY "Admin manage severity_levels" ON severity_levels FOR ALL TO authenticated
    USING (EXISTS (SELECT 1 FROM user_profiles WHERE id=auth.uid() AND role_code='admin'));
CREATE POLICY "Admin manage problem_statuses" ON problem_statuses FOR ALL TO authenticated
    USING (EXISTS (SELECT 1 FROM user_profiles WHERE id=auth.uid() AND role_code='admin'));

-- User profiles
CREATE POLICY "Users read all profiles" ON user_profiles FOR SELECT TO authenticated USING (true);
CREATE POLICY "Users update own profile" ON user_profiles FOR UPDATE TO authenticated USING (id = auth.uid());
CREATE POLICY "Admin update any profile" ON user_profiles FOR UPDATE TO authenticated
    USING (EXISTS (SELECT 1 FROM user_profiles WHERE id=auth.uid() AND role_code='admin'));

-- Problems: все авторизованные читают
CREATE POLICY "Authenticated read problems" ON problems FOR SELECT TO authenticated USING (true);

-- Problems: создание — quality_spec, manager, admin
CREATE POLICY "Editors create problems" ON problems FOR INSERT TO authenticated
    WITH CHECK (EXISTS (SELECT 1 FROM user_profiles WHERE id=auth.uid() AND role_code IN ('admin','quality_spec','manager')));

-- Problems: обновление — quality_spec, manager, admin
CREATE POLICY "Editors update problems" ON problems FOR UPDATE TO authenticated
    USING (EXISTS (SELECT 1 FROM user_profiles WHERE id=auth.uid() AND role_code IN ('admin','quality_spec','manager')));

-- Problems: удаление — только admin
CREATE POLICY "Admin delete problems" ON problems FOR DELETE TO authenticated
    USING (EXISTS (SELECT 1 FROM user_profiles WHERE id=auth.uid() AND role_code='admin'));

-- Related problems
CREATE POLICY "Authenticated read related" ON related_problems FOR SELECT TO authenticated USING (true);
CREATE POLICY "Editors manage related" ON related_problems FOR ALL TO authenticated
    USING (EXISTS (SELECT 1 FROM user_profiles WHERE id=auth.uid() AND role_code IN ('admin','quality_spec','manager')));

-- ============================================================
-- REALTIME: включить для problems
-- ============================================================

ALTER PUBLICATION supabase_realtime ADD TABLE problems;
