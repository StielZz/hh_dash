



INSERT INTO 
	business_roles (name) 
VALUES 
    ('Дата инженеры'),
    ('Разработчики игр'),
    ('.NET разработчики');




INSERT INTO groups (name) 
VALUES 
    ('ГРП-ДИ-001'),
    ('ГРП-РИ-002'),
    ('ГРП-ДОТ-003');




INSERT INTO students (full_name, group_id, business_role_id) 
VALUES 
    ('Иван Петров', '3bca8ca8-0483-11f0-973c-9239e875c285', 'a9007db0-0482-11f0-973c-9239e875c285'),
    ('Алексей Смирнов', '3bca8ca8-0483-11f0-973c-9239e875c285', 'a9007db0-0482-11f0-973c-9239e875c285'),
    ('Дмитрий Сидоров', '3bca9fe0-0483-11f0-973c-9239e875c285', 'a9009994-0482-11f0-973c-9239e875c285'),
    ('Сергей Кузнецов', '3bcaa1c0-0483-11f0-973c-9239e875c285', 'a9009c1e-0482-11f0-973c-9239e875c285');




SELECT 
    s.id AS student_id,
    s.full_name AS student_name,
    g.name AS group_name,
    b.name AS business_role
FROM 
    students s
JOIN 
    groups g ON s.group_id = g.id
JOIN 
    business_roles b ON s.business_role_id = b.id;




-- Для Ивана Петрова
INSERT INTO students_skills (student_id, skill_id)
VALUES
    ('ac4e5acc-0483-11f0-973c-9239e875c285', (SELECT id FROM skills WHERE name = '1С: Предприятие 8')),
    ('ac4e5acc-0483-11f0-973c-9239e875c285', (SELECT id FROM skills WHERE name = '1С: Бухгалтерия')),
    ('ac4e5acc-0483-11f0-973c-9239e875c285', (SELECT id FROM skills WHERE name = 'Работа с базами данных')),
    ('ac4e5acc-0483-11f0-973c-9239e875c285', (SELECT id FROM skills WHERE name = 'MS SQL')),
    ('ac4e5acc-0483-11f0-973c-9239e875c285', (SELECT id FROM skills WHERE name = 'Аналитический склад ума')),
    ('ac4e5acc-0483-11f0-973c-9239e875c285', (SELECT id FROM skills WHERE name = 'SQL')),
    ('ac4e5acc-0483-11f0-973c-9239e875c285', (SELECT id FROM skills WHERE name = 'ETL'));

-- Для Алексея Смирнова
INSERT INTO students_skills (student_id, skill_id)
VALUES
    ('ac4e6c4c-0483-11f0-973c-9239e875c285', (SELECT id FROM skills WHERE name = '1С: Предприятие 8')),
    ('ac4e6c4c-0483-11f0-973c-9239e875c285', (SELECT id FROM skills WHERE name = '1С: Бухгалтерия')),
    ('ac4e6c4c-0483-11f0-973c-9239e875c285', (SELECT id FROM skills WHERE name = 'MS SQL')),
    ('ac4e6c4c-0483-11f0-973c-9239e875c285', (SELECT id FROM skills WHERE name = 'Python')),
    ('ac4e6c4c-0483-11f0-973c-9239e875c285', (SELECT id FROM skills WHERE name = 'Аналитический склад ума')),
    ('ac4e6c4c-0483-11f0-973c-9239e875c285', (SELECT id FROM skills WHERE name = 'SQL'));

-- Для Дмитрия Сидорова
INSERT INTO students_skills (student_id, skill_id)
VALUES
    ('ac4e6e86-0483-11f0-973c-9239e875c285', (SELECT id FROM skills WHERE name = 'C++')),
    ('ac4e6e86-0483-11f0-973c-9239e875c285', (SELECT id FROM skills WHERE name = 'Unreal Engine')),
    ('ac4e6e86-0483-11f0-973c-9239e875c285', (SELECT id FROM skills WHERE name = 'Git')),
    ('ac4e6e86-0483-11f0-973c-9239e875c285', (SELECT id FROM skills WHERE name = 'Python')),
    ('ac4e6e86-0483-11f0-973c-9239e875c285', (SELECT id FROM skills WHERE name = 'Работа с базами данных')),
    ('ac4e6e86-0483-11f0-973c-9239e875c285', (SELECT id FROM skills WHERE name = 'Системное тестирование'));

