--按天趋势表
SELECT   operate_date AS 日期,
         count(DISTINCT user_id) AS UV,
         sum(CASE WHEN behavior_type = 'pv' THEN 1 ELSE 0 END) AS PV,
         sum(CASE WHEN behavior_type = 'fav' THEN 1 ELSE 0 END) AS 收藏量,
         sum(CASE WHEN behavior_type = 'cart' THEN 1 ELSE 0 END) AS 加购量,
         sum(CASE WHEN behavior_type = 'buy' THEN 1 ELSE 0 END) AS 下单量
FROM     v_data_valid
GROUP BY operate_date
ORDER BY operate_date ASC;


--查询2017/11/29的操作小时
SELECT   DISTINCT operate_hour
FROM     v_data_valid
WHERE    operate_date = '2017/11/29'
ORDER BY operate_hour ASC;


--按小时分布
SELECT   operate_hour AS 小时,
         count(DISTINCT user_id) AS UV,
         sum(CASE WHEN behavior_type = 'pv' THEN 1 ELSE 0 END) AS PV,
         sum(CASE WHEN behavior_type = 'fav' THEN 1 ELSE 0 END) AS 收藏量,
         sum(CASE WHEN behavior_type = 'cart' THEN 1 ELSE 0 END) AS 加购量,
         sum(CASE WHEN behavior_type = 'buy' THEN 1 ELSE 0 END) AS 下单量,
         CONVERT (DECIMAL (5, 2), sum(CASE WHEN behavior_type = 'buy' THEN 1 ELSE 0 END) * 100.0 /sum(CASE WHEN behavior_type = 'pv' THEN 1 ELSE 0 END) ) as '下单/浏览(%)'
FROM     v_data_valid
GROUP BY operate_hour
ORDER BY operate_hour ASC;


--日环比
WITH     每日
AS       (SELECT   operate_date AS 日期,
                   count(DISTINCT user_id) AS UV,
                   sum(CASE WHEN behavior_type = 'pv' THEN 1 ELSE 0 END) AS PV,
                   sum(CASE WHEN behavior_type = 'buy' THEN 1 ELSE 0 END) AS 下单
          FROM     v_data_valid
          GROUP BY operate_date)
SELECT   日期,
         UV,
         PV,
         CONVERT (DECIMAL (5, 2), (PV - LAG(PV, 1) OVER (ORDER BY 日期)) * 100.0 / LAG(PV, 1) OVER (ORDER BY 日期)) AS PV环比,
         下单,
         CONVERT (DECIMAL (5, 2), (下单 - LAG(下单, 1) OVER (ORDER BY 日期)) * 100.0 / LAG(下单, 1) OVER (ORDER BY 日期)) AS 下单环比
FROM     每日
ORDER BY 日期;


--周末VS工作日
WITH     周中周末
AS       (SELECT   operate_date AS 日期,
                   count(DISTINCT user_id) AS UV,
                   sum(CASE WHEN behavior_type = 'pv' THEN 1 ELSE 0 END) AS PV,
                   sum(CASE WHEN behavior_type = 'buy' THEN 1 ELSE 0 END) AS 下单,
                   CASE WHEN operate_date IN ('2017/11/25','2017/11/26') THEN '周末' ELSE '工作日' END AS 类型
          FROM     v_data_valid
          GROUP BY operate_date)
SELECT
    类型,
    COUNT(*) AS 天数,
    CONVERT(DECIMAL(6,0), AVG(UV))    AS 日均UV,
    CONVERT(DECIMAL(6,0), AVG(PV))    AS 日均PV,
    CONVERT(DECIMAL(6,0), AVG(下单))   AS 日均下单,
    CONVERT(DECIMAL(5,2), AVG(下单) * 100.0 / AVG(PV)) AS '浏览->下单(%)'
FROM 周中周末
WHERE 日期 < '2017/11/29'   -- 去掉被截断的29号，不影响平均值
GROUP BY 类型;