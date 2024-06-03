
-- -Таблица с событиями по смотрению контента (playback) вида
-- | user_id    | title_id  | play_dt     | play_duration |
-- |------------|-----------|-------------|---------------|
-- | 1          | 130       | 2022-08-10  | 120           |
-- | 1          | 150       | 2022-08-14  | 60            |
-- | 1          | 155       | 2022-08-14  | 90            |
-- | 2          | 121       | 2022-11-01  | 10            |
-- | 1          | 80        | 2023-01-10  | 1             |
-- | 1          | 176       | 2023-08-19  | 20            |
-- | 2          | 142       | 2023-06-17  | 80            |
-- | 3          | 200       | 2023-09-19  | 5             |

-- ------------------------
-- 1. Найти для каждого месяца по топ-5 тайтлов, имеющих больше всего уникальных юзеров, стартов и времени смотрения
with
    raw_data as (
        select
            toStartOfMonth(play_dt) as month,
            title_id,
            uniq(user_id) as cnt_users, row_number() over (partition by month order by cnt_users desc) as num_cnt_users
            count(play_dt) as cnt_plays, row_number() over (partition by month order by cnt_plays desc) as num_cnt_plays
            sum(play_duration) as sum_dur, row_number() over (partition by month order by cnt_plays desc) as num_sum_dur
        from playback
        group by month, title_id
    )

select
    month, title_id, cnt_users, cnt_plays, sum_dur
from raw_data
where num_cnt_users <= 5 or num_cnt_plays <=5 or num_sum_dur <=5
order by month




-- 2. Найти сколько юзеров смотрели тайтл c id 150 вчера, но не смотрели ничего как минимум 30 дней до этого
with
    target as (
        select
            distinct(user_id) as users
        from playback
        where taDate(play_dt) == yeastarday()
            and title_id == 150
    )

select
    user_id, uniq(play_dt) as cnt
from playback
where user_id in targets[users]
    and yeastarday() - 30 < taDate(play_dt) <= yeastarday()
group by user_id
having cnt = 1




-- 3. Для каждого тайтла в помесячной динамике показать,
--  на сколько процентов менялось количество уникальных юзеров
select
    title_id,
    toStartOfMonth(play_dt) as month,
    uniq(user_id) as cnt_users,
    lead(cnt_users, 1) over(partition by title_id order month asc) as cnt_lead,
    round(cnt_lead - cnt_users / cnt_users * 100, 2) as diff_percent
from playback
group by title_id, month
order by title_id, month




-- 4. Если у нас есть таблица с контентом (content) вида

-- | title_id  | season_id | name                       |duration |content_type | genres                                  |
-- |-----------|-----------|----------------------------|---------|-------------|-----------------------------------------|
-- | 130       | 130       | Матрица                    | 120     | movie       |['фантастика', 'боевик']                 |
-- | 150       | 110       | Чикатило сезон 1. Серия 1. | 55      | episode     |['криминал']                             |
-- | 155       | 111       | Чикатило сезон 2. Серия 5  | 55      | episode     |['криминал']                             |
-- | 110       | 110       | Чикатило сезон 1.          |         | season      |['криминал']                             |
-- | 80        | 80        | Гарри Поттер 1             | 140     | movie       |['фантастика', 'приключения', 'семейное']|

-- Сделать аналогичный топ как в 1 пункте, но отдельно по сезонам сериалов и фильмам с названиями

-- 5. Найти средний процент досматриваемости тайтлов по жанрам по месяцам


-- 6*. Сделать топ тайтлов по доле аудитории в первые 5 дней после релиза

