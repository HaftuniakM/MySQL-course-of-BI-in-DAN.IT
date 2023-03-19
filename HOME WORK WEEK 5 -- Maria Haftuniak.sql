USE `employees`;

-- 1. Отобразить информацию из таблицы сотрудников и через подзапрос добавить его текущую должность.
SELECT e.*,
       s.title
 FROM `employees`             AS e
INNER JOIN (-- Список поточних посад працівників
            SELECT t.emp_no,
				   t.title
			 FROM `titles`    AS t
             WHERE t.to_date > CURDATE()) AS s ON (e.emp_no = s.emp_no)
;
 
-- 2. Отобразить информацию из таблицы сотрудников, которые (exists) в прошлом были с должностью 'Engineer'.
SELECT e.*
  FROM `employees`           AS e
 WHERE EXISTS (-- Список працівників, які в минулому були на посаді 'Engineer'
               SELECT t.emp_no,
				      t.title
			    FROM `titles` AS t
                WHERE t.to_date < CURDATE()
                  AND title = 'Engineer'
			      AND e.emp_no = t.emp_no) -- кореляція запиту
;
  
-- 3. Отобразить информацию из таблицы сотрудников, у которых (in) актуальная зарплата от 50 тысяч до 75 тысяч.
SELECT e.*
  FROM `employees`                     AS e
  WHERE e.emp_no IN (-- Список працівників, актуальна зарплата / останнє нарахування яких в діапазоні від 50000 до 75000
					 SELECT s.emp_no
				      FROM `salaries`  AS s
				      WHERE s.to_date > CURDATE()
                        AND s.salary BETWEEN 50000 AND 75000)
;

-- 4. Создать копию таблицы employees с помощью этого SQL скрипта: create table employees_dub as select * from employees;
CREATE TABLE `employees_dub` AS 
      SELECT * 
        FROM `employees`
;
      
-- 5. Из таблицы employees_dub удалить сотрудников которые были наняты в 1985 году.
DELETE FROM `employees_dub` 
      WHERE hire_date BETWEEN '19850101' AND '19851231'
;
	
-- 6. В таблице employees_dub сотруднику под номером 10008 изменить дату приема на работу на ‘1994-09-01’. -- '1994-09-15'
UPDATE `employees_dub` 
   SET hire_date = '19940901' 
 WHERE emp_no = 10008
;

-- 7. В таблицу employees_dub добавить двух произвольных сотрудников.
INSERT INTO `employees_dub` (emp_no, birth_date, first_name, last_name, gender, hire_date) -- назви стопців можна не прописувати
VALUES (112359, '19970209', 'Sofia', 'First',  'F', '20221126'),
	   (112360, '19970309', 'Sofia', 'Second', 'F', '20221127')
;
	