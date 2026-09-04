--5天总转化率
WITH   用户行为
AS     (SELECT   user_id,
                 MAX(CASE WHEN behavior_type = 'pv' THEN 1 ELSE 0 END) AS 是否浏览,
                 MAX(CASE WHEN behavior_type IN ('fav', 'cart') THEN 1 ELSE 0 END) AS 是否收藏加购,
                 MAX(CASE WHEN behavior_type = 'buy' THEN 1 ELSE 0 END) AS 是否购买
        FROM     v_data_valid
        GROUP BY user_id),
       漏斗
AS     (SELECT SUM(是否浏览) AS 浏览用户,
               SUM(CASE WHEN 是否浏览 = 1
                             AND 是否收藏加购 = 1 THEN 1 ELSE 0 END) AS 收藏加购用户,
               SUM(CASE WHEN 是否浏览 = 1
                             AND 是否收藏加购 = 1
                             AND 是否购买 = 1 THEN 1 ELSE 0 END) AS 三级用户,
               SUM(CASE WHEN 是否浏览 = 1
                             AND 是否购买 = 1 THEN 1 ELSE 0 END) AS 购买用户
        FROM   用户行为)
SELECT 浏览用户,
       收藏加购用户,
       购买用户,
       三级用户,
       CONVERT (DECIMAL (5, 2), 收藏加购用户 * 100.0 / 浏览用户) AS '浏览->收藏加购(%)',
       CONVERT (DECIMAL (5, 2), 三级用户 * 100.0 / 收藏加购用户) AS '收藏加购->购买(%)',
       CONVERT (DECIMAL (5, 2), 购买用户 * 100.0 / 浏览用户) AS '浏览->购买(%)',
       CONVERT (DECIMAL (5, 2), 三级用户 * 100.0 / 浏览用户) AS '三级转化率(%)'
FROM   漏斗;


-- 事件级转化率
WITH   操作次数
AS     (SELECT SUM(CASE WHEN behavior_type = 'pv' THEN 1 ELSE 0 END) AS PV,
               SUM(CASE WHEN behavior_type IN ('fav', 'cart') THEN 1 ELSE 0 END) AS FC,
               SUM(CASE WHEN behavior_type = 'buy' THEN 1 ELSE 0 END) AS B,
               COUNT(DISTINCT CASE WHEN behavior_type = 'pv' THEN user_id END) AS PV用户,
               COUNT(DISTINCT CASE WHEN behavior_type = 'buy' THEN user_id END) AS B用户
        FROM   v_data_valid)
SELECT PV AS 浏览量,
       FC AS 收藏加购量,
       B AS 购买量,
       CONVERT (DECIMAL (5, 2), FC * 100.0 / PV) AS '收藏加购/浏览(%)',
       CONVERT (DECIMAL (5, 2), B * 100.0 / FC) AS '下单/收藏加购(%)',
       CONVERT (DECIMAL (5, 2), B * 100.0 / PV) AS '下单/浏览(%)',
       CONVERT (DECIMAL (5, 2), PV * 1.0 / PV用户) AS 人均浏览,
       CONVERT (DECIMAL (5, 2), B * 1.0 / B用户) AS 人均下单
FROM   操作次数;


--单日转化率
SELECT   operate_date,
         COUNT(DISTINCT CASE WHEN behavior_type = 'pv' THEN user_id END) AS 当天浏览用户,
         COUNT(DISTINCT CASE WHEN behavior_type = 'buy' THEN user_id END) AS 当天购买用户,
         CONVERT (DECIMAL (5, 2), COUNT(DISTINCT CASE WHEN behavior_type = 'buy' THEN user_id END) * 100.0 / COUNT(DISTINCT CASE WHEN behavior_type = 'pv' THEN user_id END)) AS 单日转化率
FROM     v_data_valid
GROUP BY operate_date
ORDER BY operate_date;


-- 类目级漏斗
WITH     类目用户行为
AS       (SELECT   category_id,
                   user_id,
                   MAX(CASE WHEN behavior_type = 'pv' THEN 1 ELSE 0 END) AS 是否浏览,
                   MAX(CASE WHEN behavior_type IN ('fav', 'cart') THEN 1 ELSE 0 END) AS 是否收藏加购,
                   MAX(CASE WHEN behavior_type = 'buy' THEN 1 ELSE 0 END) AS 是否购买
          FROM     v_data_valid
          GROUP BY category_id, user_id),
         类目汇总
AS       (SELECT   category_id,
                   SUM(CASE WHEN 是否浏览 = 1 THEN 1 ELSE 0 END) AS 浏览用户,
                   SUM(CASE WHEN 是否浏览 = 1
                                 AND 是否收藏加购 = 1 THEN 1 ELSE 0 END) AS 收藏加购用户,
                   SUM(CASE WHEN 是否浏览 = 1
                                 AND 是否收藏加购 = 1
                                 AND 是否购买 = 1 THEN 1 ELSE 0 END) AS 购买用户
          FROM     类目用户行为
          GROUP BY category_id)
SELECT   TOP 20 category_id AS 类目,
                浏览用户,
                收藏加购用户,
                购买用户,
                CONVERT (DECIMAL (5, 2), 收藏加购用户 * 100.0 / 浏览用户) AS '浏览->收藏加购(%)',
                CONVERT (DECIMAL (5, 2), 购买用户 * 100.0 / 收藏加购用户) AS '收藏加购->购买(%)',
                CONVERT (DECIMAL (5, 2), 购买用户 * 100.0 / 浏览用户) AS '浏览->购买(%)'
FROM     类目汇总
ORDER BY 浏览用户 DESC;