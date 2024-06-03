SELECT * FROM employees;

-- Рейтинг сотрудников по размеру заработной платы
select
    dense_rank() over (order by salary desc) as rank,
    name, department, salary
from employees
order by salary desc, id;


-- Рейтинг сотрудников по размеру заработной платы и по департаменту
select
    ntile(3) over (order by salary desc) as tile,
    name, department, salary
from employees
order by tile, department, salary desc, id;

-- Упорядочим сотрудников по возрастанию зарплаты и проверим, велик ли разрыв между соседями:
select
    id, name, department, salary,
    round(
        (salary - lag(salary, 1) over w) * 100.00 / lag(salary, 1) over w
    ) as diff
from employees
window w as (order by salary asc)
order by salary asc;

-- Посмотрим, как зарплата сотрудника соотносится с
-- минимальной и максимальной зарплатой в его департаменте:
select
    name, department, salary,
    first_value(salary) over w as low,
    last_value(salary) over w as high
from employees
window w as (
    partition by department
    order by salary
    rows between unbounded preceding and unbounded following
    )
order by department, salary, id asc


-- У каждого департамента есть фонд оплаты труда — денежная сумма,
-- которая ежемесячно уходит на выплату зарплат сотрудникам.
-- Посмотрим, какой процент от этого фонда составляет зарплата каждого сотрудника:
select
    name, department, salary,
    sum(salary) over w as fund,
    round(salary * 100.00 / sum(salary) over w, 2) as perc
from employees
window w as (partition by department)
order by department, salary, id;

-- Фильтрация. Так как окошки работают после where/group by,
-- то делать фильтр в самом запросе не правильно.
select
    name, department, salary,
    sum(salary) over w as fund
from employees
where city = 'Самара'
window w as (partition by department)
order by department, salary, id;

with
    tmp as (
        select
            name, city, salary,
            sum(salary) over w as fund
        from employees
        window w as (partition by department)
        order by department, salary, id
    )
select
    name, salary, fund
from tmp
where city = 'Самара';

-- Рассчитаем считаем скользящее среднее по всем месяцам:
select
    year, month, expense,
    round(avg(expense) over w) as roll_avg
from expenses
window w as (
    order by year, month
    rows between 1 preceding and 1 following
    )
order by year, month;

-- Рассчитаем доходы и расходы по месяцам нарастающим итогом (кумулятивно)
select
    year, month, income, expense,
    sum(income) over w as t_income,
    sum(expense) over w as t_expense,
    (sum(income) over w - sum(expense) over w) as t_profit
from expenses
window w as (
    order by year, month
    rows between unbounded preceding and current row
    )
order by year, month;

-- Для эксперимента. Возьмем запрос, который считает доходы нарастающим итогом.
-- И уберем из него определение фрейма.
-- В данном случае получим правильный результат как и в предыдущем примере.
-- Но это случайное совпадение. Фрейм не указа и есть order by в окне,
-- значит делаем фрейм по умолчанию – от первой до текущей записи.
select
    year, month, expense,
    sum(expense) over w as total
from expenses
window w as (
    order by year, month
--     rows between unbounded preceding and current row
    )
order by year, month;

-- Возьмем зарплату каждого сотрудника и определим,
-- какой процент людей получает столько же или меньше
select
    id, name, department, salary,
    cume_dist() over w
from employees
window w as (order by salary)
order by salary, id;

-- Какой процент людей получает строго меньше, чем конкретный сотрудник?
select
    name, salary,
    round(percent_rank() over w, 2) as perc
from employees
window w as (order by salary)
order by salary, id;

-- Считаем процентили
select
    round(avg(salary)) as average,
    percentile_disc(0.50) within group (order by salary) as median
from employees