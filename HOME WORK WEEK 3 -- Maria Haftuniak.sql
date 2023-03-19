USE `employees`
;

/* 1. For the current maximum annual wage in the company 
SHOW the full name of an employee, department, current position, for how long the current position is held, 
and total years of service in the company.
USE common table expression this time */

WITH fname AS
(SELECT e.emp_no, 
        e.hire_date,
        CONCAT(e.first_name,' ',e.last_name) AS `full_name`
  FROM `employees`.`employees`               AS  e),
cur_title AS
(SELECT et.title,
		et.emp_no,
        et.from_date
  FROM `employees`.`titles` AS et
  WHERE to_date > CURDATE())
SELECT f.full_name,
       ct.title,
       ed.dept_name,
       s1.salary,
       TIMESTAMPDIFF(YEAR, f.hire_date, CURDATE())  AS `total_years_of_service`,
       TIMESTAMPDIFF(YEAR, ct.from_date, CURDATE()) AS `duration_of_current_position`
  FROM fname                                        AS f
INNER JOIN cur_title                                AS ct ON f.emp_no = ct.emp_no
INNER JOIN (SELECT d.emp_no,
				   d.dept_no
              FROM `employees`.`dept_emp`           AS d
              WHERE to_date > CURDATE())            AS d1 ON f.emp_no = d1.emp_no
INNER JOIN `employees`.`departments`                AS ed ON d1.dept_no = ed.dept_no 
INNER JOIN (SELECT s.emp_no,
                   s.salary
              FROM `employees`.`salaries`           AS s
              ORDER BY s.salary DESC
				 LIMIT 1)                           AS s1 ON f.emp_no = s1.emp_no
;

-- 2. From MySQL documentation check how ABS() function works. https://dev.mysql.com/doc/refman/8.0/en/mathematical-functions.html#function_abs
-- I have checked how ABS() function works. It's good to use when there is a need to know difference between numbers and doesn't matter the difference is - or +

/* 3. Show all information about the employee, salary year, and the difference between salary and average salary in the company overall. 
For the employee, whose salary was assigned latest from salaries that are closest to mean salary overall (doesn’t matter higher or lower). 
Here you need to find the average salary overall and then find the smallest difference of someone’s salary with an average salary */
	SELECT YEAR(from_date)                     AS `salary_year`,
		   s.salary,
           ABS(s.salary - AVG(s.salary)OVER()) AS `avg_difference`
     FROM `employees`.`salaries`               AS s
 ORDER BY `salary_year`    DESC /*salary year was assigned latest from salaries that are closest to mean salary overall*/, 
          `avg_difference` ASC  /*the smallest difference of salary with an average salary */
    LIMIT 1;

-- 4. Select the details, title, and salary of the employee with the highest salary who is not employed in the company anymore.
WITH copy_salaries AS -- I decided to create the cte as I have used the salaries table more than once
(SELECT *
   FROM `employees`.`salaries`)
SELECT CONCAT(e.last_name, ' ', e.first_name) AS `full_name`,
       s.salary,
       t.title
 FROM `employees`.`employees`     AS e
INNER JOIN copy_salaries          AS s ON e.emp_no = s.emp_no
								      AND s.salary = (SELECT MAX(s1.salary)
												        FROM copy_salaries s1
												       WHERE s1.emp_no NOT IN (-- exclude employees who work
																			   SELECT s2.emp_no
																			     FROM copy_salaries AS s2
																		        WHERE s2.to_date > CURDATE()))
LEFT JOIN `employees`.`titles`    AS t ON s.emp_no = t.emp_no
                                      AND (SELECT ROW_NUMBER() OVER (ORDER BY t.from_date DESC) AS w0) -- for example - if someone wants to know the latest title
LIMIT 1
;

/* 5. Show Full Name, salary, and year of the salary for top 5 employees that have the highest one-time raise in salary (in absolute numbers). 
Also, attach the top 5 employees that have the highest one-time raise in salary (in percent).  
One-time rise here means the biggest difference between the two consecutive years */

SELECT fn.full_name,
	   g3.salary,
       g3.salary_year,
       g3.difference
-- Absolute difference (top 5 employees with the highest one-time raise in salary)
 FROM (SELECT *
		 FROM (SELECT s.emp_no,
			          s.salary,
			          YEAR(s.from_date)     AS `salary_year`,
					  LEAD(s.salary)OVER(PARTITION BY s.emp_no ORDER BY s.from_date) - s.salary    AS `difference`
                FROM `employees`.`salaries` AS s
             ORDER BY difference DESC
                LIMIT 5) AS g1
UNION ALL 
-- Percent difference (top 5 employees with the highest one-time raise in salary)
SELECT g2.*
  FROM (SELECT s.emp_no,
               s.salary,
			   YEAR(s.from_date)     AS `salary_year`,
			 ((LEAD(s.salary)OVER(PARTITION BY s.emp_no ORDER BY s.from_date))/s.salary)*100 - 100 AS `difference_percent`
		 FROM `employees`.`salaries` AS s
	  ORDER BY difference_percent DESC
		 LIMIT 5) AS g2) AS g3
INNER JOIN (SELECT e.emp_no,
                   CONCAT(e.first_name,' ',e.last_name) AS `full_name`
			 FROM `employees`.`employees`               AS  e) AS fn ON g3.emp_no = fn.emp_no
;

-- 6. Generate a sequence of square numbers till 9 (1^2, 2^2... 9^2)
WITH RECURSIVE cte AS
(SELECT 1 AS N
  UNION ALL
 SELECT n + 1 FROM cte WHERE n < 9)
 SELECT POWER(c.n,2) AS Sequence_of_square_numbers
   FROM cte AS c;