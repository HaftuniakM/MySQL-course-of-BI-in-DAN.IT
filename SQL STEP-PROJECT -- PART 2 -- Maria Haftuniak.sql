-- Дизайн базы данных:
/* 1. Разработайте базу данных для управления курсами. 
База данных содержит следующие сущности:
a. students: student_no, teacher_no, course_no, student_name, email, birth_date
b. teachers: teacher_no, teacher_name, phone_no
c. courses:  course_no, course_name, start_date, end_date.
● Секционировать по годам, таблицу students по полю birth_date с помощью механизма range
● В таблице students сделать первичный ключ в сочетании двух полей student_no и birth_date
● Создать индекс по полю students.email 
● Создать уникальный индекс по полю teachers.phone_no */

DROP DATABASE IF EXISTS `course_management`;
CREATE DATABASE `course_management`;

USE `course_management`;

DROP TABLE IF EXISTS `students`;
CREATE TABLE `students` (
 `student_no`   INT         NOT NULL, 
 `teacher_no`   INT         NOT NULL, 
 `course_no`    CHAR(4)     NOT NULL, 
 `student_name` VARCHAR(30) NOT NULL, 
 `email`        VARCHAR(40) NOT NULL, 
 `birth_date`   DATE        NOT NULL,
PRIMARY KEY (`student_no`, `birth_date`)
) ENGINE = INNODB
PARTITION BY RANGE (YEAR(`birth_date`)) 
(
 PARTITION p0 VALUES LESS THAN (1980),
 PARTITION p1 VALUES LESS THAN (1990),
 PARTITION p2 VALUES LESS THAN (2000),
 PARTITION p3 VALUES LESS THAN (2010),
 PARTITION p4 VALUES LESS THAN (2020),
 PARTITION p5 VALUES LESS THAN (MAXVALUE)
) 
;

CREATE INDEX `index_email` ON `students`(`email`);

DROP TABLE IF EXISTS `teachers`;
CREATE TABLE `teachers` 
(
 `teacher_no`   INT         NOT NULL, 
 `teacher_name` VARCHAR(30) NOT NULL, 
 `phone_no`     VARCHAR(13) NOT NULL
) ENGINE = INNODB
;

CREATE UNIQUE INDEX `index_phone` ON `teachers`(`phone_no`);

DROP TABLE IF EXISTS `courses`;
CREATE TABLE `courses` (
  `course_no`   CHAR(4)     NOT NULL, 
  `course_name` VARCHAR(30) NOT NULL, 
  `start_date`  DATE        NOT NULL, 
  `end_date`    DATE        NOT NULL
) ENGINE = INNODB
;

-- 2. На свое усмотрение добавить тестовые данные (7-10 строк) в наши три таблицы.
INSERT INTO `students` (`student_no`, `teacher_no`, `course_no`, `student_name`, `email`, `birth_date`)
VALUES (1, 1, 'abc1', 'Kovalchuk Sergiy', 'kovalchuk_sergiy@gmail.com', '19910205' ),
       (2, 1, 'abc1', 'Matrosova Sofia', 'matrosova_sofia97@gmail.com', '19971125' ),
       (3, 2, 'abc2', 'Fedoriv Alexandr', 'fedoriv_alexandr@gmail.com', '19890312' ),
       (4, 2, 'abc2', 'Chyz Viktor', 'chyz_viktor98@gmail.com', '19980502' ),
       (5, 3, 'abc3', 'Bestik Nikita', 'bestik_nikita@gmail.com', '19941008'),
       (6, 3, 'abc3', 'Tarasova Valentyna', 'tarasova_valentyna@gmail.com', '19881108'),
       (7, 4, 'abc4', 'Vitrenko Maria', 'vitrenko_maria@gmail.com', '20001128'),
       (8, 4, 'abc4', 'Hovorukha Kateryna', 'hovorukha_kateryna@gmail.com', '20010109'),
       (9, 5, 'abc5', 'Petrova Iryna', 'petrova_iryna@gmail.com', '19991020'),
       (10, 5, 'abc5', 'Vidz Sofia', 'vidz_sofia@gmail.com', '20000129')
;
     
INSERT INTO  `teachers` (`teacher_no`, `teacher_name`, `phone_no`)
     VALUES (1, 'Vakulov Alexandr', '+380967438614'),
            (2, 'Martynov Andrew', '+380986538942'),
            (3, 'Pokotilova Maria', '+380957639512'),
            (4, 'Nikitenko Sergiy', '+380508695432'),
            (5, 'Nesterenko Innesa', '+380675298741'),
            (6, 'Makarenko Nazar', '+380508456975'),
            (7, 'Titarenko Natalya', '+380968525645')
;

INSERT INTO  `courses` (`course_no`, `course_name`, `start_date`, `end_date`)
     VALUES ('abc1', 'Business Intelligence', '20221201', '20230601'),
            ('abc2', 'Digital Marketing', '20230101', '20230701'),
            ('abc3', 'Java', '20221215', '20230615'),
            ('abc4', 'FrontEnd', '20221220', '20230620'),
            ('abc5', 'Quality Assurance', '20221201', '20230601')
;

