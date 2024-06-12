import sqlite3
import random
import string
from datetime import datetime, timedelta

# Создаем соединение с базой данных SQLite
conn = sqlite3.connect('test_tasks.sqlite')
cursor = conn.cursor()

# Создаем таблицы
cursor.execute('''
CREATE TABLE IF NOT EXISTS loco_accounts (
    report_date TEXT,
    acc_num TEXT PRIMARY KEY,
    rest_rub REAL
)
''')

cursor.execute('''
CREATE TABLE IF NOT EXISTS loco_cards (
    hash_id TEXT PRIMARY KEY,
    tarif_id INTEGER,
    date_issued TEXT,
    date_activated TEXT,
    acc_num TEXT,
    client_id INTEGER
)
''')

cursor.execute('''
CREATE TABLE IF NOT EXISTS loco_card_status (
    hash_id TEXT,
    status TEXT,
    date_status TEXT,
    FOREIGN KEY(hash_id) REFERENCES loco_cards(hash_id)
)
''')

cursor.execute('''
CREATE TABLE IF NOT EXISTS loco_catalog (
    tarif_id INTEGER PRIMARY KEY,
    tarif_name TEXT
)
''')

cursor.execute('''
CREATE TABLE IF NOT EXISTS loco_tel_catalog (
    client_id INTEGER PRIMARY KEY,
    tel_num TEXT
)
''')

cursor.execute('''
CREATE TABLE IF NOT EXISTS loco_black_list (
    client_id INTEGER PRIMARY KEY
)
''')

cursor.execute('''
CREATE TABLE IF NOT EXISTS loco_comms (
    client_id INTEGER,
    comm_date TEXT,
    days_pass INTEGER
)
''')

# Функции для генерации данных
def random_date(start, end):
    return start + timedelta(
        seconds=random.randint(0, int((end - start).total_seconds())),
    )

def random_string(length=16):
    letters = string.ascii_letters + string.digits
    return ''.join(random.choice(letters) for _ in range(length))

# Данные для вставки
today = datetime.now()
start_date = today - timedelta(days=365)
end_date = today

accounts_data = [(random_date(start_date, end_date).strftime("%Y-%m-%d"), f'ACC{1000 + i}', round(random.uniform(1000, 100000), 2)) for i in range(20)]
cards_data = [(random_string(16), random.randint(1, 5), random_date(start_date, end_date).strftime("%Y-%m-%d"), random_date(start_date, end_date).strftime("%Y-%m-%d"), f'ACC{1000 + i}', 1000 + i) for i in range(20)]
card_status_data = [(cards_data[i][0], random.choice(['active', 'blocked', 'expired']), random_date(start_date, end_date).strftime("%Y-%m-%d")) for i in range(20)]
catalog_data = [(i, f'Tarif {i}') for i in range(1, 6)]
tel_catalog_data = [(1000 + i, f'+79{random.randint(100000000, 999999999)}') for i in range(20)]

# Уникальные client_id для black_list
black_list_client_ids = random.sample(range(1000, 1020), 5)
black_list_data = [(client_id,) for client_id in black_list_client_ids]

comms_data = [(1000 + i, random_date(start_date, end_date).strftime("%Y-%m-%d"), random.randint(0, 365)) for i in range(20)]

# Вставка данных
cursor.executemany('INSERT INTO loco_accounts (report_date, acc_num, rest_rub) VALUES (?, ?, ?)', accounts_data)
cursor.executemany('INSERT INTO loco_cards (hash_id, tarif_id, date_issued, date_activated, acc_num, client_id) VALUES (?, ?, ?, ?, ?, ?)', cards_data)
cursor.executemany('INSERT INTO loco_card_status (hash_id, status, date_status) VALUES (?, ?, ?)', card_status_data)
cursor.executemany('INSERT INTO loco_catalog (tarif_id, tarif_name) VALUES (?, ?)', catalog_data)
cursor.executemany('INSERT INTO loco_tel_catalog (client_id, tel_num) VALUES (?, ?)', tel_catalog_data)
cursor.executemany('INSERT INTO loco_black_list (client_id) VALUES (?)', black_list_data)
cursor.executemany('INSERT INTO loco_comms (client_id, comm_date, days_pass) VALUES (?, ?, ?)', comms_data)

# Сохранение изменений и закрытие соединения
conn.commit()
conn.close()
