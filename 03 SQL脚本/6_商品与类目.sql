--商品画像
SELECT COUNT(DISTINCT item_id) AS 商品数,
       COUNT(DISTINCT category_id) AS 类目数,
       CONVERT (DECIMAL (5, 2), COUNT(*) * 1.0 / COUNT(DISTINCT item_id)) AS 平均每商品行为数
FROM   v_data_valid;


--TOP10商品
WITH     商品统计
AS       (SELECT   item_id,
                   SUM(CASE WHEN behavior_type = 'pv' THEN 1 ELSE 0 END) AS PV,
                   SUM(CASE WHEN behavior_type = 'buy' THEN 1 ELSE 0 END) AS 下单
          FROM     v_data_valid
          GROUP BY item_id),
         商品排名
AS       (SELECT *,
                 ROW_NUMBER() OVER (ORDER BY 下单 DESC) AS 排名
          FROM   商品统计)
SELECT   排名,
         item_id,
         PV,
         下单
FROM     商品排名
WHERE    排名 <= 10
ORDER BY 排名;


--长尾集中度
WITH   商品统计
AS     (SELECT   item_id,
                 SUM(CASE WHEN behavior_type = 'pv' THEN 1 ELSE 0 END) AS PV,
                 SUM(CASE WHEN behavior_type = 'buy' THEN 1 ELSE 0 END) AS 下单
        FROM     v_data_valid
        GROUP BY item_id),
       商品排名
AS     (SELECT *,
               ROW_NUMBER() OVER (ORDER BY 下单 DESC) AS 排名
        FROM   商品统计)
SELECT SUM(下单) AS 总下单,
       SUM(CASE WHEN 排名 <= 10 THEN 下单 ELSE 0 END) AS TOP10下单,
       CONVERT (DECIMAL (5, 2), SUM(CASE WHEN 排名 <= 10 THEN 下单 ELSE 0 END) * 100.0 / SUM(下单)) AS TOP10下单占比
FROM   商品排名;


--长尾覆盖
WITH     商品下单
AS       (SELECT   item_id,
                   SUM(CASE WHEN behavior_type = 'buy' THEN 1 ELSE 0 END) AS 下单
          FROM     v_data_valid
          GROUP BY item_id),
         商品累计
AS       (SELECT item_id,
                 下单,
                 SUM(下单) OVER (ORDER BY 下单 DESC, item_id ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS 累计下单
          FROM   商品下单),
         总量
AS       (SELECT SUM(下单) AS 总下单,
                 COUNT(*) AS 商品数
          FROM   商品下单)
SELECT   t.总下单,
         SUM(CASE WHEN c.累计下单 < t.总下单 * 0.5 THEN 1 ELSE 0 END) + 1 AS '覆盖50%商品数',
         CONVERT (DECIMAL (5, 2), (SUM(CASE WHEN c.累计下单 < t.总下单 * 0.5 THEN 1 ELSE 0 END) + 1) * 100.0 / t.商品数) AS '覆盖50%商品占比',
         SUM(CASE WHEN c.累计下单 < t.总下单 * 0.8 THEN 1 ELSE 0 END) + 1 AS '覆盖80%商品数',
         CONVERT (DECIMAL (5, 2), (SUM(CASE WHEN c.累计下单 < t.总下单 * 0.8 THEN 1 ELSE 0 END) + 1) * 100.0 / t.商品数) AS '覆盖80%商品占比'
FROM     商品累计 AS c CROSS JOIN 总量 AS t
GROUP BY t.总下单, t.商品数;


--类目集中度
SELECT   TOP 10 category_id AS 类目,
                SUM(CASE WHEN behavior_type = 'pv' THEN 1 ELSE 0 END) AS PV,
                SUM(CASE WHEN behavior_type = 'buy' THEN 1 ELSE 0 END) AS 下单,
                CONVERT (DECIMAL (5, 2), SUM(CASE WHEN behavior_type = 'buy' THEN 1 ELSE 0 END) * 100.0 / (SELECT SUM(CASE WHEN behavior_type = 'buy' THEN 1 ELSE 0 END)
                                                                                                           FROM   v_data_valid)) AS 下单占比,
                CONVERT (DECIMAL (5, 2), SUM(CASE WHEN behavior_type = 'buy' THEN 1 ELSE 0 END) * 100.0 / SUM(CASE WHEN behavior_type = 'pv' THEN 1 ELSE 0 END)) AS 下单率
FROM     v_data_valid
GROUP BY category_id
ORDER BY 下单 DESC;