
-- ====================================================================
-- PROJECT: GLOBAL DATA SCIENCE JOB MARKET ANALYSIS
-- DATASET: 3,925 Rows of Global Salaries and Job Metadata
-- AUTHOR: Data Analyst Candidate Portfolio
-- ====================================================================

-- --------------------------------------------------------------------
-- PHASE 1 & 2: DATABASE SETUP & DATA CLEANING
-- --------------------------------------------------------------------

-- 1. Check for missing values (NULLs) in critical columns
SELECT
  COUNT(*) FILTER (WHERE job_title IS NULL) AS missing_title,
  COUNT(*) FILTER (WHERE salary_in_usd IS NULL) AS missing_salary,
  COUNT(*) FILTER (WHERE job_category IS NULL) AS missing_category,
  COUNT(*) FILTER (WHERE company_location IS NULL) AS missing_location
FROM jobs_data;

-- 2. Audit the dataset for identical duplicate records
SELECT job_title, job_category, salary_in_usd, company_location, COUNT(*)
FROM jobs_data
GROUP BY job_title, job_category, salary_in_usd, company_location
HAVING COUNT(*) > 1;

-- 3. Standardize and normalize messy country text strings
UPDATE jobs_data
SET company_location = CASE
  WHEN company_location ILIKE '%United States%' OR company_location ILIKE 'US' OR company_location ILIKE 'USA' THEN 'United States'
  WHEN company_location ILIKE '%United Kingdom%' OR company_location ILIKE 'UK' THEN 'United Kingdom'
  ELSE company_location
END;

-- 4. Feature Engineering: Create a high-level experience mapping category
-- First time setup requires running: ALTER TABLE jobs_data ADD COLUMN exp_band VARCHAR(20);
UPDATE jobs_data
SET exp_band = CASE
  WHEN experience_level ILIKE '%entry%' OR experience_level = 'EN' THEN 'Entry'
  WHEN experience_level ILIKE '%mid%' OR experience_level = 'MI' THEN 'Mid'
  WHEN experience_level ILIKE '%senior%' OR experience_level = 'SE' THEN 'Senior'
  WHEN experience_level ILIKE '%exec%' OR experience_level = 'EX' THEN 'Executive'
  ELSE 'Unspecified'
END;


-- --------------------------------------------------------------------
-- PHASE 3: CORE BUSINESS ANALYSIS QUERIES
-- --------------------------------------------------------------------

-- Q1: Average salary by country (With minimum sample size threshold)
SELECT company_location, ROUND(AVG(salary_in_usd), 0) AS avg_salary, COUNT(*) AS volume
FROM jobs_data
GROUP BY company_location
HAVING COUNT(*) >= 5  -- <--- The filter is already live right here!
ORDER BY avg_salary DESC;



-- Q2: What are the top 10 highest-paying job titles?
-- Uses sample size logic (HAVING >= 5) to remove rare data flukes and outliers.
SELECT job_title, ROUND(AVG(salary_in_usd), 0) AS avg_salary, COUNT(*) AS listings
FROM jobs_data
GROUP BY job_title
HAVING COUNT(*) >= 5
ORDER BY avg_salary DESC
LIMIT 10;

-- Q3: How does average salary scale across experience bands?
SELECT exp_band, ROUND(AVG(salary_in_usd), 0) AS avg_salary
FROM jobs_data
GROUP BY exp_band
ORDER BY avg_salary DESC;

-- Q4: Which high-level job categories have the highest market volume/demand?
SELECT job_category, COUNT(*) AS frequency
FROM jobs_data
GROUP BY job_category
ORDER BY frequency DESC;

-- Q5: Ultimate Headline Insight (Country + Category + Experience Combo)
-- Filters for a minimum sample size of 5 rows to ensure statistical significance.
SELECT 
    company_location, 
    job_category, 
    exp_band,
    ROUND(AVG(salary_in_usd), 0) AS avg_salary,
    COUNT(*) AS total_listings
FROM jobs_data
GROUP BY company_location, job_category, exp_band
HAVING COUNT(*) >= 5
ORDER BY avg_salary DESC
LIMIT 15;


-- --------------------------------------------------------------------
-- PHASE 4: ADVANCED WINDOW FUNCTIONS & INTERVIEW PATTERNS
-- --------------------------------------------------------------------

-- 1. Rank job titles within each country (Filtered for statistically significant markets)
SELECT 
    company_location, 
    job_title, 
    avg_salary,
    listings_in_market,
    RANK() OVER (PARTITION BY company_location ORDER BY avg_salary DESC) AS salary_rank
FROM (
    SELECT 
        company_location, 
        job_title, 
        ROUND(AVG(salary_in_usd), 0) AS avg_salary,
        COUNT(*) AS listings_in_market
    FROM jobs_data
    GROUP BY company_location, job_title
) subquery
WHERE listings_in_market >= 5
ORDER BY company_location ASC, salary_rank ASC;

-- 2. Extract ONLY the top 3 elite paying roles per country (CTE with sample size floor)
WITH ranked_jobs AS (
  SELECT 
    company_location, 
    job_title,
    ROUND(AVG(salary_in_usd), 0) AS avg_salary,
    COUNT(*) AS volume,
    RANK() OVER (PARTITION BY company_location ORDER BY AVG(salary_in_usd) DESC) AS rnk
  FROM jobs_data
  GROUP BY company_location, job_title
  HAVING COUNT(*) >= 5
)
SELECT company_location, job_title, avg_salary, volume, rnk 
FROM ranked_jobs 
WHERE rnk <= 3;

-- 3. Calculate the salary percentile ranking within each individual experience band
SELECT 
  exp_band, 
  job_title, 
  salary_in_usd AS salary,
  ROUND(PERCENT_RANK() OVER (PARTITION BY exp_band ORDER BY salary_in_usd)::numeric * 100, 1) AS percentile_score
FROM jobs_data
ORDER BY exp_band DESC, salary DESC;

-- 4. Benchmark: Compare rows against country baselines 
-- [LOGIC]: The CTE labels every row with its country's total volume count badge.
-- The outer WHERE clause then handles the actual filtering to eliminate low-sample markets.
WITH filtered_countries AS (
  SELECT *,
         COUNT(*) OVER(PARTITION BY company_location) AS country_volume
  FROM jobs_data
)
SELECT 
  job_title, 
  company_location, 
  salary_in_usd AS salary,
  ROUND(AVG(salary_in_usd) OVER (PARTITION BY company_location), 0) AS country_avg,
  ROUND(salary_in_usd - AVG(salary_in_usd) OVER (PARTITION BY company_location), 0) AS diff_from_avg
FROM filtered_countries
WHERE country_volume >= 5
ORDER BY company_location ASC, diff_from_avg DESC;
