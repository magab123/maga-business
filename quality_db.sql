-- ============================================================
-- База данных: Система учета и анализа проблем качества по цехам
-- Версия: 1.0
-- ============================================================

-- Используем SQLite-совместимый синтаксис (легко адаптируется под PostgreSQL/MySQL)

PRAGMA foreign_keys = ON;

-- ============================================================
-- СПРАВОЧНИКИ (Раздел 11 ТЗ)
-- ============================================================

-- Роли пользователей (Раздел 12)
CREATE TABLE roles (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    code TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL
);

INSERT INTO roles (code, name) VALUES
    ('admin',          'Администратор системы'),
    ('quality_spec',   'Специалист службы качества цеха'),
    ('manager',        'Руководитель цеха / руководитель качества'),
    ('viewer',         'Пользователь с правом просмотра');

-- Укрупненная специализация цехов (Раздел 6)
CREATE TABLE workshop_groups (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    code TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL
);

INSERT INTO workshop_groups (code, name) VALUES
    ('metallurgy',   'Металлургические цеха'),
    ('forging',      'Кузнечные цеха'),
    ('thermal',      'Термообработка, гальваника, специальные покрытия'),
    ('machining',    'Механическая обработка и смежные операции'),
    ('pipebending',  'Трубогибочный цех'),
    ('rubber',       'Изготовление резинотехнических изделий'),
    ('engine_prod',  'Производственно-технологические центры изготовления вертолетных двигателей'),
    ('assembly',     'Сборочный цех'),
    ('testing',      'Испытательный цех'),
    ('shipping',     'Отгрузка');

-- Перечень цехов (Раздел 5)
CREATE TABLE workshops (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    code TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    group_id INTEGER NOT NULL REFERENCES workshop_groups(id),
    is_active INTEGER NOT NULL DEFAULT 1
);

INSERT INTO workshops (code, name, group_id) VALUES
    ('1б',     'Цех 1б',     (SELECT id FROM workshop_groups WHERE code='metallurgy')),
    ('ЦТК_АЛ','ЦТК АЛ',     (SELECT id FROM workshop_groups WHERE code='metallurgy')),
    ('ЦТК_ТЛ','ЦТК ТЛ',     (SELECT id FROM workshop_groups WHERE code='metallurgy')),
    ('2',      'Цех 2',      (SELECT id FROM workshop_groups WHERE code='forging')),
    ('2а',     'Цех 2а',     (SELECT id FROM workshop_groups WHERE code='forging')),
    ('4',      'Цех 4',      (SELECT id FROM workshop_groups WHERE code='thermal')),
    ('4а',     'Цех 4а',     (SELECT id FROM workshop_groups WHERE code='thermal')),
    ('9а',     'Цех 9а',     (SELECT id FROM workshop_groups WHERE code='thermal')),
    ('3а1',    'Цех 3а1',    (SELECT id FROM workshop_groups WHERE code='machining')),
    ('3а2',    'Цех 3а2',    (SELECT id FROM workshop_groups WHERE code='machining')),
    ('3б',     'Цех 3б',     (SELECT id FROM workshop_groups WHERE code='machining')),
    ('3в1',    'Цех 3в1',    (SELECT id FROM workshop_groups WHERE code='machining')),
    ('3в2',    'Цех 3в2',    (SELECT id FROM workshop_groups WHERE code='machining')),
    ('8',      'Цех 8',      (SELECT id FROM workshop_groups WHERE code='machining')),
    ('8б',     'Цех 8б',     (SELECT id FROM workshop_groups WHERE code='machining')),
    ('8в',     'Цех 8в',     (SELECT id FROM workshop_groups WHERE code='machining')),
    ('11',     'Цех 11',     (SELECT id FROM workshop_groups WHERE code='machining')),
    ('13',     'Цех 13',     (SELECT id FROM workshop_groups WHERE code='machining')),
    ('22',     'Цех 22',     (SELECT id FROM workshop_groups WHERE code='machining')),
    ('22а',    'Цех 22а',    (SELECT id FROM workshop_groups WHERE code='machining')),
    ('ЦСРТК',  'ЦСРТК',     (SELECT id FROM workshop_groups WHERE code='machining')),
    ('39',     'Цех 39',     (SELECT id FROM workshop_groups WHERE code='machining')),
    ('43',     'Цех 43',     (SELECT id FROM workshop_groups WHERE code='machining')),
    ('44',     'Цех 44',     (SELECT id FROM workshop_groups WHERE code='machining')),
    ('5',      'Цех 5',      (SELECT id FROM workshop_groups WHERE code='pipebending')),
    ('38',     'Цех 38',     (SELECT id FROM workshop_groups WHERE code='rubber')),
    ('ПТЦ_1', 'ПТЦ 1',      (SELECT id FROM workshop_groups WHERE code='engine_prod')),
    ('ПТЦ_3', 'ПТЦ 3',      (SELECT id FROM workshop_groups WHERE code='engine_prod')),
    ('6б',     'Цех 6б',     (SELECT id FROM workshop_groups WHERE code='assembly')),
    ('7б',     'Цех 7б',     (SELECT id FROM workshop_groups WHERE code='testing')),
    ('40',     'Цех 40',     (SELECT id FROM workshop_groups WHERE code='shipping'));

