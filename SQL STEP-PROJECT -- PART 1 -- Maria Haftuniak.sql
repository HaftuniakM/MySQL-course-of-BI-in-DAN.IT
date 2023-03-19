-- Запросы:
USE `employees`;
/* 1. Покажите среднюю зарплату сотрудников за каждый год (средняя заработная плата среди тех, кто работал в отчетный период - 
статистика с начала до 2005 года).*/
SELECT YEAR(s.to_date)         AS `Year`,
	   ROUND(AVG(s.salary), 2) AS `AVG_salary`
 FROM `salaries`               AS s
GROUP BY YEAR(s.to_date)
  HAVING `Year` < '2005'
ORDER BY `Year` ASC
;

/*2. Покажите среднюю зарплату сотрудников по каждому отделу. 
Примечание: принять в расчет только текущие отделы и текущую заработную плату. */

SELECT d.dept_name             AS `Name_of_department`,       
       ROUND(AVG(s.salary), 2) AS `AVG_current_salary`
 FROM `salaries`               AS s
INNER JOIN `dept_emp`          AS de ON (s.emp_no = de.emp_no 
									AND de.to_date > CURDATE())
INNER JOIN `departments` AS d ON (de.dept_no = d.dept_no)
WHERE s.to_date > CURDATE()
GROUP BY d.dept_name
;

/*3.Покажите среднюю зарплату сотрудников по каждому отделу за каждый год. 
Примечание: для средней зарплаты отдела X в году Y нам нужно взять среднее значение всех зарплат в году Y сотрудников, 
которые были в отделе X в году Y. */

-- Належність працівника до департаменту визначалась на момент початку періоду виплати з/п
SELECT d.dept_name            AS `Name_of_department`,
       YEAR(s.from_date)      AS `Year`,
	   ROUND(AVG(s.salary),2) AS `AVG_salary`
     FROM `salaries`     AS s
INNER JOIN `dept_emp`    AS de ON (s.emp_no = de.emp_no)
INNER JOIN `departments` AS d  ON (de.dept_no = d.dept_no)
WHERE s.from_date = de.from_date 
GROUP BY `Year`, `Name_of_department`
ORDER BY `Year` ASC
;

-- 4. Покажите для каждого года самый крупный отдел (по количеству сотрудников) в этом году и его среднюю зарплату.

WITH a1 AS 
(SELECT YEAR(s.from_date)      AS `Year`,
	    ROUND(AVG(s.salary),2) AS `AVG_salary`,
        COUNT(de.emp_no)       AS `QTY`,
        de.dept_no
FROM `salaries`       AS s
INNER JOIN `dept_emp` AS de ON (s.emp_no = de.emp_no)
WHERE YEAR(s.from_date) = YEAR(de.from_date)
GROUP BY YEAR(s.from_date), de.dept_no)
  SELECT a1.`Year`,
		 d.dept_name  AS `department`,
		 a1.AVG_salary
	FROM a1
    INNER JOIN `departments` AS d ON (a1.dept_no = d.dept_no)
    WHERE a1.`QTY` = (SELECT MAX(t2.`QTY`) AS `max_emp_count`
				        FROM (SELECT * 
                                FROM a1) AS t2
							   WHERE a1.`Year` = t2.`Year`)
	ORDER BY a1.`Year`
    ;

-- 5. Покажите подробную информацию о менеджере, который дольше всех исполняет свои обязанности на данный момент.
-- Виведення детальної інформації по працівнику, який займає посаду Менеджера триваліше інших
SELECT CONCAT(e.first_name, ' ', e.last_name) AS `full_name`, e.emp_no, e.gender, e.birth_date, e.hire_date,
       s.salary    AS `current_salary`,
       d.dept_name AS `department`,
       t1.dept_no, t1.from_date, t1.to_date, t1.`Duration_years`
 FROM (SELECT dm.*,
			  TIMESTAMPDIFF(YEAR,  dm.from_date, CURDATE())  AS `Duration_years`
	    FROM `dept_manager` AS dm
        WHERE dm.to_date > CURDATE()                         -- поточна посада 'Менеджер'
    ORDER BY `Duration_years` DESC
       LIMIT 1)             AS t1
INNER JOIN `employees`      AS e  ON (t1.emp_no =  e.emp_no)
INNER JOIN `dept_emp`       AS de ON (t1.emp_no = de.emp_no
							     AND de.to_date > CURDATE()) -- поточний департамент
INNER JOIN `departments`    AS d  ON (de.dept_no = d.dept_no)
INNER JOIN `salaries`       AS s  ON (t1.emp_no = s.emp_no
                                 AND s.to_date > CURDATE())  -- поточна зарплата
;

-- 6. Покажите топ-10 нынешних сотрудников компании с наибольшей разницей между их зарплатой и текущей средней зарплатой в их отделе.
WITH t1 AS -- поточна середня зарплата по департаментам
(SELECT de.dept_no,     
       AVG(s.salary)   AS `AVG_dept_current_salary`
      FROM `salaries`  AS s
INNER JOIN `dept_emp`  AS de ON (s.emp_no = de.emp_no 
						    AND de.to_date > CURDATE())
   WHERE s.to_date > CURDATE()
GROUP BY de.dept_no)
SELECT s.emp_no,
	   CONCAT(e.first_name, ' ', e.last_name)     AS `full_name`,
       s.salary                                   AS `current_salary`, 
       t2.AVG_dept_current_salary,
       ABS(s.salary - t2.AVG_dept_current_salary) AS `difference` -- застосовано функцію ABS, так як в умові завдання неуточнено якою є різниця (позитивною, чи негативною)
 FROM `salaries`       AS s
INNER JOIN `dept_emp`  AS de ON (s.emp_no = de.emp_no 
						    AND de.to_date > CURDATE())  -- поточний відділ працівника
INNER JOIN         t1  AS t2 ON (t2.dept_no = de.dept_no)
INNER JOIN `employees` AS e  ON (s.emp_no = e.emp_no)
WHERE s.to_date > CURDATE()                              -- поточна з/п працівника
ORDER BY `difference` DESC
LIMIT 10
;

/*7.Из-за кризиса на одно подразделение на своевременную выплату зарплаты выделяется всего 500 тысяч долларов. 
Правление решило, что низкооплачиваемые сотрудники будут первыми получать зарплату. 
Показать список всех сотрудников, которые будут вовремя получать зарплату 
обратите внимание, что мы должны платить зарплату за один месяц, но в базе данных мы храним годовые суммы). */

SELECT t1.emp_no,
       CONCAT(e.first_name, ' ', e.last_name) AS `full_name`,
	   d.dept_name,
       t1.dept_no,
       t1.salary_month,
       t1.sum_increasing
FROM (SELECT s.emp_no,
			 s.salary/12 AS `salary_month`,
             de.dept_no,
             SUM(s.salary/12)OVER(PARTITION BY de.dept_no ORDER BY(s.salary/12) ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS `sum_increasing`
       FROM `salaries`   AS s
 INNER JOIN `dept_emp`   AS de ON (s.emp_no = de.emp_no
                              AND de.to_date > CURDATE())
WHERE s.to_date > CURDATE()) t1
INNER JOIN `employees`   AS e  ON (t1.emp_no = e.emp_no)
INNER JOIN `departments` AS d  ON (t1.dept_no = d.dept_no)
WHERE t1.sum_increasing < 500000
;