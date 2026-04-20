
-- ==================================================
-- 无人驾驶汽车用户调研分析 - SQL 版本
-- 说明：以下SQL假设您已将Excel数据导入到名为 `autonomous_car_survey` 的数据表中
-- 您可以直接在MySQL、PostgreSQL等关系型数据库中执行以下查询
-- ==================================================

-- ------------------------------
-- 1. 创建表结构 (如果尚未创建)
-- ------------------------------
/*
CREATE TABLE autonomous_car_survey (
    IP VARCHAR(50),
    性别 VARCHAR(10),
    年龄段 VARCHAR(20),
    学历 VARCHAR(20),
    职业 VARCHAR(20),
    收入 VARCHAR(20),
    了解程度得分 INT,
    驾驶水平 VARCHAR(20),
    购无人驾驶车意愿 VARCHAR(20),
    购车理由_减少疲惫感 VARCHAR(20),
    购车理由_减少事故 VARCHAR(20),
    购车理由_提高效率 VARCHAR(20),
    购车理由_节能环保 VARCHAR(20),
    购车理由_技术发达 VARCHAR(20),
    不购车理由_安全问题 VARCHAR(20),
    不购车理由_技术不成熟 VARCHAR(20),
    不购车理由_质量不行 VARCHAR(20),
    不购车理由_法规不完善 VARCHAR(20),
    不购车理由_喜欢手动 VARCHAR(20),
    是否尝试过 VARCHAR(10),
    满意度 VARCHAR(20),
    需加强方面 TEXT,
    场景想象 TEXT
);
*/

-- 注意：由于原Excel列名有中文和特殊符号，导入数据库时建议做一下映射，如上所示。
-- 以下查询基于上述映射后的字段名。

-- ------------------------------
-- 2. 样本用户画像分析
-- ------------------------------

-- 2.1 年龄段分布
SELECT 
    年龄段, 
    COUNT(*) as 人数,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM autonomous_car_survey), 1) as 占比
FROM autonomous_car_survey
GROUP BY 年龄段
ORDER BY 
    CASE 年龄段 
        WHEN '18岁以下' THEN 1 
        WHEN '18～24' THEN 2 
        WHEN '25～35' THEN 3 
        WHEN '36～54' THEN 4 
        WHEN '54岁及以上' THEN 5 
    END;

-- 2.2 学历分布
SELECT 
    学历, 
    COUNT(*) as 人数,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM autonomous_car_survey), 1) as 占比
FROM autonomous_car_survey
GROUP BY 学历
ORDER BY 
    CASE 学历 
        WHEN '高中及以下' THEN 1 
        WHEN '大专' THEN 2 
        WHEN '本科' THEN 3 
        WHEN '研究生及以上' THEN 4 
    END;

-- 2.3 职业分布
SELECT 
    职业, 
    COUNT(*) as 人数,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM autonomous_car_survey), 1) as 占比
FROM autonomous_car_survey
GROUP BY 职业
ORDER BY 人数 DESC;

-- ------------------------------
-- 3. 整体购买意愿分析
-- ------------------------------
SELECT 
    -- 修正错别字，统一显示
    REPLACE(REPLACE(购无人驾驶车意愿, '不原意', '不愿意'), '非常不原意', '非常不愿意') as 购买意愿,
    COUNT(*) as 人数,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM autonomous_car_survey), 1) as 占比
FROM autonomous_car_survey
GROUP BY 购无人驾驶车意愿
ORDER BY 
    CASE 购无人驾驶车意愿 
        WHEN '非常愿意' THEN 1 
        WHEN '愿意' THEN 2 
        WHEN '不愿意' THEN 3 
        WHEN '不原意' THEN 3
        WHEN '非常不愿意' THEN 4
        WHEN '非常不原意' THEN 4
    END;

-- ------------------------------
-- 4. 交叉分析
-- ------------------------------

