USE `employees`
;

/* 1. For the current maximum annual wage in the company SHOW the full name of the employee, department, current position, 
for how long the current position is held, and total years of service in the company */
SELECT t1.salary, 
       t2.first_name, 
       t2.last_name,
       t4.dept_name,
       t5.title,
       t6.total_years_of_service,
       t7.duration_of_current_position
FROM (SELECT emp_no, salary
		FROM `employees`.`salaries`
       WHERE to_date > CURDATE()
    ORDER BY salary DESC
       LIMIT 1)                       AS t1 -- finding the maximum annual wage and emp_no for further JOINs
INNER JOIN `employees`.`employees`    AS t2 -- finding the first and last name of emp_no
        ON t1.emp_no = t2.emp_no
INNER JOIN `employees`.`dept_emp`     AS t3 -- finding the current dept_no, where employee works (and dept_no will help in further JOINs)
        ON t1.emp_no = t3.emp_no 
	   AND t3.to_date > CURDATE()
INNER JOIN `employees`.`departments`  AS t4 -- finding the current dept_name of dept_no
        ON t3.dept_no = t4.dept_no
INNER JOIN `employees`.`titles`       AS t5 -- finding the current position of employee
        ON t1.emp_no = t5.emp_no 
	   AND t5.to_date > CURDATE()
INNER JOIN (SELECT emp_no,
				   TIMESTAMPDIFF(YEAR, hire_date, CURDATE()) AS total_years_of_service -- !можна було задати TIMESTAMPDIFF в SELECT і обмежитись додаткового JOINa і вкладеного запиту
			 FROM `employees`.`employees`)                   AS t6 
ON t1.emp_no = t6.emp_no
INNER JOIN (SELECT emp_no, to_date,
                   TIMESTAMPDIFF(YEAR, from_date, CURDATE()) AS duration_of_current_position -- !можна було задати TIMESTAMPDIFF в SELECT і обмежитись додаткового JOINa і вкладеного запиту
              FROM `employees`.`titles`)                     AS t7
 ON t1.emp_no = t7.emp_no 
AND t7.to_date > CURDATE()
;

-- 2. For each department, show its name and current manager’s name, last name, and current salary
SELECT t1.dept_name,
       t3.first_name,
       t3.last_name,
       t4.salary
 FROM `employees`.`departments`         AS t1 -- name of departments and dept_no for further JOIN
LEFT JOIN `employees`.`dept_manager`    AS t2 -- current manager’s emp_no for further identification their first and last names and salaries
		ON (t1.dept_no = t2.dept_no 
	   AND t2.to_date > CURDATE())
INNER JOIN `employees`.`employees`      AS t3 -- manager's first and last names
	    ON t2.emp_no = t3.emp_no
INNER JOIN `employees`.`salaries`       AS t4 -- manager`s current salary
		ON (t3.emp_no = t4.emp_no   
	   AND t4.to_date > CURDATE()) 
;  
 
-- 3. Show for each employee, their current salary and their current manager’s current salary
SELECT t1.emp_no AS emp_employee_no,          
       t1.salary AS employee_current_salary,
       t3.emp_no AS emp_manager_no,
       t4.salary AS emp_manager_current_salary
 FROM `employees`.`salaries`            AS t1 -- employees`s current salary
INNER JOIN `employees`.`dept_emp`       AS t2 -- departments where the employees and managers work
        ON t1.emp_no = t2.emp_no  
	   AND t1.to_date > CURDATE()   	      -- ? Чи краще вказати t1.to_date > CURDATE() в умові WHERE після всіх JOINIв?
LEFT JOIN `employees`.`dept_manager`    AS t3 -- department`s current manager
        ON (t2.dept_no = t3.dept_no 
	   AND t3.to_date > CURDATE())    
INNER JOIN `employees`.`salaries`       AS t4 -- managers`s current salary
        ON (t3.emp_no = t4.emp_no   
	   AND t4.to_date > CURDATE())
;


-- 4. Show all employees that currently earn more than their managers
SELECT t1.emp_no AS `emp_employee_no`,          
       t1.salary AS `employee_current_salary`,        
       t3.emp_no AS `emp_manager_no`,
       t4.salary AS `emp_manager_current_salary`
 FROM `employees`.`salaries`                AS t1 -- employees`s current salary
INNER JOIN `employees`.`dept_emp`           AS t2 -- departments where the employees and managers work
        ON t1.emp_no = t2.emp_no  
LEFT JOIN `employees`.`dept_manager`        AS t3 -- department`s current manager
        ON (t2.dept_no = t3.dept_no AND t3.to_date > CURDATE())    
