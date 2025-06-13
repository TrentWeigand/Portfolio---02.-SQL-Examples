USE weigand_portfolio;
/*
 These are the 5 table we created in 
 C:\Development\02. SQL Examples\Weigand_Portfolio_01_HSL_Create_Import.sql
 
 SELECT * FROM state_abbreviations;
 SELECT * FROM state_life_expectancy;
 SELECT * FROM state_expenditure;
 SELECT * FROM insured_by_state;
 SELECT * FROM uninsured_by_state;
 
 */
/* 
 
 Adding political party affiliation to the state_abbreviations table As of 2025
 Also Adding Regions to this table.
 
 Trifecta: A trifecta occurs when one party controls the governor’s office and both legislative chambers (House and Senate).
 
 I realised as I was developing this example that I needed to add a category to group on for aggregating the data.
 To accomodate I added a new column POLI_AFFILIATION and REGION to the state_abbreviations table.
 
 */
ALTER TABLE state_abbreviations
ADD COLUMN POLI_AFFILIATION ENUM('Democratic', 'Republican', 'Split', 'N/A') DEFAULT 'N/A';
-- Update POLI_AFFILIATION based on 2025 state government trifecta data
UPDATE state_abbreviations
SET POLI_AFFILIATION = CASE
        -- Republican trifectas (23 states)
        WHEN STATE IN (
            'Alabama',
            'Arkansas',
            'Florida',
            'Georgia',
            'Idaho',
            'Indiana',
            'Iowa',
            'Mississippi',
            'Missouri',
            'Montana',
            'Nebraska',
            'New Hampshire',
            'North Dakota',
            'Ohio',
            'Oklahoma',
            'South Carolina',
            'South Dakota',
            'Tennessee',
            'Texas',
            'Utah',
            'West Virginia',
            'Wyoming',
            'Louisiana'
        ) THEN 'Republican' -- Democratic trifectas (15 states)
        WHEN STATE IN (
            'California',
            'Colorado',
            'Connecticut',
            'Delaware',
            'Hawaii',
            'Illinois',
            'Maine',
            'Maryland',
            'Massachusetts',
            'New Mexico',
            'New York',
            'Oregon',
            'Rhode Island',
            'Washington',
            'New Jersey'
        ) THEN 'Democratic' -- Split control (12 states with divided governments or split legislatures)
        WHEN STATE IN (
            'Alaska',
            'Arizona',
            'Kansas',
            'Kentucky',
            'Michigan',
            'Minnesota',
            'Nevada',
            'North Carolina',
            'Pennsylvania',
            'Vermont',
            'Virginia',
            'Wisconsin'
        ) THEN 'Split'
        ELSE 'N/A' -- Default for any unmatched states
    END;
-- Update REGIONS (As catagorized by US Census Bureau)
ALTER TABLE state_abbreviations
ADD COLUMN REGION ENUM('Northeast', 'South', 'Midwest', 'West', 'N/A') DEFAULT 'N/A';
-- 
UPDATE state_abbreviations
SET REGION = CASE
        WHEN STATE IN (
            'Connecticut',
            'Maine',
            'Massachusetts',
            'New Hampshire',
            'Rhode Island',
            'Vermont',
            'New Jersey',
            'New York',
            'Pennsylvania'
        ) THEN 'Northeast'
        WHEN STATE IN (
            'Alabama',
            'Arkansas',
            'Florida',
            'Georgia',
            'Kentucky',
            'Louisiana',
            'Mississippi',
            'North Carolina',
            'South Carolina',
            'Tennessee',
            'Virginia',
            'West Virginia',
            'Delaware',
            'Maryland',
            'Texas',
            'Oklahoma'
        ) THEN 'South'
        WHEN STATE IN (
            'Illinois',
            'Indiana',
            'Iowa',
            'Kansas',
            'Michigan',
            'Minnesota',
            'Missouri',
            'Nebraska',
            'North Dakota',
            'Ohio',
            'South Dakota',
            'Wisconsin'
        ) THEN 'Midwest'
        WHEN STATE IN (
            'Alaska',
            'Arizona',
            'California',
            'Colorado',
            'Hawaii',
            'Idaho',
            'Montana',
            'Nevada',
            'New Mexico',
            'Oregon',
            'Utah',
            'Washington',
            'Wyoming'
        ) THEN 'West'
        ELSE 'N/A'
    END;