/*3. Отобразить данные за любой год из таблицы students и зафиксировать в виду  комментария план выполнения запроса, 
где будет видно что запрос будет выполняться по конкретной секции.*/

EXPLAIN SELECT *
 FROM `students`
WHERE `birth_date` BETWEEN '19990101' AND '19991231'
;
-- план виконання запиту:
/* id, select_type,      table, partitions,  type, possible_keys, key, key_len,  ref, rows, filtered, Extra
  '1',    'SIMPLE', 'students',       'p2', 'ALL',          NULL, NULL,   NULL, NULL,  '5',  '20.00', 'Using where' */

/*4. Отобразить данные учителя, по любому одному номеру телефона и зафиксировать план выполнения запроса, где будет видно, 
что запрос будет выполняться по индексу, а не методом ALL. 
Далее индекс из поля teachers.phone_no сделать невидимым и зафиксировать план выполнения запроса, где ожидаемый результат - метод ALL. 
В итоге индекс оставить в статусе - видимый.*/

EXPLAIN SELECT *
FROM `teachers`
WHERE `phone_no` = '+380675298741'
;
-- план виконання запиту:
/*# id, select_type,       table, partitions,    type, possible_keys,           key, key_len,    ref, rows, filtered, Extra
   '1',    'SIMPLE',  'teachers',       NULL, 'const', 'index_phone', 'index_phone', '   54', 'const', '1', '100.00', NULL */

/* Додатково присвоюю полю `teacher_no` значення первинного ключа, 
оскільки за його відсутності створений унікальний індекс сприймається БД як первинний ключ
і статус 'invisible' для поля `teachers`.`phone_no` не вдається зробити*/
ALTER TABLE `teachers` 
ADD PRIMARY KEY (`teacher_no`);

ALTER TABLE `teachers`
ALTER INDEX `index_phone` INVISIBLE;

EXPLAIN SELECT *
FROM `teachers`
WHERE `phone_no` = '+380675298741'
;
-- план виконання запиту:
/*# id, select_type,      table, partitions,  type, possible_keys,  key, key_len,  ref, rows, filtered, Extra
   '1',    'SIMPLE', 'teachers',       NULL, 'ALL',          NULL, NULL,    NULL, NULL,  '1', '100.00', 'Using where'*/

ALTER TABLE `teachers`
ALTER INDEX `index_phone` VISIBLE;

-- 5. Специально сделаем 3 дубляжа в таблице students (добавим еще 3 одинаковые строки).
-- Виконую 5,6 завдання по обговореній ряніше схемі з лектором
DROP TABLE `temporary_students` ;
CREATE TEMPORARY TABLE `temporary_students` 
 (
 `student_no`   INT         NOT NULL, 
 `teacher_no`   INT         NOT NULL, 
 `course_no`    CHAR(4)     NOT NULL, 
 `student_name` VARCHAR(30) NOT NULL, 
 `email`        VARCHAR(40) NOT NULL, 
 `birth_date`   DATE        NOT NULL
) ENGINE = INNODB;

INSERT INTO `temporary_students` 
VALUES (1, 1, 'abc1', 'Kovalchuk Sergiy', 'kovalchuk_sergiy@gmail.com', '19910205' ),
       (2, 1, 'abc1', 'Matrosova Sofia', 'matrosova_sofia97@gmail.com', '19971125' ),
       (3, 2, 'abc2', 'Fedoriv Alexandr', 'fedoriv_alexandr@gmail.com', '19890312' ),
       (4, 2, 'abc2', 'Chyz Viktor', 'chyz_viktor98@gmail.com', '19980502' ),
       (5, 3, 'abc3', 'Bestik Nikita', 'bestik_nikita@gmail.com', '19941008'),
       (6, 3, 'abc3', 'Tarasova Valentyna', 'tarasova_valentyna@gmail.com', '19881108'),
       (7, 4, 'abc4', 'Vitrenko Maria', 'vitrenko_maria@gmail.com', '20001128'),
       (8, 4, 'abc4', 'Hovorukha Kateryna', 'hovorukha_kateryna@gmail.com', '20010109'),
       (9, 5, 'abc5', 'Petrova Iryna', 'petrova_iryna@gmail.com', '19991020'),
       (10, 5, 'abc5', 'Vidz Sofia', 'vidz_sofia@gmail.com', '20000129'),
       (11, 6, 'abc6', 'Vidz Maria', 'vidz_maria@gmail.com', '20001010'),
       (11, 6, 'abc6', 'Vidz Maria', 'vidz_maria@gmail.com', '20001010'),
	   (11, 6, 'abc6', 'Vidz Maria', 'vidz_maria@gmail.com', '20001010')
;

-- 6. Написать запрос, который выводит строки с дубляжами.
SELECT * 
  FROM (SELECT *, 
			   COUNT(`rwn`)OVER(PARTITION BY student_no, teacher_no, course_no, student_name, email, birth_date)         AS `cnt`
		  FROM (SELECT *, 
					   ROW_NUMBER()OVER(PARTITION BY student_no, teacher_no, course_no, student_name, email, birth_date) AS `rwn`
  FROM `temporary_students`) AS `t1`) AS `t2`
  WHERE `cnt` > 1
;