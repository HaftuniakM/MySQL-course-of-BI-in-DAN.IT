-- HOME WORK WEEK 1 -- Haftuniak Maria

-- 1. List all female employees who joined at 01/01/1990 or at 01/01/2000.
SELECT *
FROM `employees`.`employees`
WHERE gender = 'F'
  AND (hire_date = '19900101' OR hire_date = '20000101')
;

-- 2. Show the name of all employees who have an equal first and last name
SELECT first_name, 
         last_name, 
         COUNT(emp_no)
   FROM `employees`.`employees`
GROUP BY first_name,
	     last_name
  HAVING COUNT(emp_no) > 1
;
-- Вам необходимо задействовать компонент where для фильтрации строк. 
-- Таким образом необходимо отобрать только те строки, у которых значения в атрибутах first_name и last_name равны.
  SELECT first_name, 
         last_name
   FROM `employees`.`employees`
WHERE first_name = last_name
;

-- 3. Show employees numbers 10001,10002,10003 and 10004, select columns first_name, last_name, gender, hire_date.
SELECT first_name, 
	   last_name, 
	   gender,
	   hire_date
 FROM `employees`.`employees`
 WHERE emp_no IN(10001, 10002, 10003, 10004)
; -- OR
SELECT first_name, 
	   last_name, 
	   gender,
	   hire_date
 FROM `employees`.`employees`
 WHERE emp_no BETWEEN 10001 AND 10004
;
   
-- 4. Select the names of all departments whose names have ‘a’ character on any position or ‘e’ on the second place.
SELECT DISTINCT dept_name
FROM   `employees`.`departments`
WHERE  (dept_name LIKE '%a%' 
  OR    dept_name LIKE '_e%')
;

-- 5. Show employees who satisfy the following description: He(!) was 45 when hired, born in October and was hired on Sunday. 
SELECT first_name,
	   last_name,
       gender,
       TIMESTAMPDIFF(YEAR, birth_date, hire_date) AS `Age_of_hiring`,
       MONTH  (birth_date)                        AS `Month_of_boring`,
       DAYNAME(hire_date)                         AS `Day_of_hiring`
  FROM `employees`.`employees`
 WHERE gender = 'M'
   AND TIMESTAMPDIFF(YEAR,birth_date, hire_date) = 45
   AND MONTH(birth_date)  = 10
   AND DAYNAME(hire_date) = 'Sunday'
;

-- 6. Show the maximum annual salary in the company after 01/06/1995.
SELECT MAX(salary)
 FROM `employees`.`salaries`
 WHERE from_date > '19950601'
;
-- Для ідентифікації працівника:
SELECT   emp_no, 
         MAX(salary)
FROM    `employees`.`salaries`
WHERE    from_date > '19950601'
GROUP BY emp_no
ORDER BY MAX(salary) DESC
   LIMIT 1
;

/* 7. In the dept_emp table, show the quantity of employees by department (dept_no). 
To_date must be greater than current_date. 
Show departments with more than 13,000 employees. Sort by quantity of employees.
*/
  SELECT dept_no,
         COUNT(dept_no) AS `QTY`
   FROM `employees`.`dept_emp`
   WHERE to_date > CURRENT_DATE()
GROUP BY dept_no
  HAVING `QTY` > 13000
ORDER BY `QTY`ASC
;

-- 8. Show the minimum and maximum salaries by employee
   SELECT emp_no,
          MAX(salary), 
	      MIN(salary)
    FROM `employees`.`salaries`
 GROUP BY emp_no
 ;
 