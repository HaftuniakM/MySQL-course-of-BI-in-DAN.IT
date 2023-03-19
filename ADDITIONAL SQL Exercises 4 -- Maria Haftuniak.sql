-- ADDITIONAL SQL Exercises (WINDOW FUNCTIONS) 4
USE `employees`;

-- 1. Отобразить сотрудников и напротив каждого, показать информацию о разнице текущей и первой зарплате.
SELECT sub.emp_no,
	   CONCAT(e.first_name, ' ', e.last_name) AS `full_name`,
       sub.salary_difference
FROM (SELECT s.emp_no, s.to_date,
             LAST_VALUE(s.salary)OVER(PARTITION BY s.emp_no ORDER BY s.salary ASC ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) - FIRST_VALUE(s.salary)OVER(PARTITION BY s.emp_no ORDER BY s.salary ASC) AS `salary_difference`
		FROM `salaries` AS s) AS sub
JOIN `employees` AS e ON (e.emp_no = sub.emp_no)
WHERE sub.to_date > CURDATE()
;

-- 2. Отобразить департаменты и сотрудников, которые получают наивысшую зарплату в своем департаменте.

SELECT t2.emp_no, t2.`full_name`, t2.dept_name, t2.`max_salary_in_the_dept`
FROM (SELECT t1.*,
	         MAX(t1.salary)OVER(PARTITION BY t1.dept_name) AS `max_salary_in_the_dept`
FROM (SELECT e.emp_no,
             CONCAT(e.first_name, ' ', e.last_name)  AS `full_name`,
	         dn.dept_name, 
	         s.salary
        FROM `salaries`    AS s
		JOIN `employees`   AS e  ON (e.emp_no = s.emp_no)
		JOIN `dept_emp`    AS d  ON (d.emp_no = s.emp_no)
		JOIN `departments` AS dn ON (d.dept_no = dn.dept_no)
       WHERE s.to_date > CURDATE()) AS t1) AS t2
WHERE t2.salary = t2.`max_salary_in_the_dept`
;

-- 3. Из таблицы должностей, отобразить сотрудника с его текущей должностью и предыдущей.
 /*HINT OVER(PARTITION BY ... ORDER BY ... ROWS 1 preceding)*/
 
-- Бізнес-логіка запиту - вибірка посад працівників, які займали більше однієї посади і досі працюють в компанії
WITH `preparat_table` AS
(SELECT *,
		ROW_NUMBER() OVER(PARTITION BY emp_no ORDER BY to_date ROWS 1 PRECEDING) AS r
   FROM `titles`)
SELECT *
  FROM `preparat_table`
 WHERE emp_no IN (SELECT emp_no           -- вибірка посад працівників, які займали більше однієї посади
                    FROM `preparat_table`
                   WHERE r > 1)
   AND emp_no IN (SELECT emp_no           -- вибірка посад працівників, які досі працюють в компанії
                    FROM `titles`
                   WHERE to_date > CURDATE())
;

 -- 4. Из таблицы должностей, посчитать интервал в днях - сколько прошло времени от первой должности до текущей.
 
-- Бізнес-логіка запиту - вибірка ідентифікаторів працівників та інтервал у днях (з часу першої посади до поточної (тобто до сьоголднішнього дня)), 
					   -- вибірка працівників, які займали більше однієї посади і досі працюють в компанії 
WITH `preparat_table` AS
(SELECT *,
		ROW_NUMBER()OVER(PARTITION BY emp_no ORDER BY to_date ROWS 1 PRECEDING) AS `range_position`
   FROM `titles`)
SELECT emp_no,
	   TIMESTAMPDIFF(DAY, from_date, CURDATE()) AS `days_interval` -- кількість днів від першої посади до поточної (тобто до сьогоднішнього дня)
  FROM `preparat_table`
 WHERE emp_no IN (SELECT emp_no                                    -- вибірка посад працівників, які займали більше однієї посади
					FROM `preparat_table`
				   WHERE `range_position` > 1)
   AND emp_no IN (SELECT emp_no                                    -- вибірка посад працівників, які досі працюють в компанії
					FROM `titles`
				   WHERE to_date > CURDATE())
   AND `range_position` = 1                                        -- вибірка дати займення першої посади
;

/* 5. Выбрать сотрудников и отобразить их рейтинг по году принятия на работу. Попробуйте разные типы рейтингов. 
 Как вариант можно 
 SELECT с оконными функциями вставить как подзапрос в FROM.
 
 SELECT subq.a-subq.bAS value_diff
   FROM (SELECT a,FIRST_VALUE(col1) OVER(PARTITION BY ... ORDER BY ...) AS b 
           FROM table1) AS subq
 WHERE subq.date > now();
 
 SELECT subq.*, DATEDIFF(subq.c-subq.d) AS date_diff
 FROM (SELECT *,FIRST_VALUE(date_col1) OVER(PARTITION BY ... ORDER BY ...) AS dFROM table1) AS subqWHERE subq.date > now() */

/* Логіка запиту:
   - рік прийнятя на роботу визначається роком з hire_date таблиці employees
   - ROW_NUMBER() - присвоєння значення рейтингу для кожного окремого працівниква
   - DENSE_RANK() - присвоєння значення рейтингу відносно року: кожен рік - це одне значення по рейтингу (1985 - 1, 1986 - 2 і т.д)
*/
SELECT t1.*,
	   ROW_NUMBER()OVER(ORDER BY t1.hire_year ASC) AS `rating_for_each_position`, 
       DENSE_RANK()OVER(ORDER BY t1.hire_year ASC) AS `rating_for_each_year`
FROM (SELECT emp_no,
	         CONCAT(first_name, ' ', last_name)    AS `full_name`,
             YEAR(hire_date)                       AS `hire_year`
        FROM `employees`) AS t1
;