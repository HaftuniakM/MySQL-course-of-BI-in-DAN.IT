USE `employees`
;

-- 1. Показать для каждого сотрудника его текущую зарплату и текущую зарплату текущего руководителя.
SELECT e.emp_no,
       CONCAT(e.first_name, ' ', e.last_name) AS `employee_full_name`,
	   s.salary                               AS `employee_current_salary`,
       sl.salary                              AS `emp_manager_current_salary`
  FROM `employees`.`employees`         AS e
  LEFT JOIN `employees`.`salaries`     AS s  ON s.emp_no = e.emp_no
										    AND s.to_date > CURDATE()
  LEFT JOIN `employees`.`dept_emp`     AS de ON de.emp_no = e.emp_no 
										    AND de.to_date > CURDATE()
  LEFT JOIN `employees`.`dept_manager` AS dm ON dm.dept_no = de.dept_no
											AND dm.to_date > CURDATE()
  LEFT JOIN `employees`.`salaries`     AS sl ON sl.emp_no = dm.emp_no
										    AND sl.to_date > CURDATE()
;

-- 2. Показать всех сотрудников, которые в настоящее время зарабатывают больше, чем их руководители.
SELECT e.emp_no,
       CONCAT(e.first_name, ' ', e.last_name) AS `employee_full_name`,
	   s.salary                               AS `employee_current_salary`,
       s1.salary                              AS `emp_manager_current_salary`,
       s.salary - s1.salary                   AS `difference`
  FROM `employees`.`employees`         AS e
  LEFT JOIN `employees`.`salaries`     AS s  ON s.emp_no = e.emp_no
										    AND s.to_date > CURDATE()
  LEFT JOIN `employees`.`dept_emp`     AS de ON de.emp_no = e.emp_no 
										    AND de.to_date > CURDATE()
  LEFT JOIN `employees`.`dept_manager` AS dm ON dm.dept_no = de.dept_no
											AND dm.to_date > CURDATE()
  LEFT JOIN `employees`.`salaries`     AS s1 ON s1.emp_no = dm.emp_no
										    AND s1.to_date > CURDATE()
HAVING `difference` > 0
;

/* 3. Из таблицы dept_manager первым запросом выбрать данные по актуальным менеджерам департаментов 
и сделать свой столбец “checks” со значением ‘actual’.
Вторым запросом из этой же таблицы dept_manager выбрать НЕ актуальных менеджеров департаментов 
и  сделать свой столбец “checks” со значением ‘old’.
Объединить результат двух запросов через union.*/

SELECT dm.*,
       REPLACE(dm.to_date, dm.to_date, 'actual') AS `checks`
FROM `employees`.`dept_manager` AS dm
WHERE to_date > CURDATE()
UNION
SELECT dm.*,
       REPLACE(dm.to_date, dm.to_date, 'old')    AS `checks`
FROM `employees`.`dept_manager` AS dm
WHERE to_date < CURDATE()
;

/*4. К результату всех строк таблицы departments, добавить еще две строки со значениями “d010”, “d011” для dept_no 
																					и “Data Base”, “Help Desk” для dept_name.*/
-- По моїй бізнес-логіці: потрібно додати нові рядки до РЕЗУЛЬТАТУ вибірки, а не нові рядки до таблиці з допомогою компанди INSERT INTO
SELECT *
  FROM departments
UNION
SELECT 'd010', 'Data Base'
UNION
SELECT 'd011', 'Help Desk';

-- 5. Найти emp_no актуального менеджера из департамента ‘d003’, далее через подзапрос из таблицы сотрудников вывести по нему информацию.
SELECT e.*
 FROM `employees`.`employees`                     AS e
 WHERE emp_no = (SELECT dm.emp_no
				  FROM `employees`.`dept_manager` AS dm
                  WHERE dm.to_date > CURDATE() 
				    AND dm.dept_no = 'd003');
;

-- 6. Найти максимальную дату приема на работу, далее через подзапрос из таблицы сотрудников вывести по этой дате информацию по сотрудникам.
SELECT e1.*
 FROM `employees`.`employees`                       AS e1
 WHERE hire_date IN (SELECT MAX(hire_date)
					   FROM `employees`.`employees` AS e2)
;