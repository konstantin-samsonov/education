/*
Используя таблицы vk_departments и vk_employees, напиши следующие SQL запросы:
    1. Для каждого сотрудника найти его департамент, включая тех, у кого департамента нет
    2. Найти наибольшую зарплату по департаментам и отсортировать департаменты по убыванию максимальной зарплаты
 */

-- Через массивы/json
with
    dict as (
        select
            e.manager_id, json_extract(json_group_array(e.dep_id), '$[0]') as dep_id,
            d.name as dep_name
        from vk_employees as e
        left join vk_departments as d on e.dep_id == d.id
        where manager_id is not null
        group by manager_id
    )
select
    e.id, e.name, e.dep_id, e.manager_id, e.salary,
    case
        when e.dep_id == '' then d2.dep_name
        else d1.dep_name
    end as result_dep_name
from vk_employees as e
left join dict as d1 on e.dep_id == d1.dep_id
left join dict as d2 on e.manager_id == d2.manager_id;

-- Через COALESCE
with
    dict as (
        select
            e.manager_id,
            coalesce(e.dep_id, m.dep_id) as dep_id,
            coalesce(d.name, md.name) as dep_name
        from vk_employees e
                 left join vk_departments d on e.dep_id = d.id
                 left join vk_employees m on e.manager_id = m.id
                 left join vk_departments md on m.dep_id = md.id
        where e.manager_id is not null
        group by e.manager_id
    ),

    data as (
        select
            e.id, e.name, e.dep_id, e.manager_id, e.salary,
            coalesce(d2.dep_name, d1.dep_name) as dep_name
        from vk_employees e
                 left join dict d1 on e.dep_id = d1.dep_id
                 left join dict d2 on e.manager_id = d2.manager_id
    )

select
    dep_name, dep_id, manager_id, name, salary,
    max(salary) over(partition by dep_name) as max_sal_dep
from data
order by max_sal_dep desc, salary desc;


/*
Используя таблицу vk_purchases
    1. Посчитай доход с женской аудитории (доход= сумма price*items)
    2. Сравни доход по группе мужчин и женщин
    3. Посчитай кол-во уникальных пользователей-мужчин, заказавших  более чем три айтема  (суммарно за все заказы).
*/

with
    data as (
        select
            user_id, substring(user_gender, 1, 1) as gender, items, price
        from vk_purchases
    ),

    female_income as (
        select sum(income) as fincome
        from (
            select
                items, price, items * price as income
            from data
            where gender == 'f'
        )
    ),

    f_vs_m_income as (
        select
            gender, max(income) as income
        from (
                 select
                     gender, items, price,
                     sum(items * price) over (partition by gender) as income
                 from data
                 order by gender
        )
        group by gender
    ),

    male as (
        select count(user_id) as active_male
        from (
            select
                user_id, sum(items) as cnt_items
            from data
            where gender == 'm'
            group by user_id
            having cnt_items > 3
        )
    )

-- select * from female_income
-- select * from f_vs_m_income
select * from male;


/*
Каждый пользователь имеет набор транзакций с определенным временем.
Используя таблицу vk_transactions, напиши НАИБОЛЕЕ ОПТИМАЛЬНЫЕ SQL запросы:
    1. Выведи для каждого пользователя первое наименование, которое он заказал (первое по времени транзакции)
    2. Посчитай сколько транзакций в среднем делает каждый пользователь в течении 72х часов с момента первой транзакции
*/

with
    first_item as (
    -- Наиболее оптимальный вариант – запихнуть все в ClickHouse и использовать имеющиеся там функции if, например.
        select *
        from (select user_id,
                     transaction_ts,
                     transaction_id,
                     item,
                     row_number() over (partition by user_id order by transaction_ts) as n
              from vk_transactions
              order by user_id, transaction_ts)
        where n == 1
    ),

    active as (
    -- В смоделированных мной данных нет окна в 72 часа, поэтому уменьшим его до 1 часа
        select
         user_id, count(distinct transaction_id) as cnt
        from (
            -- Считаем время до каждой транзакции от первой
            select
                user_id, transaction_ts, transaction_id, item,
                julianday(transaction_ts) - julianday(
                    first_value(transaction_ts) over (partition by user_id order by transaction_ts)) AS hours_since_first
            from vk_transactions
            order by user_id, transaction_ts)
        where hours_since_first <= 1.0
        group by user_id
    )

-- select * from first_item
select avg(cnt) as mean_transaction from active