-- Типы проблем (Раздел 9)
CREATE TABLE problem_types (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    code TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    description TEXT,
    sort_order INTEGER NOT NULL DEFAULT 0
);

INSERT INTO problem_types (code, name, sort_order) VALUES
    ('defect',          'Производственный брак',                           1),
    ('doc_nonconf',     'Несоответствие в документации',                   2),
    ('tech_problem',    'Технологическая проблема',                        3),
    ('design_problem',  'Конструктивная проблема',                         4),
    ('material',        'Проблема материалов и комплектующих',             5),
    ('control_remark',  'Замечание контроля',                              6),
    ('test_problem',    'Проблема испытаний',                              7),
    ('operation',       'Проблема эксплуатации',                           8),
    ('recurring',       'Повторяющийся дефект',                            9),
    ('organizational',  'Организационная проблема, влияющая на качество', 10);

-- Этапы жизненного цикла (Раздел 7, 10)
CREATE TABLE lifecycle_stages (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    code TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    sort_order INTEGER NOT NULL DEFAULT 0
);

INSERT INTO lifecycle_stages (code, name, sort_order) VALUES
    ('production',  'Производство',  1),
    ('control',     'Контроль',      2),
    ('testing',     'Испытания',     3),
    ('assembly',    'Сборка',        4),
    ('shipping',    'Отгрузка',      5),
    ('operation',   'Эксплуатация',  6);

-- Источники выявления
CREATE TABLE detection_sources (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    code TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    sort_order INTEGER NOT NULL DEFAULT 0
);

INSERT INTO detection_sources (code, name, sort_order) VALUES
    ('self_control',     'Самоконтроль исполнителя',      1),
    ('otk',              'ОТК / контроль качества',       2),
    ('tech_control',     'Технологический контроль',      3),
    ('testing_lab',      'Испытательная лаборатория',     4),
    ('acceptance_test',  'Приемо-сдаточные испытания',    5),
    ('customer',         'Рекламация заказчика',          6),
    ('operation_fb',     'Обратная связь из эксплуатации', 7),
    ('audit',            'Аудит / проверка',              8),
    ('incoming_control', 'Входной контроль',              9),
    ('other',            'Прочее',                        10);

-- Критичность
CREATE TABLE severity_levels (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    code TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    description TEXT,
    sort_order INTEGER NOT NULL DEFAULT 0
);

INSERT INTO severity_levels (code, name, description, sort_order) VALUES
    ('critical',  'Критическая',    'Угроза безопасности, остановка производства',        1),
    ('major',     'Значительная',   'Существенное влияние на качество / функциональность', 2),
    ('minor',     'Незначительная', 'Незначительное отклонение, не влияющее на функцию',   3),
    ('info',      'Информационная', 'Замечание, не требующее немедленных действий',        4);

-- Статусы проблемы (Раздел 10)
CREATE TABLE problem_statuses (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    code TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    is_open INTEGER NOT NULL DEFAULT 1,
    sort_order INTEGER NOT NULL DEFAULT 0
);

INSERT INTO problem_statuses (code, name, is_open, sort_order) VALUES
    ('new',             'Новая',                          1, 1),
    ('in_analysis',     'На анализе причин',              1, 2),
    ('corrective',      'Корректирующие меры назначены',  1, 3),
    ('in_progress',     'В работе',                       1, 4),
    ('verification',    'На проверке эффективности',      1, 5),
    ('closed',          'Закрыта',                        0, 6),
    ('closed_ineffect', 'Закрыта — меры неэффективны',    0, 7);

-- ============================================================
-- ПОЛЬЗОВАТЕЛИ (Раздел 12)
-- ============================================================

CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    login TEXT NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    full_name TEXT NOT NULL,
    role_id INTEGER NOT NULL REFERENCES roles(id),
    workshop_id INTEGER REFERENCES workshops(id),  -- NULL для администратора
    is_active INTEGER NOT NULL DEFAULT 1,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- ============================================================
-- ОСНОВНАЯ ТАБЛИЦА: КАРТОЧКА ПРОБЛЕМЫ (Раздел 10)
-- ============================================================

