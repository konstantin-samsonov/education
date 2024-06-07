-- Есть две таблицы

CREATE TABLE country
(
    country_name varchar(32),
    city varchar(32)
);

CREATE TABLE sales
(
    date datetime '2022-10-01 12:30:00',
    city varchar(32),
    income decimal(18,2)
);

/*
Задача #1: Вывести список ТОП-5 городов в каждой стране по суммарной выручке
*/
with
    raw_data as (
        select
            c.country, c.city, s.total_income,
            row_numbew() over (partition by c.country order s.total_income desc) as num
        from country as c
                 left join (select
                                sity, sum(income) as total_income
                            from sales
                            group by city) as s on c.city == s.city
        order by c.country, c.city, num desc)

select
    country, city, total_income
from raw_data where num <= 5;

/*Сессионизация
Придумать правило создания уникального session_id (сессионизировать по user_id, окно 15 минут)

+-------------+---------------------+---------+------------------+
| event_uuid  |         ts          | user_id |     event_name   | session_id
+-------------+---------------------+---------+------------------+
| <some uuid> | 2019-01-15 12:30:02 | user_1  |                  |
| <some uuid> | 2019-03-01 13:12:32 | user_1  |                  |
| <some uuid> | 2019-03-01 13:15:05 | user_1  |                  |
| <some uuid> | ...                 | user_1  | ...              |
| <some uuid> | 2019-03-15 13:30:05 | user_1  | Consultation     |
| <some uuid> | 2019-03-03 13:30:32 | user_2  | Install          |
| <some uuid> | 2019-03-03 13:34:32 | user_2  | Some other event |
| <some uuid> | 2019-03-06 13:34:32 | user_2  | Consultation     |
| <some uuid> | ...                 | user_2  | ...              |
| <some uuid> | 2019-03-06 13:34:32 | user_2  | Consultation     |
| <some uuid> | ...                 | user_N  | ...              |

 */

with
    raw_data as (
        select
            user_id, ts, user_id, event_name,
            lag(ts, 1, 1) over (partition by user_id order by ts asc) as prev_ts,
            dateDiff('minuts', pref_ts, ts) as ts_diff,
            if(ts_diff <= 15, 1, 1) as is_new_session,

        from seesions
    )

select
    user_id, ts, user_id, event_name, is_new_session,
    hash(concat(user_id, sum(is_new_session) over (partition by user_id order by ts asc))) as seesion_id
from raw_data


-- Python
-- Что делает df[‘col’] = df[‘col’].apply(lambda x: 1 if x==’test’ else 0, axis=1)


/*
У вас есть набор данных о продажах в нескольких магазинах с информацией о клиентах, товарах и транзакциях.
Набор данных содержит следующие столбцы:
    event_dt - дата транзакции в формате 'ГГГГ-ММ-ДД',
    store - название магазина,
    item - название товара
    amount - количество проданных единиц товара.
    price - цена за единицу товара.
    customer - идентификатор клиента.

+------------+---------+--------+---------+---------+----------+
|  event_dt  |  store  |  item  |  amount |  price  | customer |
+------------+---------+--------+---------+---------+----------+
| 2019-01-15 | store_1 | item_1 |    1    | price_1 |  user_1  |
| 2019-03-01 | store_2 | item_1 |    1    | price_1 |  user_2  |
| 2019-03-15 | store_2 | item_2 |    2    | price_2 |  user_3  |
|     ...    |   ...   | item_3 |   ...   | price_3 |  user_3  |
| 2019-03-06 | store_3 | item_3 |   10    | price_3 |  user_4  |
| 2019-03-06 | store_4 | item_4 |    3    | price_4 |  user_5  |
| 2019-03-26 | store_5 | item_5 |    5    | price_5 |  user_5  |
+------------+----------+--------+---------+---------+---------+
*/

-- 1. Загрузить данные в pandas DataFrame из файла (например, CSV).

-- 2. Провести агрегированный анализ данных и вывести для каждого магазина:
--  общую сумму продаж,
--  среднюю цену товара,
--  количество уникальных товаров .
-- df['price_2'] = df.apply(lambda row: row['amount'] * row['price'], axis=1)
-- Или так
-- df['price_2'] = df['amount'] * df['prince']

-- df.groupby('store')['price_2'].agg('sum').reset_index()
-- df.groupby('store')['price'].agg('mean').reset_index()
-- df.groupby('store')['item'].agg('nuniq').reset_index()

-- 3. Рассчитать средний чек для каждого клиента и вывести топ-5 клиентов с наибольшим чеком.


-- AB
/*
Придумали АБ тест: на выдаче в тестовой группе половине врачей повесили шильдик "лучший врач",
чтобы сфокусировать пользователя на конкретных карточках.Конверсия в запись на выдаче к любому врачу упала.
Предположи, почему.
 */
