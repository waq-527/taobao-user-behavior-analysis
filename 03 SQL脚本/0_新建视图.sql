-- 视图1：有效数据（剔除 11/25 前的零散测试数据）
CREATE VIEW v_data_valid
AS
SELECT *
FROM   data
WHERE  operate_date >= CAST ('20171125' AS DATE);


-- 视图2：有效数据 + 完整时间列（供行为序列等需要排序的分析使用）
CREATE VIEW v_data_valid_time
AS
SELECT *,
       DATEADD(HOUR, operate_hour, CAST (operate_date AS DATETIME)) AS operate_time
FROM   v_data_valid;