-- 
select *
from state_abbreviations;
DESCRIBE state_abbreviations;
/*  
 
 General Overview/Investigation.
 
 */
SELECT T1.STATE_ABBR,
    T1.STATE AS STATE,
    -- T0.POLI_AFFILIATION AS POLI_AFFILIATION,
    T1.LIFE_EXPECTANCY AS LIFE_EXPECTANCY,
    RANK() OVER (
        ORDER BY T1.LIFE_EXPECTANCY DESC
    ) AS RANK_LIFE_EXPECTANCY,
    T2.HEALTH AS HEALTH_EXPENDITURE,
    T2.HEALTH /(T3.CIVI_NONINST_POP + T4.CIVI_NONINST_POP) AS HEALTH_EXP_PER_CAPITA,
    RANK() OVER (
        ORDER BY T2.HEALTH /(T3.CIVI_NONINST_POP + T4.CIVI_NONINST_POP) DESC
    ) AS RANK_HEALTH_EXPENDITURE,
    T3.CIVI_NONINST_POP AS INSURED,
    -- T4.CIVI_NONINST_POP AS UNINSURED,
    T3.CIVI_NONINST_POP + T4.CIVI_NONINST_POP AS TOTAL_POPULATION,
    ROUND(
        T3.CIVI_NONINST_POP / (T3.CIVI_NONINST_POP + T4.CIVI_NONINST_POP),
        2
    ) AS INSURED_PERCENT -- ,ROUND(T4.CIVI_NONINST_POP / (T3.CIVI_NONINST_POP + T4.CIVI_NONINST_POP),2) AS UNINSURED_PERCENT
FROM state_life_expectancy T1,
    STATE_EXPENDITURE T2,
    INSURED_BY_STATE T3,
    UNINSURED_BY_STATE T4,
    state_abbreviations T0
WHERE 1 = 1
    AND T1.TYPE = 'S'
    AND T1.STATE_ABBR = T0.STATE_ABBR
    AND T1.STATE_ABBR = T2.STATE_ABBR
    AND T1.STATE_ABBR = T3.STATE_ABBR
    AND T1.STATE_ABBR = T4.STATE_ABBR
ORDER BY T2.HEALTH /(T3.CIVI_NONINST_POP + T4.CIVI_NONINST_POP) DESC;
/*  
 
 Aggregate by political affiliation
 
 */
SELECT T0.POLI_AFFILIATION AS POLI_AFFILIATION,
    AVG(T1.LIFE_EXPECTANCY) AS LIFE_EXPECTANCY,
    SUM(T2.HEALTH) AS HEALTH_EXPENDITURE,
    SUM(T2.HEALTH) /(
        SUM(T3.CIVI_NONINST_POP) + SUM(T4.CIVI_NONINST_POP)
    ) AS HEALTH_EXP_PER_CAPITA
FROM state_life_expectancy T1,
    STATE_EXPENDITURE T2,
    INSURED_BY_STATE T3,
    UNINSURED_BY_STATE T4,
    state_abbreviations T0
WHERE 1 = 1
    AND T1.TYPE = 'S'
    AND T1.STATE_ABBR = T0.STATE_ABBR
    AND T1.STATE_ABBR = T2.STATE_ABBR
    AND T1.STATE_ABBR = T3.STATE_ABBR
    AND T1.STATE_ABBR = T4.STATE_ABBR
GROUP BY T0.POLI_AFFILIATION;
/* 
 
 01. - Correlation Coefficent
 Calculate correlation Coefficent using Life Expectancy and expence per capita
 
 */
