-- ADDITIONAL SQL Exercises (INDEX) 2

/* 1. В схеме tempdb создать таблицу dept_emp с делением по партициям по полю from_date. 
Для этого:
• Из базы данных employees таблицы dept_emp → из Info-Table inspector - DDL взять и скопировать код по созданию той таблицы.
• Убрать из DDL кода упоминание про KEY и CONSTRAINT.
• И добавить код для секционирования по полю from_date с 1985 года до 2002. Партиции по каждому году.
HINT: CREATE TABLE... PARTITION BY RANGE (YEAR(from_date)) (PARTITION...) */
CREATE DATABASE IF NOT EXISTS `tempdb`;

USE `tempdb`; 

DROP TABLE IF EXISTS `dept_emp` ;
CREATE TABLE `dept_emp` (
  `emp_no` int NOT NULL,
  `dept_no` char(4) NOT NULL,
  `from_date` date NOT NULL,
  `to_date` date NOT NULL
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci
  PARTITION BY RANGE (YEAR(`from_date`))
  (
 PARTITION p0  VALUES LESS THAN (1985),
 PARTITION p1  VALUES LESS THAN (1986),
 PARTITION p2  VALUES LESS THAN (1987),
 PARTITION p3  VALUES LESS THAN (1988),
 PARTITION p4  VALUES LESS THAN (1989),
 PARTITION p5  VALUES LESS THAN (1990),
 PARTITION p6  VALUES LESS THAN (1991),
 PARTITION p7  VALUES LESS THAN (1992),
 PARTITION p8  VALUES LESS THAN (1993),
 PARTITION p9  VALUES LESS THAN (1994),
 PARTITION p10 VALUES LESS THAN (1995),
 PARTITION p11 VALUES LESS THAN (1996),
 PARTITION p12 VALUES LESS THAN (1997),
 PARTITION p13 VALUES LESS THAN (1998),
 PARTITION p14 VALUES LESS THAN (1999),
 PARTITION p15 VALUES LESS THAN (2000),
 PARTITION p16 VALUES LESS THAN (2001),
 PARTITION p17 VALUES LESS THAN (2002),
 PARTITION p18 VALUES LESS THAN (MAXVALUE)
  );


-- 2. Создать индекс на таблицу tempdb.dept_emp по полю dept_no.
CREATE INDEX `tempdb_dept_emp_index` ON `dept_emp`(`dept_no`);

-- 3. Из таблицы tempdb.dept_emp выбрать данные только за 1990 год.
SELECT *
FROM `dept_emp`
WHERE `from_date` BETWEEN '19900101' AND '19901231'
;

-- 4.На основе предыдущего задания, через explain убедиться что сканирование данных идет только по одной секции. Зафиксировать в виде комментария через/* вывод из explain*/.
     /*HINT: EXPLAIN SELECT ... FROM ... WHERE ...*/
EXPLAIN
SELECT *
FROM `dept_emp`
WHERE `from_date` BETWEEN '19900101' AND '19901231'
;	

-- # id, select_type,      table, partitions,  type, possible_keys,  key, key_len,  ref, rows, filtered, Extra
--  '1',    'SIMPLE', 'dept_emp',       'p6', 'ALL',          NULL, NULL,    NULL, NULL,  '1', '100.00', 'Using where'


-- 5. Загрузить свой любой CSV файл в схему tempdb.
--    HINT: LOAD DATA INFILE ... INTO TABLE ...

CREATE TABLE IF NOT EXISTS `exercise_5` -- створення таблиці в яку будуть завантажені дані з файлу
(`Year`      DATE,
`AVG_salary` DECIMAL)
;

SHOW VARIABLES LIKE "secure_file_priv"; -- 'secure_file_priv', 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\'

LOAD DATA INFILE "C:\ProgramData\MySQL\MySQL Server 8.0\Uploads\for_Additional_exercise_2.csv"
INTO TABLE `tempdb`.`exercise_5`
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
