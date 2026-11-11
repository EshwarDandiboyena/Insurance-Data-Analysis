use insurance_db;

-- KPI 1: Total Customers

SELECT COUNT(DISTINCT `Customer ID`) AS total_customers
FROM customer_information;

-- KPI 2:Total policies

SELECT COUNT(DISTINCT `Policy ID`) AS total_policies
FROM policy_details;

-- KPI 3: Total Claim Amount 

select sum(`Claim Amount`) as 'Total claim amount'
from claims;

-- KPI 4: Average coverage Amount

select avg(`Coverage Amount`) as 'average coverage amount'
from policy_details;

-- KPI 5: Average premium Amount

select avg(`Premium Amount`) as 'average premium amount'
from policy_details;

-- KPI 6 : Percentage of policies currently active --

SELECT ROUND(
    100.0 * SUM(CASE WHEN `Status` = 'Active'
        THEN 1 ELSE 0 END) / COUNT(*), 2
) AS active_percentage
FROM policy_details;

-- 7. Number of active, lapsed, and terminated policies --

SELECT `Status`, COUNT(DISTINCT `Policy ID`) AS policy_count
FROM policy_details
GROUP BY `Status`;

-- 8 Which policy status has the highest number of policies--

SELECT `Status`, COUNT(DISTINCT `Policy ID`) AS policy_count
FROM policy_details
GROUP BY `Status`
ORDER BY policy_count DESC
LIMIT 1;

-- 9 Ratio between active and inactive policies -----

SELECT
    SUM(CASE WHEN `Status` = 'Active'
        THEN 1 ELSE 0 END) AS active_policies,
    SUM(CASE WHEN `Status` IN ('Lapsed', 'Terminated')
        THEN 1 ELSE 0 END) AS inactive_policies,
    ROUND(
        SUM(CASE WHEN `Status` = 'Active'
            THEN 1 ELSE 0 END) /
        NULLIF(SUM(CASE WHEN `Status` IN ('Lapsed', 'Terminated')
            THEN 1 ELSE 0 END), 0), 4
    ) AS active_inactive_ratio
FROM policy_details;

-- 10 Which age group has the highest number of policies ----

SELECT c.`Age group`,
       COUNT(DISTINCT p.`Policy ID`) AS policy_count
FROM customer_information c
JOIN policy_details p
    ON c.`Customer ID` = p.`Customer ID`
GROUP BY c.`Age group`
ORDER BY policy_count DESC
LIMIT 1;

-- 11 Top three age groups by policy count -----

SELECT c.`Age group`,
       COUNT(DISTINCT p.`Policy ID`) AS policy_count
FROM customer_information c
JOIN policy_details p 
    ON c.`Customer ID` = p.`Customer ID`
GROUP BY c.`Age group`
ORDER BY policy_count DESC
LIMIT 3;

-- 12. Which gender has the highest policy participation-- 

SELECT c.`Gender`,
       COUNT(DISTINCT p.`Policy ID`) AS policy_count
FROM customer_information c
JOIN policy_details p
    ON c.`Customer ID` = p.`Customer ID`
GROUP BY c.`Gender`
ORDER BY policy_count DESC
LIMIT 1;

-- 13 Difference between male and female policy counts ------

SELECT
    SUM(CASE WHEN c.`Gender` = 'Male'
        THEN 1 ELSE 0 END) AS male_policies,
    SUM(CASE WHEN c.`Gender` = 'Female'
        THEN 1 ELSE 0 END) AS female_policies,
    ABS(
        SUM(CASE WHEN c.`Gender` = 'Male'
            THEN 1 ELSE 0 END) -
        SUM(CASE WHEN c.`Gender` = 'Female'
            THEN 1 ELSE 0 END)
    ) AS difference
FROM customer_information c
JOIN policy_details p
    ON c.`Customer ID` = p.`Customer ID`;
    
    
    -- 14 Which policy type has the maximum number of policies ----
    
SELECT `Policy Type`, COUNT(DISTINCT `Policy ID`) AS policy_count
FROM policy_details
GROUP BY `Policy Type`
ORDER BY policy_count DESC
LIMIT 1;

-- 15 Which policy type has the minimum number of policies ----

SELECT `Policy Type`, COUNT(DISTINCT `Policy ID`) AS policy_count
FROM policy_details
GROUP BY `Policy Type`
ORDER BY policy_count ASC
LIMIT 1;


-- 16 Compare Auto and Health policy counts ---

SELECT `Policy Type`,
       COUNT(DISTINCT `Policy ID`) AS policy_count
FROM policy_details
WHERE `Policy Type` IN ('Auto', 'Health')
GROUP BY `Policy Type`;


-- 17 Total number of policies across all policy types -----

SELECT COUNT(DISTINCT `Policy ID`) AS total_policies
FROM policy_details;


-- 18 Average premium growth rate over all years ----

WITH yearly_premium AS (
    SELECT
        `Policy Start date year` AS policy_year,
        SUM(`Premium Amount`) AS total_premium
    FROM policy_details
    GROUP BY `Policy Start date year`
),
growth AS (
    SELECT
        policy_year,
        100.0 * (
            total_premium -
            LAG(total_premium) OVER (ORDER BY policy_year)
        ) /
        NULLIF(
            LAG(total_premium) OVER (ORDER BY policy_year),
            0
        ) AS growth_rate
    FROM yearly_premium
)
SELECT ROUND(AVG(growth_rate), 2) AS average_growth_rate
FROM growth;

-- 19 Is the premium growth trend increasing or decreasing ---


WITH yearly_premium AS (
    SELECT
        `Policy Start date year` AS policy_year,
        SUM(`Premium Amount`) AS total_premium
    FROM policy_details
    GROUP BY `Policy Start date year`
),
growth AS (
    SELECT
        policy_year,
        100.0 * (
            total_premium -
            LAG(total_premium) OVER (ORDER BY policy_year)
        ) / NULLIF(
            LAG(total_premium) OVER (ORDER BY policy_year), 0
        ) AS growth_rate
    FROM yearly_premium
)
SELECT
    policy_year,
    ROUND(growth_rate, 2) AS growth_rate
FROM growth
ORDER BY policy_year;

-- 20 Difference between the highest and lowest premium growth rates --

WITH yearly_premium AS (
    SELECT
        `Policy Start date year` AS policy_year,
        SUM(`Premium Amount`) AS total_premium
    FROM policy_details
    GROUP BY `Policy Start date year`
),
growth AS (
    SELECT
        policy_year,
        100.0 * (
            total_premium -
            LAG(total_premium) OVER (ORDER BY policy_year)
        ) / NULLIF(
            LAG(total_premium) OVER (ORDER BY policy_year), 0
        ) AS growth_rate
    FROM yearly_premium
)
SELECT ROUND(MAX(growth_rate) - MIN(growth_rate), 2)
       AS growth_rate_difference
FROM growth;

-- 21 What is the yearly trend of policies ending from 2016 to 2034 ----

SELECT `Policy End date Year` AS ending_year,
COUNT(DISTINCT `Policy ID`) AS policies_ending
FROM policy_details
WHERE `Policy End date Year` BETWEEN 2016 AND 2034
GROUP BY `Policy End date Year`
ORDER BY `Policy End date Year`;