CREATE TABLE problems (
    id INTEGER PRIMARY KEY AUTOINCREMENT,

    -- Регистрационные данные
    registration_number TEXT NOT NULL UNIQUE,      -- Номер записи (формат: ЦЕХ-ГГГГ-НННН)
    registration_date TEXT NOT NULL DEFAULT (date('now')), -- Дата регистрации

    -- Место возникновения
    workshop_id INTEGER NOT NULL REFERENCES workshops(id),              -- Цех
    section TEXT,                                                        -- Участок / подразделение

    -- Классификация
    problem_type_id INTEGER NOT NULL REFERENCES problem_types(id),      -- Тип проблемы
    lifecycle_stage_id INTEGER NOT NULL REFERENCES lifecycle_stages(id), -- Этап жизненного цикла
    detection_source_id INTEGER NOT NULL REFERENCES detection_sources(id), -- Источник выявления
    severity_id INTEGER NOT NULL REFERENCES severity_levels(id),        -- Критичность
    is_recurring INTEGER NOT NULL DEFAULT 0,                             -- Признак повторяемости
    is_operational INTEGER NOT NULL DEFAULT 0,                           -- Эксплуатационная проблема

    -- Объект
    object_type TEXT,                              -- Объект учета (изделие, узел, деталь и т.д.)
    product_name TEXT,                             -- Изделие / узел / деталь

    -- Описание проблемы
    title TEXT NOT NULL,                           -- Краткое наименование проблемы
    description TEXT,                              -- Подробное описание проблемы
    defect_manifestation TEXT,                     -- Проявление дефекта
    detection_location TEXT,                        -- Место выявления
    detection_conditions TEXT,                      -- Условия выявления
    detected_by TEXT,                              -- Кем выявлено

    -- Анализ причин
    root_cause TEXT,                               -- Причина возникновения

    -- Меры
    corrective_actions TEXT,                        -- Корректирующие меры
    preventive_actions TEXT,                        -- Предупреждающие меры

    -- Ответственность и сроки
    responsible_person TEXT,                        -- Ответственный
    due_date TEXT,                                 -- Срок исполнения

    -- Статус и результат
    status_id INTEGER NOT NULL REFERENCES problem_statuses(id) DEFAULT 1,
    resolution_result TEXT,                        -- Результат устранения
    effectiveness_result TEXT,                     -- Результат проверки эффективности

    -- Служебные поля
    created_by INTEGER REFERENCES users(id),
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_by INTEGER REFERENCES users(id),
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- ============================================================
-- СВЯЗАННЫЕ ЗАПИСИ (Раздел 10 — ссылка на аналогичные случаи)
-- ============================================================

CREATE TABLE related_problems (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    problem_id INTEGER NOT NULL REFERENCES problems(id) ON DELETE CASCADE,
    related_problem_id INTEGER NOT NULL REFERENCES problems(id) ON DELETE CASCADE,
    relation_type TEXT NOT NULL DEFAULT 'similar',  -- similar, duplicate, caused_by
    comment TEXT,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    UNIQUE(problem_id, related_problem_id)
);

-- ============================================================
-- ВЛОЖЕННЫЕ МАТЕРИАЛЫ (Раздел 10 — вложенные материалы)
-- ============================================================

CREATE TABLE attachments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    problem_id INTEGER NOT NULL REFERENCES problems(id) ON DELETE CASCADE,
    file_name TEXT NOT NULL,
    file_path TEXT NOT NULL,
    file_size INTEGER,
    mime_type TEXT,
    description TEXT,
    uploaded_by INTEGER REFERENCES users(id),
    uploaded_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- ============================================================
-- ИСТОРИЯ ИЗМЕНЕНИЙ (аудит)
-- ============================================================

CREATE TABLE problem_history (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    problem_id INTEGER NOT NULL REFERENCES problems(id) ON DELETE CASCADE,
    field_name TEXT NOT NULL,
    old_value TEXT,
    new_value TEXT,
    changed_by INTEGER REFERENCES users(id),
    changed_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- ============================================================
-- ИНДЕКСЫ для производительности и отчетности (Раздел 13)
-- ============================================================

CREATE INDEX idx_problems_workshop ON problems(workshop_id);
CREATE INDEX idx_problems_type ON problems(problem_type_id);
CREATE INDEX idx_problems_stage ON problems(lifecycle_stage_id);
CREATE INDEX idx_problems_severity ON problems(severity_id);
CREATE INDEX idx_problems_status ON problems(status_id);
CREATE INDEX idx_problems_reg_date ON problems(registration_date);
CREATE INDEX idx_problems_recurring ON problems(is_recurring);
CREATE INDEX idx_problems_operational ON problems(is_operational);
CREATE INDEX idx_problems_due_date ON problems(due_date);
CREATE INDEX idx_problems_workshop_date ON problems(workshop_id, registration_date);
CREATE INDEX idx_problems_workshop_status ON problems(workshop_id, status_id);
CREATE INDEX idx_problems_workshop_type ON problems(workshop_id, problem_type_id);

CREATE INDEX idx_related_problem ON related_problems(problem_id);
CREATE INDEX idx_related_related ON related_problems(related_problem_id);
CREATE INDEX idx_attachments_problem ON attachments(problem_id);
CREATE INDEX idx_history_problem ON problem_history(problem_id);

-- ============================================================
-- ПРЕДСТАВЛЕНИЯ (VIEW) для отчетности (Раздел 13)
-- ============================================================

-- Полная карточка проблемы с расшифрованными справочниками
CREATE VIEW v_problems_full AS
SELECT
    p.id,
    p.registration_number,
    p.registration_date,
    w.code AS workshop_code,
    w.name AS workshop_name,
    wg.name AS workshop_group,
    p.section,
    pt.name AS problem_type,
    ls.name AS lifecycle_stage,
    ds.name AS detection_source,
    sl.name AS severity,
    sl.code AS severity_code,
    ps.name AS status,
    ps.code AS status_code,
    ps.is_open,
    p.is_recurring,
    p.is_operational,
    p.object_type,
    p.product_name,
    p.title,
    p.description,
    p.defect_manifestation,
    p.detection_location,
    p.detection_conditions,
    p.detected_by,
    p.root_cause,
    p.corrective_actions,
    p.preventive_actions,
    p.responsible_person,
    p.due_date,
    p.resolution_result,
    p.effectiveness_result,
    p.created_at,
    p.updated_at
FROM problems p
JOIN workshops w ON p.workshop_id = w.id
JOIN workshop_groups wg ON w.group_id = wg.id
JOIN problem_types pt ON p.problem_type_id = pt.id
JOIN lifecycle_stages ls ON p.lifecycle_stage_id = ls.id
JOIN detection_sources ds ON p.detection_source_id = ds.id
JOIN severity_levels sl ON p.severity_id = sl.id
JOIN problem_statuses ps ON p.status_id = ps.id;

-- Открытые проблемы по цехам
CREATE VIEW v_open_problems AS
SELECT * FROM v_problems_full WHERE is_open = 1;

-- Эксплуатационные проблемы
CREATE VIEW v_operational_problems AS
SELECT * FROM v_problems_full WHERE is_operational = 1;

-- Повторяющиеся дефекты
CREATE VIEW v_recurring_problems AS
SELECT * FROM v_problems_full WHERE is_recurring = 1;

-- Статистика по цехам: количество проблем по типам
CREATE VIEW v_stats_workshop_by_type AS
SELECT
    w.code AS workshop_code,
    w.name AS workshop_name,
    pt.name AS problem_type,
    COUNT(*) AS problem_count
FROM problems p
JOIN workshops w ON p.workshop_id = w.id
JOIN problem_types pt ON p.problem_type_id = pt.id
GROUP BY w.id, pt.id;

-- Статистика по цехам: количество проблем по критичности
CREATE VIEW v_stats_workshop_by_severity AS
SELECT
    w.code AS workshop_code,
    w.name AS workshop_name,
    sl.name AS severity,
    COUNT(*) AS problem_count
FROM problems p
JOIN workshops w ON p.workshop_id = w.id
JOIN severity_levels sl ON p.severity_id = sl.id
GROUP BY w.id, sl.id;

-- Статистика по цехам: количество проблем по статусам
CREATE VIEW v_stats_workshop_by_status AS
SELECT
    w.code AS workshop_code,
    w.name AS workshop_name,
    ps.name AS status,
    ps.is_open,
    COUNT(*) AS problem_count
FROM problems p
JOIN workshops w ON p.workshop_id = w.id
JOIN problem_statuses ps ON p.status_id = ps.id
GROUP BY w.id, ps.id;

-- Топ причин (Раздел 13 — топ причин и повторяющихся дефектов)
CREATE VIEW v_top_causes AS
SELECT
    root_cause,
    COUNT(*) AS occurrence_count,
    GROUP_CONCAT(DISTINCT w.code) AS workshops
FROM problems p
JOIN workshops w ON p.workshop_id = w.id
WHERE p.root_cause IS NOT NULL AND p.root_cause != ''
GROUP BY p.root_cause
ORDER BY occurrence_count DESC;

-- Просроченные проблемы
CREATE VIEW v_overdue_problems AS
SELECT * FROM v_problems_full
WHERE is_open = 1
  AND due_date IS NOT NULL
  AND due_date < date('now');
