from io import StringIO
import uuid
import time
import os

from sqlalchemy import create_engine
from dotenv import load_dotenv
import pandas as pd
import requests



load_dotenv()

DB_NAME = os.getenv("DB_NAME")
DB_USER = os.getenv("DB_USER")
DB_PASSWORD = os.getenv("DB_PASSWORD")
DB_HOST = os.getenv("DB_HOST")
DB_PORT = os.getenv("DB_PORT")
DB_SCHEMA = os.getenv("DB_SCHEMA")

# https://api.hh.ru/professional_roles
# https://api.hh.ru/areas 

professional_roles = {
  '96': 'Программист, разработчик',
  '160': 'DevOps-инженер',
  '156': 'BI-аналитик, аналитик данных',
  '150': 'Бизнес-аналитик',
  '164': 'Продуктовый аналитик',
  '104': 'Руководитель группы разработки',
  '157': 'Руководитель отдела аналитики',
  '107': 'Руководитель проектов',
  '112': 'Сетевой инженер',
  '113': 'Системный администратор',
  '124': 'Тестировщик',
  '125': 'Технический директор (CTO)',
  '126': 'Технический писатель',
  '121': 'Специалист технической поддержки'
}

headers = {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'}
url = 'https://api.hh.ru/vacancies'

vacancies_data = []
skills_data = []
vacancies_skills_data = []

added_vacancies = 0 
skipped_vacancies = 0 

db_url = f"postgresql+psycopg2://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
engine = create_engine(db_url)

existing_vacancies = pd.read_sql('SELECT vacancy_id_origin, id FROM vacancies', con=engine)
vacancy_id_map = dict(zip(existing_vacancies['vacancy_id_origin'], existing_vacancies['id']))

existing_skills = pd.read_sql('SELECT name, id FROM skills', con=engine)
skill_id_map = dict(zip(existing_skills['name'], existing_skills['id']))


def fetch_vacancies(url, params=None, delay=5) -> dict:
    while True:
        try:
            response = requests.get(url, params=params, headers=headers) if params else requests.get(url, headers=headers)
            response.raise_for_status()
            return response.json()
        except requests.exceptions.RequestException as e:
            print(f'Ошибка запроса: {e}. Повтор через {delay} секунд...')
            time.sleep(delay)


def df_to_database(engine, df, schema, table_name, chunksize, encoding='utf-8', index=False):
    output = StringIO()
    df.to_csv(output, sep=',', header=False, encoding=encoding, index=index, chunksize=chunksize)
    output.seek(0)

    connection = engine.raw_connection()
    cursor = connection.cursor()

    columns_in_csv = df.columns.tolist()
    columns_str = ', '.join([f'"{col}"' for col in columns_in_csv])
    schema_tablename = f'"{schema}"."{table_name}"'
    copy_query = f"COPY {schema_tablename} ({columns_str}) FROM STDIN WITH (FORMAT CSV)"

    try:
        cursor.copy_expert(copy_query, output)
        connection.commit()
    except Exception as e:
        print(f"Ошибка при вставке данных в таблицу {table_name}: {e}")
        connection.rollback()
    finally:
        cursor.close()


for professional_role in professional_roles.keys():
    for page in range(1):
        params = {
            'text': f'professional_role:{professional_role}',
            'area': '1948', # Приморский край # 1 Москва
            'page': page,
            'per_page': 100
        }
                
        vacancies = fetch_vacancies(url, params)
        vacancies = vacancies.get('items', [])

        for vacancy in vacancies:
            vacancy_id = vacancy['id']
            vacancy_uuid = str(uuid.uuid1())
                        
            if vacancy_id in vacancy_id_map:
                skipped_vacancies += 1
                print(f"Обработано {added_vacancies}. Пропущено {skipped_vacancies}. Вакансия {vacancy_id} уже существует.".ljust(100), end='\r')
                continue

            vacancy_id_map[vacancy_id] = vacancy_uuid
                    
            vacancy_data = fetch_vacancies(f'{url}/{vacancy_id}')

            if not all([
                vacancy_data.get('name'),
                vacancy_data.get('area'),
                vacancy_data.get('experience'),
                vacancy_data.get('schedule')
            ]): 
                skipped_vacancies += 1
                print(f"Обработано {added_vacancies}. Пропущено {skipped_vacancies}. Вакансия {vacancy_id} не содержит всех необходимых данных.".ljust(100), end='\r')
                continue

            skills = [skill.get('name', '') for skill in vacancy_data.get('key_skills', [])]

            if not skills:
                skipped_vacancies += 1 
                print(f"Обработано {added_vacancies}. Пропущено {skipped_vacancies}. Вакансия {vacancy_id} не содержит навыков.".ljust(100), end='\r')
                continue 

            salary = vacancy_data.get('salary', {})
            salary_from = salary.get('from') if salary else None
            salary_to = salary.get('to') if salary else None
            salary_currency = salary.get('currency') if salary else None    

            vacancy_name = vacancy_data['name']
            area = vacancy_data['area']['name']
            experience_name = vacancy_data['experience']['name']
            employment_type = vacancy_data['employment']['name']
            vacancy_schedule = vacancy_data['schedule']['name']
            vacancy_employer = vacancy_data['employer']['name']

            published_at = vacancy_data.get('published_at')[:10] 
            professional_roles = ', '.join([role.get('name', '') for role in vacancy_data.get('professional_roles', [])]) 

            archived = vacancy_data.get('archived') 

            vacancies_data.append([
                vacancy_uuid, vacancy_id, vacancy_name, salary_from, salary_to, salary_currency, 
                area, experience_name, employment_type, vacancy_schedule, vacancy_employer, 
                published_at, professional_roles, archived
            ])

            for skill in skills:
                if skill not in skill_id_map:
                    skill_uuid = str(uuid.uuid1())
                    skill_id_map[skill] = skill_uuid
                    skills_data.append([skill_uuid, skill]) 

                skill_id = skill_id_map[skill]
                vacancies_skills_data.append([vacancy_uuid, skill_id])

            added_vacancies += 1
            print(f"Обработано {added_vacancies}. Пропущено {skipped_vacancies}. Вакансия {vacancy_id} добавлена.".ljust(100), end='\r')


vacancies_df = pd.DataFrame(vacancies_data, columns=[
    'id', 'vacancy_id_origin', 'vacancy_name', 'salary_from', 'salary_to', 'salary_currency',
    'region', 'experience', 'employment_type', 'schedule', 'employer',
    'published_at', 'professional_roles', 'archived'
])
skills_df = pd.DataFrame(skills_data, columns=['id', 'name'])
vacancies_skills_df = pd.DataFrame(vacancies_skills_data, columns=['vacancy_id', 'skill_id'])

data = {
    'vacancies': (vacancies_df, 'vacancies'),
    'skills': (skills_df, 'skills'),
    'vacancies_skills': (vacancies_skills_df, 'vacancies_skills')
}

chunksize = 5000
for key, (df, table_name) in data.items():
    split_data = [df[i:i + chunksize] for i in range(0, df.shape[0], chunksize)]
    for chunk in split_data:
        df_to_database(engine, chunk, DB_SCHEMA, table_name, chunksize)

data_dir = "data"
if not os.path.exists(data_dir):
    os.makedirs(data_dir)

vacancies_df.to_csv(os.path.join(data_dir, 'vacancies.csv'), index=False, encoding='utf-8')
vacancies_skills_df.to_csv(os.path.join(data_dir, 'vacancies_skills.csv'), index=False, encoding='utf-8')
skills_df.to_csv(os.path.join(data_dir, 'skills.csv'), index=False, encoding='utf-8')

print(f'Завершено. Обработано {added_vacancies} вакансий. Пропущено {skipped_vacancies} вакансий.'.ljust(100))