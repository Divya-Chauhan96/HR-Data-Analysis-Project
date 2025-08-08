CREATE DATABASE HR_ANALYTICS;
USE HR_ANALYTICS;

CREATE TABLE HR_1 (
AGE INT, ATTRITION VARCHAR(50) , BUSINESS_TRAVEL VARCHAR(50), DAILY_RATE INT, DEPARTMENT VARCHAR(100) , DISTANCE_FROM_HOME INT , EDUCATION INT, EDUCATION_FIELD VARCHAR(100),
EMPLOYEE_COUNT INT , EMPLOYEE_NUMBER INT  , ENVIRONMENT_SATISFACTION INT, GENDER VARCHAR(100) ,  HOURLY_RATE INT, JOB_INVOLVEMENT INT , JOB_LEVEL INT, JOB_ROLE VARCHAR(100), JOB_SATISFACTION INT , MARITAL_STATUS VARCHAR(100));

CREATE TABLE HR_2 (
EMPLOYEE_ID INT, MONTHLY_INCOME INT, MONTHLY_RATE INT, NUM_COMPANIES_WORKED INT, OVER_18 VARCHAR(20), OVER_TIME VARCHAR(20), PERCENT_SALARY_HIKE INT, PERFORMANCE_RATING INT,
 RELATIONSHIP_SATISFACTION INT, STANDARD_HOURS INT, STOCK_OPTION_LEVEL INT, TOTAL_WORKING_YEARS INT, TRAINING_TIMES_LAST_YEAR INT, WORK_LIFE_BALANCE INT,YEARS_AT_COMPANY INT,
YEARS_IN_CURRENT_ROLE INT, YEARS_SINCE_LAST_PROMOTION INT,YEARS_WITH_CURRENT_MANAGER INT );

SHOW VARIABLES LIKE 'secure_file_priv';
SHOW GLOBAL VARIABLES LIKE 'local_infile';
SET GLOBAL local_infile = 'ON';  

LOAD DATA INFILE "C:/Divya/D.A/PROJECT/HR Analysis Project/HR Analytics/HR_1.CSV.CSV"
INTO TABLE HR_1
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE "C:/Divya/D.A/PROJECT/HR Analysis Project/HR Analytics/HR_2.CSV.csv"
INTO TABLE HR_2
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT * FROM HR_1;
SELECT * FROM HR_2;
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE VIEW HR_COMBINED AS SELECT
H1.*,
H2.MONTHLY_INCOME,
H2.MONTHLY_RATE,
H2.NUM_COMPANIES_WORKED,
H2.OVER_18,
H2.OVER_TIME,
H2.PERCENT_SALARY_HIKE,
H2.PERFORMANCE_RATING,
H2.RELATIONSHIP_SATISFACTION ,
H2.STANDARD_HOURS ,
H2.STOCK_OPTION_LEVEL  ,
H2.TOTAL_WORKING_YEARS ,
H2.TRAINING_TIMES_LAST_YEAR ,
H2.WORK_LIFE_BALANCE  ,
H2.YEARS_AT_COMPANY ,
H2.YEARS_IN_CURRENT_ROLE ,
H2.YEARS_SINCE_LAST_PROMOTION ,
H2.YEARS_WITH_CURRENT_MANAGER
FROM HR_1 H1 JOIN HR_2 H2 ON H1.EMPLOYEE_NUMBER=H2.EMPLOYEE_ID ;

SELECT * FROM HR_COMBINED;

-- --------------------------------------------------------MONTHLY INCOME OF EACH EMPLOYEE ------------------------------------------------------------------------------

SELECT EMPLOYEE_NUMBER , SUM(MONTHLY_INCOME) FROM HR_COMBINED
GROUP BY EMPLOYEE_NUMBER
ORDER BY SUM(MONTHLY_INCOME) DESC
;
-- ------------------------------------------------------------DEPARTMENT WISE ATTRITION_count ---------------------------------------------------------------------------------------- 

SELECT DEPARTMENT , SUM(CASE WHEN ATTRITION = 'Yes' then 1 else 0 end) as Attrition_count
FROM HR_COMBINED
GROUP BY DEPARTMENT ;

-- -------------------------------------------------------------DEPARTMENT WISE  AVERAGE ATTRITION RATE -----------------------------------------------------------------

SELECT DEPARTMENT , CONCAT(ROUND((SUM(CASE WHEN ATTRITION = 'Yes' THEN 1 ELSE 0 END ) * 100 ) / COUNT(ATTRITION),2),'%') AS AVG_ATT_RATE
FROM HR_COMBINED
GROUP BY DEPARTMENT;

-- -------------------------------------------------------------ALTERNATE WAY FOR ABOVE QUERY ----------------------------------------------------------------------------
SELECT DEPARTMENT , CONCAT(ROUND((AVG(CASE WHEN ATTRITION = 'Yes' THEN 1 ELSE 0 END ) * 100 ),2),'%') AS AVG_ATT_RATE 
FROM HR_COMBINED
GROUP BY DEPARTMENT;

-- -------------------------------------------------------------HOURLY RATE VIA JOB ROLE ---------------------------------------------------------------------------------

SELECT job_role,  hourly_rate FROM HR_COMBINED
order by hourly_rate desc; 

-- -------------------------------------------------------------average hourly rate of male research scientist ---------------------------------------------------------

select job_role ,concat(round(avg(hourly_rate),2),' %') as avg_hourly_rate from hr_combined 
where gender = 'Male' and job_role = 'Research Scientist';