WITH METRICS_BY_STATE AS (
    SELECT T1.STATE_ABBR,
        T0.LIFE_EXPECTANCY,
        -- T2.CIVI_NONINST_POP /(T2.CIVI_NONINST_POP + T3.CIVI_NONINST_POP) AS INSURED_PERCENT,
        T1.HEALTH /(T2.CIVI_NONINST_POP + T3.CIVI_NONINST_POP) AS HEALTH_EXP_PER_CAPITA
    FROM state_life_expectancy T0
        JOIN state_expenditure T1 ON T0.STATE_ABBR = T1.STATE_ABBR
        JOIN insured_by_state T2 ON T0.STATE_ABBR = T2.STATE_ABBR
        JOIN uninsured_by_state T3 ON T0.STATE_ABBR = T3.STATE_ABBR
    WHERE 1 = 1
        AND T0.TYPE = 'S'
)
SELECT ROUND(
        (
            AVG(LIFE_EXPECTANCY * HEALTH_EXP_PER_CAPITA) - AVG(LIFE_EXPECTANCY) * AVG(HEALTH_EXP_PER_CAPITA)
        ) / (
            STDDEV(LIFE_EXPECTANCY) * STDDEV(HEALTH_EXP_PER_CAPITA)
        ),
        4
    ) AS CORRELATION_COEFFICENT
FROM METRICS_BY_STATE;
/* 
 
 02. - OUTLIER CHECK
 For this example We'll consider anything more than +/- 1.5* the Inter-Quartile-Range (IQR) as an outlier
 
 */
WITH METRICS_BY_STATE AS (
    SELECT T1.STATE_ABBR,
        T1.STATE,
        T1.HEALTH /(T2.CIVI_NONINST_POP + T3.CIVI_NONINST_POP) AS HEALTH_EXP_PER_CAPITA,
        ROW_NUMBER () OVER (
            ORDER BY T1.HEALTH /(T2.CIVI_NONINST_POP + T3.CIVI_NONINST_POP)
        ) AS ORDERED_ROW,
        COUNT(*) OVER() AS TOTAL_ROWS
    FROM state_expenditure T1
        JOIN insured_by_state T2 ON T1.STATE_ABBR = T2.STATE_ABBR
        JOIN uninsured_by_state T3 ON T1.STATE_ABBR = T3.STATE_ABBR --
    WHERE 1 = 1
        AND T1.TYPE = 'S'
        AND T1.HEALTH IS NOT NULL
        AND T2.CIVI_NONINST_POP IS NOT NULL
        AND T3.CIVI_NONINST_POP IS NOT NULL
),
INNER_QUARTILES AS(
    /*   The Windows function 'Percentile Cont' is not supported on this version so we'll have to manually calculate Q1 & Q3.
     if it was the function would look something like this 
     PERCENTILE CONT (0.25) WITHIN GROUP (ORDER BY HEALTH_EXP_PER_CAPITA) OVER() AS Q1,
     PERCENTILE CONT (0.75) WITHIN GROUP (ORDER BY HEALTH_EXP_PER_CAPITA) OVER() AS Q3,
     N = COUNT(*) (POPULATION SIZE IE. 50 STATES) 
     Q1_index=(N+1)*.25; Q3_index=(N=1)*.75
     THESE FORMULAS BELOW APPROXIMATE Q1 AND Q3 BY indexing the appropriate value in the ordered dataset
     */
    SELECT MAX(
            CASE
                WHEN ORDERED_ROW = CEIL(TOTAL_ROWS *.25) THEN HEALTH_EXP_PER_CAPITA
            END
        ) AS Q1,
        MAX(
            CASE
                WHEN ORDERED_ROW = CEIL(TOTAL_ROWS *.75) THEN HEALTH_EXP_PER_CAPITA
            END
        ) AS Q3
    FROM METRICS_BY_STATE
)
SELECT A.STATE_ABBR,
    A.STATE,
    A.HEALTH_EXP_PER_CAPITA,
    CASE
        WHEN A.HEALTH_EXP_PER_CAPITA < (B.Q1 - 1.5 * (B.Q3 - B.Q1))
        OR A.HEALTH_EXP_PER_CAPITA > (B.Q3 + 1.5 * (B.Q3 - B.Q1)) THEN 'OUTLIER'
        ELSE 'NORMAL'
    END AS OUTLIER_STATUS,
    -- BELOW ARE OPTIONAL TO VIEW IQR,Q1,Q3
    (B.Q3 - B.Q1) AS IQR,
    B.Q1,
    B.Q3
