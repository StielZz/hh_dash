



create table skills (
    id uuid primary key default uuid_generate_v1(),
    name text unique not null
);

create table business_roles (
    id uuid primary key default uuid_generate_v1(),
    name text unique not null
);

create table groups (
    id uuid primary key default uuid_generate_v1(),
    name text unique  not null
);

create table students (
    id uuid primary key default uuid_generate_v1(),
    full_name text unique not null,
    group_id uuid not null references groups(id) on delete cascade,
    business_role_id uuid not null references business_roles(id) on delete cascade
);

create table vacancies (
    id uuid primary key default uuid_generate_v1(),
    vacancy_id_origin integer unique not null, 
    vacancy_name text not null,
    salary_from numeric, 
    salary_to numeric,  
    salary_currency text,
    region text not null, 
    experience text  not null,  
    employment_type text  not null,
    schedule text not null, 
    employer text,
    published_at date not null,
    professional_roles text not null,
    archived boolean default false not null,
    updated_at timestamptz default current_timestamp
);


create table students_skills (
    student_id uuid references students(id) on delete cascade,
    skill_id uuid references skills(id) on delete cascade,
    primary key (student_id, skill_id)
);

create table vacancies_skills (
    vacancy_id uuid references vacancies(id) on delete cascade,
    skill_id uuid references skills(id) on delete cascade,
    primary key (vacancy_id, skill_id)
);













