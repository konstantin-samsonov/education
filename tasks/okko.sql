-- 1. Найти для каждого месяца по топ-5 тайтлов, имеющих больше всего: уникальных юзеров, стартов и времени смотрения
with
    raw_data as (
        select
            strftime('%Y-%m', play_dt) as year_month,
            user_id,
            title_id,
            play_dt,
            play_duration
        from okko_playback
    ),

    agg_data as (
        select
            year_month, title_id,
            count(distinct user_id) as uniq_users,
            row_number() over (partition by year_month order by count(distinct user_id) desc) as uniq_users_num,
            count(play_dt) as cnt_plays,
            row_number() over (partition by year_month order by count(play_dt) desc) as cnt_plays_num,
            sum(play_duration) as total_durations,
            row_number() over (partition by year_month order by sum(play_duration) desc) as total_durations_num
        from raw_data
        group by year_month, title_id
        order by year_month asc
    )

select year_month, title_id, uniq_users, cnt_plays, total_durations
from agg_data
where (uniq_users_num <= 5 or cnt_plays_num <= 5 or total_durations_num <= 5);


-- 2. Найти сколько юзеров смотрели тайтл c id 150 вчера, но не смотрели ничего как минимум 30 дней до этого
with
    target_users as (
        select
            distinct(user_id) as users
        from okko_playback
        where title_id == 150
    ),

    res as (
        select
            user_id
        from okko_playback
        where user_id in target_users
          and DATE('2022-08-14', '-30 days') < play_dt <= '2022-08-14'
        group by user_id
        having count(distinct (play_dt)) = 1)

select count(user_id) as cnt_users from res;


-- 3. Для каждого тайтла в помесячной динамике показать, на сколько процентов менялось количество уникальных юзеров
with
    monthly_users as (
        select
            strftime('%Y-%m', play_dt) as year_month,
            count(distinct user_id) as uniq_users,
            LAG(count(distinct user_id)) OVER (ORDER BY strftime('%Y-%m', play_dt)) as uniq_users_prev
        from okko_playback
        group by year_month
    )

select
    year_month, uniq_users,
    round((uniq_users - uniq_users_prev) * 100.0 / uniq_users_prev, 2) as month_diff_percent
from monthly_users;


-- 4. Сделать аналогичный топ как в 1 пункте, но отдельно по сезонам сериалов и фильмам с названиями.
-- Дополнительные данные в таблице с контентом (content).
-- Если я правильно понял, то говоря иначе – найти для каждого месяца по топ-5 сериалов/фильмов, имеющих больше всего:
-- уникальных юзеров, стартов и времени смотрения
with
    raw_data as (
        select
            strftime('%Y-%m', p.play_dt) as month,
            p.user_id, p.title_id, p.play_dt, p.play_duration,
            c.content_type, c.season_id, c.name
        from okko_playback as p
                 left join okko_content as c on p.title_id = c.title_id
        where content_type is not null
    ),

    agg_data as (
        select
            content_type, season_id, month, name,
            count(distinct user_id) as uniq_users,
            row_number() over (partition by month order by count(distinct user_id) desc) as uniq_users_num,
            count(play_dt) as cnt_plays,
            row_number() over (partition by month order by count(play_dt) desc) as cnt_plays_num,
            sum(play_duration) as total_durations,
            row_number() over (partition by month order by sum(play_duration) desc) as total_durations_num
        from raw_data
        group by content_type, season_id, month
    )


select month, content_type, season_id, name, uniq_users, cnt_plays, total_durations
from agg_data
where (uniq_users_num <= 5 or cnt_plays_num <= 5 or total_durations_num <= 5);


-- 5. Найти средний процент досматриваемости тайтлов по жанрам по месяцам
-- Очень не хотелось мудрить с SQLite3 и делать в нем массивы, поэтому сделал допущение,
-- что фильм с жанрами ['фантастика', 'приключения', 'семейное'] - это один "длинный" жанр.
-- А ['фантастика', 'боевик'] – это другой "длинный" жанр, и тд.
with
    agg_data as (
        select
            year_month, title_id, avg(percent_finished) as avg_percent_finished
        from (
                 select
                     strftime('%Y-%m', p.play_dt) as year_month,
                     p.title_id, p.play_duration, c.duration,
                     round(p.play_duration * 1.0 / c.duration * 100, 2) as percent_finished
                 from okko_playback as p
                          left join okko_content as c on p.title_id == c.title_id
                 where c.genres is not null
             )
        group by year_month, title_id
    )

select
    c.genres, t.year_month, c.title_id, c.name, t.avg_percent_finished
from agg_data as t
         left join okko_content as c on t.title_id == c.title_id
order by c.genres, t.year_month;


-- 6*. Сделать топ тайтлов по доле аудитории в первые 5 дней после релиза
-- План:
--  1. Так как даты релиза нет в таблице content, а считать релизом минимальную дату из playback не тру (как мне кажется),
--  то сгенерим новую таблицу с датами релизов.
--  2. Посчитать
--      - всех уников, которые смотрели каждый title_id в течение первых 5 дней после релиза
--      - всех уников, которые смотрели каждый title_id за все время после релиза
--      - долю первых от вторых
-- 3. Сортировать по доле и выбрать ТОП, допустим, 3;

with
    raw_data as (
        select
            p.title_id, r.release_date, p.user_id, p.play_dt
        from okko_playback as p
                 left join okko_release as r on p.title_id == r.title_id
        where r.release_date is not null
    ),

    first_watchers as (
        select
            title_id, count(distinct(user_id)) as uniq_users
        from raw_data
        where play_dt between release_date and date(release_date, '+5 days')
        group by title_id
    ),

    all_watchers as (
        select
            title_id, count(distinct(user_id)) as uniq_users
        from raw_data
        group by title_id
    ),

    results as (
        select
            a.title_id, a.uniq_users as all_uniq_users, f.uniq_users as first_uniq_users,
            round(f.uniq_users * 100.0 / a.uniq_users, 2) as share_users_percent
        from all_watchers as a
                 left join first_watchers as f on a.title_id = f.title_id
        where first_uniq_users is not null
    )

select title_id, all_uniq_users, first_uniq_users, share_users_percent from results order by share_users_percent desc