FROM METRICS_BY_STATE A
    CROSS JOIN INNER_QUARTILES B
ORDER BY A.HEALTH_EXP_PER_CAPITA DESC;
/* 
 
 03. - Geo-clustering 
 Aggregating the data by Region (Northeast, South, Midwest, West)
 
 */
SELECT T0.REGION,
    AVG(T1.LIFE_EXPECTANCY) AS AVG_LIFE_EXPECTANCY,
    SUM(T2.HEALTH) / SUM(T3.CIVI_NONINST_POP + T4.CIVI_NONINST_POP) AS HEALTH_EXP_PER_CAPITA,
    AVG(
        T3.CIVI_NONINST_POP /(T3.CIVI_NONINST_POP + T4.CIVI_NONINST_POP)
    ) AS INSURED_PERCENT
FROM state_abbreviations T0,
    state_life_expectancy T1,
    state_expenditure T2,
    insured_by_state T3,
    uninsured_by_state T4
WHERE 1 = 1
    AND T0.STATE_ABBR = T1.STATE_ABBR
    AND T0.STATE_ABBR = T2.STATE_ABBR
    AND T0.STATE_ABBR = T3.STATE_ABBR
    AND T0.STATE_ABBR = T4.STATE_ABBR
    AND T0.TYPE = 'S'
GROUP BY REGION
ORDER BY AVG_LIFE_EXPECTANCY;
/* 
 
 04.A Ranking states 
 based on:
 LIFE EXPECTANCY,
 % Insured, 
 health expednature per capita.
 
 */
WITH RANK_TEMP AS (
    SELECT T0.STATE AS STATE,
        T1.LIFE_EXPECTANCY AS LIFE_EXPECTANCY,
        RANK() OVER(
            ORDER BY T1.LIFE_EXPECTANCY
        ) AS LIFE_RANK,
        T2.HEALTH / (T3.CIVI_NONINST_POP + T4.CIVI_NONINST_POP) AS HEALTH_EXPENDITURE_PER_CAPITA,
        --  Important to add 'DESC' after the order by so we rank highest expendature pre capita as 1. 
        RANK() OVER(
            ORDER BY T2.HEALTH / (T3.CIVI_NONINST_POP + T4.CIVI_NONINST_POP) DESC
        ) AS EXP_PER_CAPITA_RANK,
        T3.CIVI_NONINST_POP / (T3.CIVI_NONINST_POP + T4.CIVI_NONINST_POP) AS INSURED_PERCENT,
        RANK() OVER (
            ORDER BY T3.CIVI_NONINST_POP / (T3.CIVI_NONINST_POP + T4.CIVI_NONINST_POP) DESC
        ) AS INSURED_RANK
    FROM state_abbreviations T0
        JOIN state_life_expectancy T1 ON T0.STATE_ABBR = T1.STATE_ABBR
        JOIN STATE_EXPENDITURE T2 ON T0.STATE_ABBR = T2.STATE_ABBR
        JOIN insured_by_state T3 ON T0.STATE_ABBR = T3.STATE_ABBR
        JOIN uninsured_by_state T4 ON T0.STATE_ABBR = T4.STATE_ABBR
)
SELECT STATE,
    LIFE_EXPECTANCY,
    LIFE_RANK,
    ROUND(HEALTH_EXPENDITURE_PER_CAPITA, 2) AS HEALTH_EXPENDITURE_PER_CAPITA,
    EXP_PER_CAPITA_RANK,
    ROUND(INSURED_PERCENT * 100, 2) AS INSURED_PERCENT,
    INSURED_RANK
FROM RANK_TEMP
WHERE 1 = 1
    AND EXP_PER_CAPITA_RANK <= 5
