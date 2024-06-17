/*
Есть табличка some_table вида some_id Integer, в которой хранится числовая последовательность от 1 до n с пропусками.
Нужно найти начало и конец пропусков данных, если его длина больше k

some_id
1,
2,
3,
9,
10,
11,
12,
20,
23

k = 2 =>
4, 8
13, 19
 */

-- 1, 0
-- 2, 1
-- 3, 1
-- 9, 6, 3+1, 9-1
-- 10,1
-- 11,1
-- 12,1
-- 20,8
-- 23,3

select
    some_id, first_val, last_val
from (
         select
             some_id,
             some_id - lag(some_id) over() as diff,
             if(diff != 1, lag(some_id) over() + 1) as first_val,
             if(diff != 1, some_id - 1) as last_val
         from some_table)
where diff >= 2