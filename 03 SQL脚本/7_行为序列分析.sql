--下单前一步
WITH 行为序列 AS (
    SELECT user_id,
           behavior_type,
           LAG(behavior_type, 1) OVER (PARTITION BY user_id ORDER BY operate_time) AS 前一步
    FROM v_data_valid_time
)
SELECT
    CASE WHEN 前一步 IS NULL THEN '无(首次行为就下单)'
         WHEN 前一步 = 'pv'   THEN '浏览'
         WHEN 前一步 = 'fav'  THEN '收藏'
         WHEN 前一步 = 'cart' THEN '加购'
         WHEN 前一步 = 'buy'  THEN '购买(连买)' END AS 下单前一步行为,
    COUNT(*) AS 次数,
    CONVERT(DECIMAL(5,2), COUNT(*) * 100.0 / SUM(COUNT(*)) OVER ()) AS 占比
FROM 行为序列
WHERE behavior_type = 'buy'
GROUP BY CASE WHEN 前一步 IS NULL THEN '无(首次行为就下单)'
              WHEN 前一步 = 'pv'   THEN '浏览'
              WHEN 前一步 = 'fav'  THEN '收藏'
              WHEN 前一步 = 'cart' THEN '加购'
              WHEN 前一步 = 'buy'  THEN '购买(连买)' END
ORDER BY 次数 DESC;


--浏览后一步
WITH 行为序列 AS (
    SELECT user_id,
           behavior_type,
           LEAD(behavior_type, 1) OVER (PARTITION BY user_id ORDER BY operate_time) AS 后一步
    FROM v_data_valid_time
)
SELECT
    CASE WHEN 后一步 IS NULL THEN '无(最后一次浏览)'
         WHEN 后一步 = 'pv'   THEN '继续浏览'
         WHEN 后一步 = 'fav'  THEN '收藏'
         WHEN 后一步 = 'cart' THEN '加购'
         WHEN 后一步 = 'buy'  THEN '直接下单' END AS 浏览后一步行为,
    COUNT(*) AS 次数,
    CONVERT(DECIMAL(5,2), COUNT(*) * 100.0 / SUM(COUNT(*)) OVER ()) AS 占比
FROM 行为序列
WHERE behavior_type = 'pv'
GROUP BY CASE WHEN 后一步 IS NULL THEN '无(最后一次浏览)'
              WHEN 后一步 = 'pv'   THEN '继续浏览'
              WHEN 后一步 = 'fav'  THEN '收藏'
              WHEN 后一步 = 'cart' THEN '加购'
              WHEN 后一步 = 'buy'  THEN '直接下单' END
ORDER BY 次数 DESC;