-- 4.1 年龄段 vs 购车意愿 (占比)
SELECT 
    年龄段,
    -- 计算各年龄段内，不同意愿的占比
    ROUND(SUM(CASE WHEN 购无人驾驶车意愿 IN ('愿意', '非常愿意') THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) as 接受度,
    ROUND(SUM(CASE WHEN 购无人驾驶车意愿 IN ('不愿意', '非常不原意') THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) as 拒绝度
FROM autonomous_car_survey
GROUP BY 年龄段
ORDER BY 
    CASE 年龄段 
        WHEN '18岁以下' THEN 1 
        WHEN '18～24' THEN 2 
        WHEN '25～35' THEN 3 
        WHEN '36～54' THEN 4 
        WHEN '54岁及以上' THEN 5 
    END;

-- 4.2 体验过 vs 未体验过 的意愿对比
SELECT 
    是否尝试过,
    COUNT(*) as 总人数,
    ROUND(SUM(CASE WHEN 购无人驾驶车意愿 IN ('愿意', '非常愿意') THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) as 购买意愿占比
FROM autonomous_car_survey
GROUP BY 是否尝试过;

-- 4.3 了解程度 vs 购车意愿
SELECT 
    了解程度得分,
    COUNT(*) as 人数,
    ROUND(SUM(CASE WHEN 购无人驾驶车意愿 IN ('愿意', '非常愿意') THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) as 购买意愿占比
FROM autonomous_car_survey
GROUP BY 了解程度得分
ORDER BY 了解程度得分;

-- ------------------------------
-- 5. 用户核心关注点分析
-- ------------------------------

-- 5.1 愿意购车用户的理由统计
-- 统计在愿意购买的人群中，有多少人认同各个理由
WITH buyers AS (
    SELECT * FROM autonomous_car_survey 
    WHERE 购无人驾驶车意愿 IN ('愿意', '非常愿意')
)
SELECT 
    '减少驾驶疲惫感' as 关注点,
    ROUND(SUM(CASE WHEN 购车理由_减少疲惫感 IN ('同意', '非常同意') THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) as 认同占比
FROM buyers
UNION ALL
SELECT 
    '提高交通效率' as 关注点,
    ROUND(SUM(CASE WHEN 购车理由_提高效率 IN ('同意', '非常同意') THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) as 认同占比
FROM buyers
UNION ALL
SELECT 
    '技术发达' as 关注点,
    ROUND(SUM(CASE WHEN 购车理由_技术发达 IN ('同意', '非常同意') THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) as 认同占比
FROM buyers
UNION ALL
SELECT 
    '节能环保' as 关注点,
    ROUND(SUM(CASE WHEN 购车理由_节能环保 IN ('同意', '非常同意') THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) as 认同占比
FROM buyers
UNION ALL
SELECT 
    '减少交通事故' as 关注点,
    ROUND(SUM(CASE WHEN 购车理由_减少事故 IN ('同意', '非常同意') THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) as 认同占比
FROM buyers
ORDER BY 认同占比 DESC;

-- 5.2 拒绝购车用户的顾虑统计
WITH non_buyers AS (
    SELECT * FROM autonomous_car_survey 
    WHERE 购无人驾驶车意愿 IN ('不愿意', '非常不原意')
)
SELECT 
    '安全问题' as 顾虑点,
    ROUND(SUM(CASE WHEN 不购车理由_安全问题 IN ('同意', '非常同意') THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) as 认同占比
FROM non_buyers
UNION ALL
SELECT 
    '技术不够成熟' as 顾虑点,
    ROUND(SUM(CASE WHEN 不购车理由_技术不成熟 IN ('同意', '非常同意') THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) as 认同占比
FROM non_buyers
UNION ALL
SELECT 
    '法律法规不完善' as 顾虑点,
    ROUND(SUM(CASE WHEN 不购车理由_法规不完善 IN ('同意', '非常同意') THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) as 认同占比
FROM non_buyers
UNION ALL
SELECT 
    '质量不行' as 顾虑点,
    ROUND(SUM(CASE WHEN 不购车理由_质量不行 IN ('同意', '非常同意') THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) as 认同占比
FROM non_buyers
UNION ALL
SELECT 
    '喜欢手动驾驶' as 顾虑点,
    ROUND(SUM(CASE WHEN 不购车理由_喜欢手动 IN ('同意', '非常同意') THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) as 认同占比
FROM non_buyers
ORDER BY 认同占比 DESC;
