-- Вопрос 1: Какая единица контента наиболее востребована пользователями, обоснуйте.
SELECT ContentSysname,
       COUNT(MomentPassedUtc) AS cnt,
       ROUND(COUNT(MomentPassedUtc) * 1.0 / sum(Count(MomentPassedUtc)) OVER () * 100, 2) AS percent
FROM sessions
GROUP BY ContentSysname
ORDER BY cnt DESC;

-- Вопрос 2: Контент по какому запросу наиболее востребован пользователями, обоснуйте.
SELECT PsyRequestFilterSysname,
       COUNT(MomentPassedUtc) AS cnt,
       ROUND(COUNT(MomentPassedUtc) * 1.0 / SUM(COUNT(MomentPassedUtc)) OVER () * 100, 2) AS percent
FROM sessions
GROUP BY PsyRequestFilterSysname
ORDER BY cnt DESC;

-- Вопрос 3: Проверьте гипотезу о равномерности распределения запросов
SELECT PsyRequestFilterSysname,
       COUNT(MomentPassedUtc) AS observed_freq,
       (1.0 * SUM(COUNT(MomentPassedUtc)) OVER ()
            / SUM(COUNT(DISTINCT PsyRequestFilterSysname)) OVER ()
        ) as expected_freq
FROM sessions
GROUP BY PsyRequestFilterSysname
ORDER BY observed_freq DESC;

-- Вопрос 4
WITH
    daily_usage AS (
        SELECT
            UserGuid,
            DATE(MomentPassedUtc) AS date,
            MIN(MomentPassedUtc) AS first_view,
            MAX(MomentPassedUtc) AS last_view,
            TIMEDIFF(MAX(MomentPassedUtc), MIN(MomentPassedUtc)) AS day_view,
            ROUND((JULIANDAY(MAX(MomentPassedUtc)) - JULIANDAY(MIN(MomentPassedUtc))) * 86400) AS day_view_seconds
        FROM sessions
        GROUP BY UserGuid, date
        ORDER BY UserGuid, date
    ),

    users_avg AS (
        SELECT
            UserGuid, ROUND((sum(day_view_seconds) / count(date)) / 60)  AS avg_daily_view_minutes
        FROM daily_usage
        GROUP BY UserGuid
        ORDER BY avg_daily_view_minutes DESC
    ),

    total_avg AS (
        SELECT
            ROUND(sum(day_view_seconds) / count(UserGuid) / 60) AS avg_total_minutes
        FROM daily_usage
    )

SELECT
    u.UserGuid,
    u.avg_daily_view_minutes AS avg_daily_minutes_by_user,
    t.avg_total_minutes AS avg_daily_minutes_by_total,
    u.avg_daily_view_minutes - t.avg_total_minutes AS deviation
FROM users_avg as u
LEFT JOIN total_avg as t










