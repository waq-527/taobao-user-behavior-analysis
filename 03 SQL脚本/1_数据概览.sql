--按日期查询用户数和操作数（原表）
SELECT   operate_date AS 日期,
         count(DISTINCT user_id) AS UV,
         sum(CASE WHEN behavior_type = 'pv' THEN 1 ELSE 0 END) AS PV,
         sum(CASE WHEN behavior_type = 'fav' THEN 1 ELSE 0 END) AS 收藏量,
         sum(CASE WHEN behavior_type = 'cart' THEN 1 ELSE 0 END) AS 加购量,
         sum(CASE WHEN behavior_type = 'buy' THEN 1 ELSE 0 END) AS 下单量
FROM     data
GROUP BY operate_date
ORDER BY operate_date ASC;


--按日期查询用户数和操作数（有效数据视图）
SELECT   operate_date AS 日期,
         count(DISTINCT user_id) AS UV,
         sum(CASE WHEN behavior_type = 'pv' THEN 1 ELSE 0 END) AS PV,
         sum(CASE WHEN behavior_type = 'fav' THEN 1 ELSE 0 END) AS 收藏量,
         sum(CASE WHEN behavior_type = 'cart' THEN 1 ELSE 0 END) AS 加购量,
         sum(CASE WHEN behavior_type = 'buy' THEN 1 ELSE 0 END) AS 下单量
FROM     v_data_valid
GROUP BY operate_date
ORDER BY operate_date ASC;


/*2017-09-11到2017-11-24数据量太小，故以下皆使用v_data_valid有效数据视图*/


--数据总数
SELECT count(*) AS 数据总数
FROM   v_data_valid;


--各操作总数
SELECT   behavior_cn,
         count(*) AS 行为数量
FROM     v_data_valid
GROUP BY behavior_cn;


--操作行为中英文对照
SELECT   behavior_type,
         behavior_cn
FROM     v_data_valid
GROUP BY behavior_type, behavior_cn;


--按用户查询操作次数
SELECT user_id,
                  sum(CASE WHEN behavior_type = 'pv' THEN 1 ELSE 0 END) AS PV,
                  sum(CASE WHEN behavior_type = 'fav' THEN 1 ELSE 0 END) AS 收藏量,
                  sum(CASE WHEN behavior_type = 'cart' THEN 1 ELSE 0 END) AS 加购量,
                  sum(CASE WHEN behavior_type = 'buy' THEN 1 ELSE 0 END) AS 下单量
FROM     v_data_valid
GROUP BY user_id;