-- ------------------------------------------------------------AVERAGE WORKING YEARS BY DEPARTMENT -------------------------------------------------------------------------

SELECT DEPARTMENT, ROUND(AVG(TOTAL_WORKING_YEARS),2) AS AVG_WORKING_YEARS FROM HR_COMBINED 
GROUP BY DEPARTMENT;

-- ----------------------------------------------------------JOB ROLE VS WORK LIFE BALANCE ------------------------------------------------------------------------------

SELECT JOB_ROLE ,
concat(round(((sum(case when WORK_LIFE_BALANCE = 1 then 1 else 0 end)) * 100) / count(*),2),'%') as  'Bad WLB',
concat(round(((sum(case when WORK_LIFE_BALANCE = 2 then 1 else 0 end)) * 100) / count(*),2),'%') as 'Average WLB',
concat(round(((sum(case when WORK_LIFE_BALANCE = 3 then 1 else 0 end)) * 100) / count(*),2),'%') as  'Good WLB',
concat(round(((sum(case when WORK_LIFE_BALANCE = 4 then 1 else 0 end)) * 100) / count(*),2),'%') as 'Excellent WLB'
FROM HR_COMBINED 
group by job_role;

-- -----------------------------------------------
select job_role , avg(work_life_balance) from hr_combined
group by job_role;

-- -----------------------------------------------------------over time vs work_life balance ---------------------------------------------------------------------------

select job_role , sum(case when over_time = 'Yes' then 1 else 0 end ) as over_time from hr_combined
group by job_role;

-- ------------------------------------------------
SELECT Over_Time, AVG(Work_Life_Balance) AS AvgWLB
FROM hr_combined
GROUP BY Over_Time;

-- ------------------------------------------------------GENDER WISE WORK LIFE BALANCE ----------------------------------------------------------------------------------
SELECT Gender,
concat(round(((sum(case when WORK_LIFE_BALANCE = 1 then 1 else 0 end)) * 100) / count(*),2),'%') as  'Bad WLB',
concat(round(((sum(case when WORK_LIFE_BALANCE = 2 then 1 else 0 end)) * 100) / count(*),2),'%') as 'Average WLB',
concat(round(((sum(case when WORK_LIFE_BALANCE = 3 then 1 else 0 end)) * 100) / count(*),2),'%') as  'Good WLB',
concat(round(((sum(case when WORK_LIFE_BALANCE = 4 then 1 else 0 end)) * 100) / count(*),2),'%') as 'Excellent WLB'
FROM HR_COMBINED 
group by Gender;

-- -----------------------------------------------------YEAR SINCE LAST PROMOTION , PERFOMANCE RATING --------------------------------------------------------------------

SELECT  YEARS_SINCE_LAST_PROMOTION ,
SUM(CASE WHEN PERFORMANCE_RATING = 1 THEN 1 ELSE 0 END ) AS 'LOW ',
SUM(CASE WHEN PERFORMANCE_RATING = 2 THEN 1 ELSE 0 END ) AS 'BELOW_AVERAGE',
SUM(CASE WHEN PERFORMANCE_RATING = 3 THEN 1 ELSE 0 END ) AS 'GOOD',
SUM(CASE WHEN PERFORMANCE_RATING = 4 THEN 1 ELSE 0 END ) AS 'EXCELLENT '
FROM HR_COMBINED 
GROUP BY YEARS_SINCE_LAST_PROMOTION
ORDER BY YEARS_SINCE_LAST_PROMOTION;

-- ----------------------------------------------------------------------------------

SELECT Years_Since_Last_Promotion, ROUND(AVG(Performance_Rating),3) AS AvgPerformance
FROM hr_COMBINED
GROUP BY Years_Since_Last_Promotion
ORDER BY Years_Since_Last_Promotion;

-- --------------------------------------------------ATTRITION RATE VS YEARS SINCE LAST PROMOTION ------------------------------------------------------------------------

SELECT YEARS_SINCE_LAST_PROMOTION , round((((sum(CASE WHEN ATTRITION = 'Yes' then 1 else 0 end))*100)/count(*)),2) as attrition_rate 
from hr_combined
group by years_since_last_promotion
order by years_since_last_promotion;

-- -----------------------------------------------------ATTRITION RATE VS BUSINESS TRAVEL ---------------------------------------------------------------------------------------

SELECT BUSINESS_TRAVEL , round((((sum(CASE WHEN ATTRITION = 'Yes' then 1 else 0 end))*100)/count(*)),2) as attrition_rate 
from hr_combined
group by BUSINESS_TRAVEL
order by BUSINESS_TRAVEL; 

-- -------------------------------------------------------ATTRITION RATE VS DISTANCE FROM HOME ------------------------------------------------------------------------
SELECT DISTANCE_FROM_HOME , round((((sum(CASE WHEN ATTRITION = 'Yes' then 1 else 0 end))*100)/count(*)),2) as attrition_rate 
from hr_combined
group by  DISTANCE_FROM_HOME
order by  DISTANCE_FROM_HOME; 

--                                                           ATTRITION RATE VS GENDER ----------------------------------------------------------------------------------
SELECT GENDER, round((((sum(CASE WHEN ATTRITION = 'Yes' then 1 else 0 end))*100)/count(*)),2) as attrition_rate 
from hr_combined
group by   GENDER
order by  GENDER; 


SELECT MONTHLY_INCOME FROM HR_COMBINED
WHERE MONTHLY_INCOME < (SELECT MAX(MONTHLY_INCOME) FROM HR_COMBINED)
LIMIT 1;









