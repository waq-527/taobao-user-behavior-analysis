--复购率
WITH 用户购买 AS (
    SELECT user_id,
           COUNT(*) AS 购买次数,
           COUNT(DISTINCT operate_date) AS 购买天数
    FROM v_data_valid
    WHERE behavior_type = 'buy'
    GROUP BY user_id
)
SELECT
    COUNT(*) AS 购买用户,
    SUM(CASE WHEN 购买次数 >= 2 THEN 1 ELSE 0 END) AS 复购用户_次数口径,
    CONVERT(DECIMAL(5,2), SUM(CASE WHEN 购买次数 >= 2 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) AS 复购率_次数口径,
    SUM(CASE WHEN 购买天数 >= 2 THEN 1 ELSE 0 END) AS 复购用户_天数口径,
    CONVERT(DECIMAL(5,2), SUM(CASE WHEN 购买天数 >= 2 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) AS 复购率_天数口径
FROM 用户购买;


--留存率
WITH 首次活跃 AS (
    SELECT user_id, MIN(operate_date) AS 首次日
    FROM v_data_valid
    GROUP BY user_id
),
每日活跃 AS (
    SELECT DISTINCT operate_date AS 日期, user_id
    FROM v_data_valid
)
SELECT
    f.首次日,
    COUNT(DISTINCT f.user_id) AS 新增用户,
    COUNT(DISTINCT CASE WHEN a1.user_id IS NOT NULL THEN f.user_id END) AS D1,
    COUNT(DISTINCT CASE WHEN a2.user_id IS NOT NULL THEN f.user_id END) AS D2,
    COUNT(DISTINCT CASE WHEN a3.user_id IS NOT NULL THEN f.user_id END) AS D3,
    COUNT(DISTINCT CASE WHEN a4.user_id IS NOT NULL THEN f.user_id END) AS D4
FROM 首次活跃 f
LEFT JOIN 每日活跃 a1 ON f.user_id = a1.user_id AND a1.日期 = DATEADD(DAY, 1, f.首次日)
LEFT JOIN 每日活跃 a2 ON f.user_id = a2.user_id AND a2.日期 = DATEADD(DAY, 2, f.首次日)
LEFT JOIN 每日活跃 a3 ON f.user_id = a3.user_id AND a3.日期 = DATEADD(DAY, 3, f.首次日)
LEFT JOIN 每日活跃 a4 ON f.user_id = a4.user_id AND a4.日期 = DATEADD(DAY, 4, f.首次日)
GROUP BY f.首次日
ORDER BY f.首次日;