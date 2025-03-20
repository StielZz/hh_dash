


-- Бизнес роли ---------------------------------------------------------------------------------------------


--Количество вакансий
SELECT DISTINCT count(distinct v.*) 
FROM vacancies v
JOIN vacancies_skills vs ON v.id = vs.vacancy_id
JOIN skills s ON vs.skill_id = s.id
JOIN students_skills ss ON s.id = ss.skill_id
JOIN students st ON ss.student_id = st.id
JOIN business_roles br ON st.business_role_id = br.id
WHERE br.name = '${business_roles}';


--Процент от общего кол-ва вакансий
SELECT 
    (COUNT(distinct v.id) * 100.0) / NULLIF((SELECT COUNT(*) FROM vacancies), 0) AS percentage
FROM vacancies v
JOIN vacancies_skills vs ON v.id = vs.vacancy_id
JOIN skills s ON vs.skill_id = s.id
JOIN students_skills ss ON s.id = ss.skill_id
JOIN students st ON ss.student_id = st.id
JOIN business_roles br ON st.business_role_id = br.id
WHERE br.name = '${business_roles}';


--Топ 5 навыков
SELECT s.name AS skill, COUNT(DISTINCT v.id) AS demand_count
FROM vacancies_skills vs
JOIN skills s ON vs.skill_id = s.id
JOIN vacancies v ON vs.vacancy_id = v.id
JOIN students_skills ss ON s.id = ss.skill_id
JOIN students st ON ss.student_id = st.id
JOIN business_roles br ON st.business_role_id = br.id
WHERE br.name = '${business_roles}'
GROUP BY s.name
ORDER BY demand_count DESC
LIMIT 5;


--Средняя зарплата
SELECT AVG(DISTINCT v.salary_from) AS avg_salary
FROM vacancies v
JOIN vacancies_skills vs ON v.id = vs.vacancy_id
JOIN skills s ON vs.skill_id = s.id
JOIN students_skills ss ON s.id = ss.skill_id
JOIN students st ON ss.student_id = st.id
JOIN business_roles br ON st.business_role_id = br.id
WHERE br.name = '${business_roles}' 
AND v.salary_from IS NOT NULL;


--Медианная зарплата
SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY salary_from) AS median_salary
FROM (
    SELECT DISTINCT v.salary_from
    FROM vacancies v
    JOIN vacancies_skills vs ON v.id = vs.vacancy_id
    JOIN skills s ON vs.skill_id = s.id
    JOIN students_skills ss ON s.id = ss.skill_id
    JOIN students st ON ss.student_id = st.id
    JOIN business_roles br ON st.business_role_id = br.id
    WHERE br.name = '${business_roles}'
    AND v.salary_from IS NOT NULL
) AS subquery;


--Вакансии 
SELECT DISTINCT 
    v.vacancy_id_origin,
    v.vacancy_name,
    CASE 
        WHEN v.salary_from IS NOT NULL THEN CONCAT(v.salary_from, ' ', v.salary_currency)
        WHEN v.salary_to IS NOT NULL THEN CONCAT(v.salary_to, ' ', v.salary_currency)
        ELSE 'Не указано'
    END AS salary_with_currency,
    v.region,
    v.experience,
    v.employment_type,
    v.schedule,
    v.employer
FROM vacancies v
JOIN vacancies_skills vs ON v.id = vs.vacancy_id
JOIN skills s ON vs.skill_id = s.id
JOIN students_skills ss ON s.id = ss.skill_id
JOIN students st ON ss.student_id = st.id
JOIN business_roles br ON st.business_role_id = br.id
WHERE br.name = '${business_roles}';


-- Студенты ------------------------------------------------------------------------------------------------


--Количество вакансий
SELECT DISTINCT count(distinct v.*) 
FROM vacancies v
JOIN vacancies_skills vs ON v.id = vs.vacancy_id
JOIN skills s ON vs.skill_id = s.id
JOIN students_skills ss ON s.id = ss.skill_id
JOIN students st ON ss.student_id = st.id
JOIN business_roles br ON st.business_role_id = br.id
WHERE st.full_name = '${student}';


--Медианная зарплата
SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY salary_from) AS median_salary
FROM (
    SELECT DISTINCT v.salary_from
    FROM vacancies v
    JOIN vacancies_skills vs ON v.id = vs.vacancy_id
    JOIN skills s ON vs.skill_id = s.id
    JOIN students_skills ss ON s.id = ss.skill_id
    JOIN students st ON ss.student_id = st.id
    JOIN business_roles br ON st.business_role_id = br.id
    WHERE st.full_name = '${student}'
    AND v.salary_from IS NOT NULL
) AS subquery;


--Средняя зарплата
SELECT AVG(DISTINCT v.salary_from) AS avg_salary
FROM vacancies v
JOIN vacancies_skills vs ON v.id = vs.vacancy_id
JOIN skills s ON vs.skill_id = s.id
JOIN students_skills ss ON s.id = ss.skill_id
JOIN students st ON ss.student_id = st.id
JOIN business_roles br ON st.business_role_id = br.id
WHERE st.full_name = '${student}'
AND v.salary_from IS NOT NULL;


--Топ 5 навыков
SELECT 
    sk.name AS skill_name,
    COUNT(vs.vacancy_id) AS matching_vacancies_count
FROM 
    students_skills ss
JOIN 
    skills sk ON ss.skill_id = sk.id
JOIN 
    vacancies_skills vs ON sk.id = vs.skill_id
JOIN 
    vacancies v ON vs.vacancy_id = v.id
JOIN 
    students s ON ss.student_id = s.id
WHERE 
    s.full_name = '${student}'
GROUP BY 
    sk.name
ORDER BY 
    matching_vacancies_count DESC
LIMIT 5;


--Вакансии
SELECT 
    v.vacancy_id_origin,
    v.vacancy_name,
    CASE 
        WHEN v.salary_from IS NOT NULL THEN CONCAT(v.salary_from, ' ', v.salary_currency)
        WHEN v.salary_to IS NOT NULL THEN CONCAT(v.salary_to, ' ', v.salary_currency)
        ELSE 'Не указано'
    END AS salary_with_currency,
    v.region,
    v.experience,
    v.employment_type,
    v.schedule,
    v.employer,
    COUNT(vs.skill_id) AS matching_skills_count
FROM 
    vacancies v
JOIN 
    vacancies_skills vs ON v.id = vs.vacancy_id
JOIN 
    skills sk ON vs.skill_id = sk.id
JOIN 
    students_skills ss ON sk.id = ss.skill_id
JOIN 
    students s ON ss.student_id = s.id
WHERE 
    s.full_name  = '${student}'
GROUP BY 
    v.id
ORDER BY 
    matching_skills_count DESC; 




