ORDER BY EXP_PER_CAPITA_RANK,
    STATE;
/* 
 
 04.B Ranking states 
 similar to 4A except this time we'll partition the ranking by a category (poli affiliation)
 
 */
WITH RANK_TEMP AS (
    SELECT T0.STATE AS STATE,
        T0.POLI_AFFILIATION AS POLI_AFFILIATION,
        T1.LIFE_EXPECTANCY AS LIFE_EXPECTANCY,
        RANK() OVER(
            PARTITION BY T0.POLI_AFFILIATION
            ORDER BY T1.LIFE_EXPECTANCY
        ) AS LIFE_RANK,
        T2.HEALTH / (T3.CIVI_NONINST_POP + T4.CIVI_NONINST_POP) AS HEALTH_EXPENDITURE_PER_CAPITA,
        --  Important to add 'DESC' after the order by so we rank highest expendature pre capita as 1. 
        RANK() OVER(
            PARTITION BY T0.POLI_AFFILIATION
            ORDER BY T2.HEALTH / (T3.CIVI_NONINST_POP + T4.CIVI_NONINST_POP) DESC
        ) AS EXP_PER_CAPITA_RANK,
        T3.CIVI_NONINST_POP / (T3.CIVI_NONINST_POP + T4.CIVI_NONINST_POP) AS INSURED_PERCENT,
        RANK() OVER (
            PARTITION BY T0.POLI_AFFILIATION
            ORDER BY T3.CIVI_NONINST_POP / (T3.CIVI_NONINST_POP + T4.CIVI_NONINST_POP) DESC
        ) AS INSURED_RANK
    FROM state_abbreviations T0
        JOIN state_life_expectancy T1 ON T0.STATE_ABBR = T1.STATE_ABBR
        JOIN STATE_EXPENDITURE T2 ON T0.STATE_ABBR = T2.STATE_ABBR
        JOIN insured_by_state T3 ON T0.STATE_ABBR = T3.STATE_ABBR
        JOIN uninsured_by_state T4 ON T0.STATE_ABBR = T4.STATE_ABBR
)
SELECT POLI_AFFILIATION,
    STATE,
    LIFE_EXPECTANCY,
    LIFE_RANK,
    ROUND(HEALTH_EXPENDITURE_PER_CAPITA, 2) AS HEALTH_EXPENDITURE_PER_CAPITA,
    EXP_PER_CAPITA_RANK,
    ROUND(INSURED_PERCENT * 100, 2) AS INSURED_PERCENT,
    INSURED_RANK
FROM RANK_TEMP
WHERE 1 = 1
    AND EXP_PER_CAPITA_RANK <= 5
ORDER BY POLI_AFFILIATION,
    EXP_PER_CAPITA_RANK,
    STATE;
/* 
 
 05. Multidimesional analysis 
 (poli-affil & region)
 Similar to a basic pivot table in excel
 
 */
SELECT T0.REGION,
    ROUND(
        AVG(
            CASE
                WHEN T0.POLI_AFFILIATION = 'Democratic' THEN T2.HEALTH / (T3.CIVI_NONINST_POP + T4.CIVI_NONINST_POP)
            END
        ),
        2
    ) AS DEM_EXP_PER_CAPITA,
    ROUND(
        AVG(
            CASE
                WHEN T0.POLI_AFFILIATION = 'Republican' THEN T2.HEALTH / (T3.CIVI_NONINST_POP + T4.CIVI_NONINST_POP)
            END
        ),
        2
    ) AS REP_EXP_PER_CAPITA,
    ROUND(
        AVG(
            CASE
                WHEN T0.POLI_AFFILIATION = 'Split' THEN T2.HEALTH / (T3.CIVI_NONINST_POP + T4.CIVI_NONINST_POP)
            END
        ),
        2
    ) AS SPLIT_EXP_PER_CAPITA
