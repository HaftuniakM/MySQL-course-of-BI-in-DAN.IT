-- ADDITIONAL SQL Exercises 3

-- 1. В схеме employees, в таблице employees добавить новый столбец - lang_no (int).
USE `employees`;

ALTER TABLE `employees`
 ADD COLUMN `lang_no` INT
;

/* 2. Обновить столбец lang_no значением "1" для всех у кого год прихода на работу 1985 и 1988. 
Остальным значение сотрудникам обновить значение "2". */

UPDATE `employees` 
SET `lang_no` =  
CASE WHEN YEAR(hire_date) = '1985' THEN 1
	 WHEN YEAR(hire_date) = '1988' THEN 1
								ELSE 2 
END
;

-- При виконні запиту отримано помилку:
/*Error Code: 1175. You are using safe update mode and you tried to update a table without a WHERE that uses a KEY column.  
To disable safe mode, toggle the option in Preferences -> SQL Editor and reconnect.*/

-- За допомогою коду нижче, зняла обмеження на оновлення і виконала запит повторно
SET SQL_SAFE_UPDATES = 0;
-- 2 варіант вирішення проблеми: зняти помітку біля Safe Updates (rejects UPDATEs and DELETEs with no restrictions) в Edit -> Preferences -> SQL Editor

-- 3. В схеме tempdb, создать новую таблицу language с двумя полями lang_no (int) и lang_name (varchar(3)).
USE `tempdb`;

CREATE TABLE IF NOT EXISTS `language` (
`lang_no`   INT,
`lang_name` VARCHAR(3)
);

-- 4. Добавить в таблицу tempdb.language две строки: 1 - ukr, 2 - rus.

INSERT INTO `language` (`lang_no`, `lang_name`)
VALUES (1, 'ukr'),
	   (2, 'rus')
;

/* 5. Связать таблицы из схемы employees и tempdb чтобы показать всю информацию из таблицы employees 
и один столбец lang_name из таблицы language (столбцы lang_no не отображать).*/

SELECT e.emp_no, e.birth_date, e.first_name, e.last_name, e.gender, e.hire_date, l.lang_name
FROM `employees`.`employees`  AS e
LEFT JOIN `tempdb`.`language` AS l ON e.lang_no = l.lang_no
;

-- 6. На основе запроса из 5-го задания, создать вью employees_lang.

DROP VIEW IF EXISTS `view_emp_lang`;
CREATE VIEW `view_emp_lang`
       AS SELECT e.emp_no, e.birth_date, e.first_name, e.last_name, e.gender, e.hire_date, l.lang_name
            FROM `employees`.`employees`  AS e
	   LEFT JOIN `tempdb`.`language` AS l ON e.lang_no = l.lang_no
;

-- 7. Через вью employees_lang вывести количество сотрудников в разрезе языка.
SELECT lang_name,
       count(emp_no) AS `QTY`
 FROM `view_emp_lang`
GROUP BY lang_name
;