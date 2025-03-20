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


headers = {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'}
url = 'https://api.hh.ru/vacancies'

vacancies_data = []
skills_data = []
vacancies_skills_data = []

updated_vacancies = 0 

db_url = f"postgresql+psycopg2://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
engine = create_engine(db_url)

existing_vacancies = pd.read_sql('SELECT vacancy_id_origin, id FROM vacancies', con=engine)

total_vacancies = len(existing_vacancies)

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


for _, row in existing_vacancies.iterrows():
    vacancy_uuid = row['id']
    vacancy_id = row['vacancy_id_origin']

    vacancy_data = fetch_vacancies(f'{url}/{vacancy_id}')

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

    archived = vacancy_data.get('archived', False)

    update_vacancy_query = """
        UPDATE vacancies
        SET 
            vacancy_name = %s,
            salary_from = %s,
            salary_to = %s,
            salary_currency = %s,
            region = %s,
            experience = %s,
            employment_type = %s,
            schedule = %s,
            employer = %s,
            published_at = %s,
            professional_roles = %s,
            archived = %s,
            updated_at = CURRENT_TIMESTAMP
        WHERE id = %s
    """

    vacancy_params = (
        vacancy_name, salary_from, salary_to, salary_currency,
        area, experience_name, employment_type, vacancy_schedule,
        vacancy_employer, published_at, professional_roles, archived,
        vacancy_uuid
    )

    skills = [skill.get('name', '') for skill in vacancy_data.get('key_skills', [])]

    delete_skills_query = "DELETE FROM vacancies_skills WHERE vacancy_id = %s"
    delete_skills_params = (vacancy_uuid,)

    insert_skills_query = "INSERT INTO skills (id, name) VALUES (%s, %s)"
    insert_vacancies_skills_query = "INSERT INTO vacancies_skills (vacancy_id, skill_id) VALUES (%s, %s) ON CONFLICT (vacancy_id, skill_id) DO NOTHING"

    connection = engine.raw_connection()
    cursor = connection.cursor()
    try:
        cursor.execute(update_vacancy_query, vacancy_params)

        cursor.execute(delete_skills_query, delete_skills_params)

        for skill in skills:
            if skill not in skill_id_map:
                skill_uuid = str(uuid.uuid4())
                skill_id_map[skill] = skill_uuid
                cursor.execute(insert_skills_query, (skill_uuid, skill))

            skill_id = skill_id_map[skill]
            cursor.execute(insert_vacancies_skills_query, (vacancy_uuid, skill_id))

        connection.commit()
        updated_vacancies += 1
        print(f"Всего вакансий {total_vacancies}. Обновлено {updated_vacancies}. Вакансия {vacancy_id} и связанные навыки обновлены.".ljust(100), end='\r')
    except Exception as e:
        print(f"Ошибка при обновлении вакансии {vacancy_id}: {e}")
        connection.rollback()
    finally:
        cursor.close()

print(f"\nЗавершено. Всего вакансий {total_vacancies}. Обновлено {updated_vacancies}.".ljust(100))