FROM state_life_expectancy T1
    JOIN state_abbreviations T0 ON T1.STATE_ABBR = T0.STATE_ABBR
    JOIN state_expenditure T2 ON T1.STATE_ABBR = T2.STATE_ABBR
    JOIN insured_by_state T3 ON T1.STATE_ABBR = T3.STATE_ABBR
    JOIN uninsured_by_state T4 ON T1.STATE_ABBR = T4.STATE_ABBR
WHERE T1.TYPE = 'S'
GROUP BY T0.REGION
ORDER BY T0.REGION;
/* 
 
 06.A Procedure Excample 
 Good example of createing a procedure that accepts input that can quickly and dynamically run quieries.
 If we had time sequenced data we could also use this to update dates as opposed to creating a seperate table containing the 'report_date'
 
 DELIMITER: If running code as a script the delimiter may have to be changed. 
 Some versions of SQL will requier changing the delimiter which allows for the the whole script 
 (creating the proceduer) to run without executing each line ending in ;.
 
 */
CREATE PROCEDURE AggregateByCategory(IN category VARCHAR(50)) BEGIN
SET @sql = CONCAT(
        '
        SELECT 
            T0.',
        category,
        ' AS CATEGORY,
            AVG(T1.LIFE_EXPECTANCY) AS AVG_LIFE_EXPECTANCY,
            SUM(T2.HEALTH) / SUM(T3.CIVI_NONINST_POP + T4.CIVI_NONINST_POP) AS HEALTH_EXP_PER_CAPITA,
            AVG(T3.CIVI_NONINST_POP / (T3.CIVI_NONINST_POP + T4.CIVI_NONINST_POP)) AS AVG_INSURED_PERCENT
        FROM state_life_expectancy T1
        JOIN state_abbreviations T0 ON T1.STATE_ABBR = T0.STATE_ABBR
        JOIN state_expenditure T2 ON T1.STATE_ABBR = T2.STATE_ABBR
        JOIN insured_by_state T3 ON T1.STATE_ABBR = T3.STATE_ABBR
        JOIN uninsured_by_state T4 ON T1.STATE_ABBR = T4.STATE_ABBR
        WHERE T1.TYPE = ''S''
        GROUP BY T0.',
        category,
        '
        ORDER BY AVG_LIFE_EXPECTANCY DESC
    '
    );
PREPARE stmt
FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
END;
/* 
 
 06.B Call the procedure with specified variable
 
 */
CALL AggregateByCategory('POLI_AFFILIATION');
CALL AggregateByCategory('REGION');
/* 
 
 07. Status Check
 Simple check to see if we are missing data for any of the fields we used.
 
 */
SELECT T0.STATE_ABBR,
    T0.STATE,
    CASE
        WHEN T1.LIFE_EXPECTANCY IS NULL THEN 'Missing Life Expectancy'
        ELSE 'OK'
    END AS LIFE_EXPECTANCY_STATUS,
    CASE
        WHEN T2.HEALTH IS NULL THEN 'Missing Health Expenditure'
        ELSE 'OK'
    END AS EXPENDITURE_STATUS,
    CASE
        WHEN T3.CIVI_NONINST_POP IS NULL THEN 'Missing Insured Population'
        ELSE 'OK'
    END AS INSURED_STATUS,
    CASE
        WHEN T4.CIVI_NONINST_POP IS NULL THEN 'Missing Uninsured Population'
        ELSE 'OK'
    END AS UNINSURED_STATUS
FROM state_abbreviations T0
    LEFT JOIN state_life_expectancy T1 ON T0.STATE_ABBR = T1.STATE_ABBR
    AND T1.TYPE = 'S'
    LEFT JOIN state_expenditure T2 ON T0.STATE_ABBR = T2.STATE_ABBR
    LEFT JOIN insured_by_state T3 ON T0.STATE_ABBR = T3.STATE_ABBR
    LEFT JOIN uninsured_by_state T4 ON T0.STATE_ABBR = T4.STATE_ABBR
WHERE T1.LIFE_EXPECTANCY IS NULL
    OR T2.HEALTH IS NULL
    OR T3.CIVI_NONINST_POP IS NULL
    OR T4.CIVI_NONINST_POP IS NULL
ORDER BY T0.STATE_ABBR;