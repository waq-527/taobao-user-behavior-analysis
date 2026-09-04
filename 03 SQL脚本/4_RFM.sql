--R分布
WITH RFM AS (
    SELECT user_id,
           DATEDIFF(DAY, MAX(operate_date), '2017-11-29') AS R,
           COUNT(*) AS F,
           COUNT(DISTINCT item_id) AS M
    FROM v_data_valid
    WHERE behavior_type = 'buy'
    GROUP BY user_id
)
select R, count(*) as 人数,convert(decimal(5,2),count(*)*100.0/(select count(*) from RFM)) as '占比(%)'
from RFM
group by R
order by R;


--R，F平均值
WITH RFM AS (
    SELECT user_id,
           DATEDIFF(DAY, MAX(operate_date), '2017-11-29') AS R,
           COUNT(*) AS F,
           COUNT(DISTINCT item_id) AS M
    FROM v_data_valid
    WHERE behavior_type = 'buy'
    GROUP BY user_id
)
select CONVERT(DECIMAL(5,2), AVG(R*1.0)) AS R平均,CONVERT(DECIMAL(5,2), AVG(F*1.0)) AS F平均
from RFM;


--用户分层
WITH RFM AS (
    SELECT user_id,
           DATEDIFF(DAY, MAX(operate_date), '2017-11-29') AS R,
           COUNT(*) AS F,
           COUNT(DISTINCT item_id) AS M
    FROM v_data_valid
    WHERE behavior_type = 'buy'
    GROUP BY user_id
),
用户分层 AS (
    SELECT user_id,
           CASE WHEN R <= 1 AND F >= 2 THEN '重要价值'
                WHEN R > 1  AND F >= 2 THEN '重要保持'
                WHEN R <= 1 AND F < 2  THEN '潜力客户'
                ELSE '待激活' END AS 用户分层
    FROM RFM
)
SELECT
    b.用户分层,
    COUNT(*) AS 人数,
    CONVERT(DECIMAL(5,2), COUNT(*) * 100.0 / (SELECT COUNT(*) FROM 用户分层)) AS 占比,
    CONVERT(DECIMAL(5,2), AVG(a.M * 1.0)) AS 人均购买商品数
FROM RFM a
JOIN 用户分层 b ON a.user_id = b.user_id
GROUP BY b.用户分层
ORDER BY 人数 DESC;