-- Для Сергея Кузнецова
INSERT INTO students_skills (student_id, skill_id)
VALUES
    ('ac4e6f76-0483-11f0-973c-9239e875c285', (SELECT id FROM skills WHERE name = 'C#')),
    ('ac4e6f76-0483-11f0-973c-9239e875c285', (SELECT id FROM skills WHERE name = 'SQL')),
    ('ac4e6f76-0483-11f0-973c-9239e875c285', (SELECT id FROM skills WHERE name = 'MS SQL Server')),
    ('ac4e6f76-0483-11f0-973c-9239e875c285', (SELECT id FROM skills WHERE name = 'Работа с базами данных')),
    ('ac4e6f76-0483-11f0-973c-9239e875c285', (SELECT id FROM skills WHERE name = 'Тестирование')),
    ('ac4e6f76-0483-11f0-973c-9239e875c285', (SELECT id FROM skills WHERE name = 'Git')),
    ('ac4e6f76-0483-11f0-973c-9239e875c285', (SELECT id FROM skills WHERE name = 'HTML')),
    ('ac4e6f76-0483-11f0-973c-9239e875c285', (SELECT id FROM skills WHERE name = 'CSS'));













INSERT INTO students (id, full_name, group_id, business_role_id) 
VALUES 
    ('0524324e-04d3-11f0-9c4c-9239e875c285', 'Артем Тарасовский', '3bca9fe0-0483-11f0-973c-9239e875c285', 'a9009994-0482-11f0-973c-9239e875c285');

    
INSERT INTO students_skills (student_id, skill_id)
VALUES
    ('0524324e-04d3-11f0-9c4c-9239e875c285', (SELECT id FROM skills WHERE name = 'C#')),
    ('0524324e-04d3-11f0-9c4c-9239e875c285', (SELECT id FROM skills WHERE name = 'Unreal Engine')),
    ('0524324e-04d3-11f0-9c4c-9239e875c285', (SELECT id FROM skills WHERE name = 'C++')),
    ('0524324e-04d3-11f0-9c4c-9239e875c285', (SELECT id FROM skills WHERE name = 'HTML')),
    ('0524324e-04d3-11f0-9c4c-9239e875c285', (SELECT id FROM skills WHERE name = 'Деловое общение')),
    ('0524324e-04d3-11f0-9c4c-9239e875c285', (SELECT id FROM skills WHERE name = 'Босс-Кадровик')),
    ('0524324e-04d3-11f0-9c4c-9239e875c285', (SELECT id FROM skills WHERE name = 'Blueprints')),
    ('0524324e-04d3-11f0-9c4c-9239e875c285', (SELECT id FROM skills WHERE name = 'Уверенный пользователь ПК')),
    ('0524324e-04d3-11f0-9c4c-9239e875c285', (SELECT id FROM skills WHERE name = 'Строительство')),
    ('0524324e-04d3-11f0-9c4c-9239e875c285', (SELECT id FROM skills WHERE name = 'Мотивация персонала')),
    ('0524324e-04d3-11f0-9c4c-9239e875c285', (SELECT id FROM skills WHERE name = 'Управление временем')),
    ('0524324e-04d3-11f0-9c4c-9239e875c285', (SELECT id FROM skills WHERE name = 'работа с детьми')),
    ('0524324e-04d3-11f0-9c4c-9239e875c285', (SELECT id FROM skills WHERE name = 'Настройка принтеров')),
    ('0524324e-04d3-11f0-9c4c-9239e875c285', (SELECT id FROM skills WHERE name = 'архивариус')),
    ('0524324e-04d3-11f0-9c4c-9239e875c285', (SELECT id FROM skills WHERE name = 'CSS'));




