INNER JOIN `employees`.`salaries`           AS t4 -- managers`s current salary
        ON (t3.emp_no = t4.emp_no   AND t4.to_date > CURDATE())
/* difference between employees`s current salary and managers`s current salary 
(a positive value indicates that the employee earns more than the manager) */
WHERE (t1.to_date > CURDATE()                     -- ? Чи краще вказати AND t1.to_date > CURDATE() після першого запису JOINа?
  AND (t1.salary - t4.salary) > 0) 
;

-- 5. Show how many employees currently hold each title, sorted in descending order by the number of employees.
   SELECT title,
          COUNT(title)    AS QTY_employees
    FROM `employees`.`titles`
    WHERE to_date > CURDATE()
 GROUP BY title
 ORDER BY COUNT(title) DESC
;

-- 6. Show full name of the all employees who were employed in more than one department
SELECT t2.first_name,
	   t2.last_name
FROM (SELECT emp_no
	   FROM `employees`.`dept_emp` 
	GROUP BY emp_no
	  HAVING COUNT(emp_no) > 1)   AS t1 -- all emp_no who were employed in more than one department
LEFT JOIN `employees`.`employees` AS t2 -- idendification first and last name of emp_no
       ON t1.emp_no = t2.emp_no
;

-- 7. Show the average salary and maximum salary in thousands of dollars for every year
SELECT YEAR(from_date)            AS `Year`,
       ROUND(AVG(salary)/1000,2)  AS `Average_salary`,
       ROUND(MAX(salary)/1000,2)  AS `Maximum_salary`
 FROM `employees`.`salaries`
GROUP BY YEAR(from_date)
;

-- 8. Show how many employees were hired on weekends (Saturday + Sunday), split by gender
  SELECT gender,
         COUNT(gender)      AS `QTY_employees_hired_on_weekends`
   FROM `employees`.`employees`
   WHERE DAYNAME(hire_date) IN('Saturday', 'Sunday')
GROUP BY gender
;

-- 9. Fulfill the script below to achieve the following data:
/* Group all employees according to their age at January 1st, 1995 into four groups:
30 or younger, 31-40, 41-50 and older. Show average salary for each group and gender
(8 categories in total) Also add subtotals and grand total */
SELECT gender,
       AVG(salary),
       CASE WHEN TIMESTAMPDIFF(YEAR, birth_date, '1995-01-01') <= 30             THEN 'YoungerThen30'
		    WHEN TIMESTAMPDIFF(YEAR, birth_date, '1995-01-01') BETWEEN 31 AND 40 THEN 'Between31and40' 
			WHEN TIMESTAMPDIFF(YEAR, birth_date, '1995-01-01') BETWEEN 41 AND 50 THEN 'Between41and50'
            WHEN TIMESTAMPDIFF(YEAR, birth_date, '1995-01-01') >= 50             THEN 'OlderThen50'
	   END AS `category`
FROM       employees      AS e
INNER JOIN salaries       AS s 
        ON s.emp_no = e.emp_no
WHERE e.hire_date < '19950101'        -- filter out those employees, who were not employed at that date yet.
  AND (SELECT MAX(to_date) 
		 FROM dept_emp    AS de 
		WHERE de.emp_no = e.emp_no
	 GROUP BY de.emp_no) > '19950101' -- this subquery filters out employees, who already left the company by that date 
GROUP BY gender,
         `category`
WITH ROLLUP 
ORDER BY e.gender
;

-- the code below eliminates 'NULL' 
SELECT AVG(salary),
       CASE GROUPING 
            (CASE WHEN TIMESTAMPDIFF(YEAR, birth_date, '1995-01-01') <= 30             THEN 'YoungerThen30'
			      WHEN TIMESTAMPDIFF(YEAR, birth_date, '1995-01-01') BETWEEN 31 AND 40 THEN 'Between31and40' 
                  WHEN TIMESTAMPDIFF(YEAR, birth_date, '1995-01-01') BETWEEN 41 AND 50 THEN 'Between41and50'
                  WHEN TIMESTAMPDIFF(YEAR, birth_date, '1995-01-01') >= 50             THEN 'OlderThen50' END)
	   WHEN 1 THEN 'TOTAL'
       ELSE (CASE WHEN TIMESTAMPDIFF(YEAR, birth_date, '1995-01-01') <= 30             THEN 'YoungerThen30'
			      WHEN TIMESTAMPDIFF(YEAR, birth_date, '1995-01-01') BETWEEN 31 AND 40 THEN 'Between31and40' 
                  WHEN TIMESTAMPDIFF(YEAR, birth_date, '1995-01-01') BETWEEN 41 AND 50 THEN 'Between41and50'
                  WHEN TIMESTAMPDIFF(YEAR, birth_date, '1995-01-01') >= 50             THEN 'OlderThen50' END)
	   END AS `category`,
	   CASE 
	   GROUPING (e.gender) WHEN 1 THEN 'TOTAL'
           ELSE e.gender END gender
FROM       employees      AS e
INNER JOIN salaries       AS s 
        ON s.emp_no = e.emp_no
WHERE e.hire_date < '19950101'        -- filter out those employees, who were not employed at that date yet.
  AND (SELECT MAX(to_date) 
		 FROM dept_emp    AS de 
		WHERE de.emp_no = e.emp_no
	 GROUP BY de.emp_no) > '19950101' -- this subquery filters out employees, who already left the company by that date 
 GROUP BY e.gender,
          CASE  WHEN TIMESTAMPDIFF(YEAR, birth_date, '1995-01-01') <= 30 THEN 'YoungerThen30'
			    WHEN TIMESTAMPDIFF(YEAR, birth_date, '1995-01-01') between 31 and 40 THEN 'Between31and40' 
                WHEN TIMESTAMPDIFF(YEAR, birth_date, '1995-01-01') between 41 and 50 THEN 'Between41and50'
                WHEN TIMESTAMPDIFF(YEAR, birth_date, '1995-01-01') >= 50 THEN 'OlderThen50' END
 WITH ROLLUP 
    ORDER BY e.gender
;