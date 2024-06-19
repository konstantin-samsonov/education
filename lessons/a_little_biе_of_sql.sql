/* Assume you have an events table on Facebook app analytics.
Write a query to calculate the click-through rate (CTR) for the app in 2022 and
round the results to 2 decimal places. */
WITH
    agg_data AS (
        SELECT
            app_id,
            COUNT(CASE WHEN event_type = 'click' THEN 1 END) AS clicks,
            COUNT(CASE WHEN event_type = 'impression' THEN 1 END) AS impressions
        FROM events
        WHERE DATE_PART('year', timestamp) = '2022'
        GROUP BY app_id
    )

SELECT
    app_id, ROUND(100.0 * clicks / impressions, 2) AS ctr
FROM agg_data;


/* Given a table of tweet data over a specified time period, calculate the 3-day rolling average of tweets for each user.
Output the user ID, tweet date, and rolling averages rounded to 2 decimal places. */
WITH
    agg_data AS (
    SELECT
        user_id,
        tweet_date,
        SUM(tweet_count) AS cnt_tweet,
        ROUND(AVG(SUM(tweet_count)) OVER (
            PARTITION BY user_id ORDER BY tweet_date ASC
                ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS rolling_avg
    FROM tweets
    GROUP BY user_id, tweet_date
    ORDER BY user_id, tweet_date
  )

SELECT * FROM agg_data;


/* Write a query that outputs the name of the credit card, and how many cards were issued in its launch month.
The launch month is the earliest record in the monthly_cards_issued table for a given card.
Order the results starting from the biggest issued amount. */
WITH
    agg_data as (
        SELECT
            card_name, issue_year, issue_month, SUM(issued_amount) AS issued_amount,
            ROW_NUMBER() OVER (PARTITION BY card_name ORDER BY issue_year, issue_month ASC) AS num

        FROM monthly_cards_issued
        GROUP BY card_name, issue_year, issue_month
        ORDER BY card_name, issue_year, issue_month
    )

SELECT
    card_name, issued_amount
FROM agg_data
WHERE num = 1
ORDER BY issued_amount DESC;


/* Assume you're given a table containing information on Facebook user actions.
Write a query to obtain number of monthly active users (MAUs) in July 2022,
including the month in numerical format "1, 2, 3". */
WITH
    month_birth as (
        SELECT
            user_id, MIN(DATE_PART('month', event_date)) AS month_birth
        FROM user_actions
        WHERE DATE_PART('year', event_date) = 2022
          AND event_type IN ('sign-in', 'like', 'comment')
        GROUP BY user_id
    ),

    agg_data as (
        SELECT
            u.user_id,
            DATE_PART('month', u.event_date) AS month,
            ARRAY_AGG(u.event_type) as arr_events
        FROM user_actions AS u
                 LEFT JOIN month_birth AS m ON u.user_id = m.user_id
        WHERE DATE_PART('year', u.event_date) = 2022
          AND u.event_type IN ('sign-in', 'like', 'comment')
        GROUP BY u.user_id, month
        ORDER BY u.user_id, month
    )


SELECT
    agg.month AS month,
    COUNT(agg.user_id) AS monthly_active_users
FROM agg_data AS agg
         LEFT JOIN month_birth AS birth ON agg.user_id = birth.user_id
WHERE agg.month = 7 AND (agg.month - birth.month_birth) >= 1
GROUP BY agg.month;