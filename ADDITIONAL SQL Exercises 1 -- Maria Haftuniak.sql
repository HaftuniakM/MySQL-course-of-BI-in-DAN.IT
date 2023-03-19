-- ADDITIONAL SQL Exercises 1

/* 1. Создать таблицу client с полями:
• clnt_no (AUTO_INCREMENT первичный ключ)
• cnlt_name (нельзя null значения)
• clnt_tel (нельзя null значения)
• clnt_region_no */

USE `employees`;

CREATE TABLE IF NOT EXISTS `client` (
`clnt_no`        INT AUTO_INCREMENT,
`cnlt_name`      VARCHAR(40) NOT NULL,
`clnt_tel`       VARCHAR(13) NOT NULL,
`clnt_region_no` INT,
PRIMARY KEY (`clnt_no`)
) ENGINE=InnoDB;

/*2. Создать таблицу sales с полями:
• clnt_no (внешний ключ на таблицу client поле clnt_no; режим RESTRICT для update и delete)
• product_no (нельзя null значения)
• date_act (по умолчанию текущая дата)*/

DROP TABLE `sales`;
CREATE TABLE IF NOT EXISTS `sales` (
`clnt_no`    INT,
`product_no` INT NOT NULL,
`date_act`   DATE DEFAULT(CURRENT_DATE),
CONSTRAINT `sales1` FOREIGN KEY (`clnt_no`) REFERENCES `client` (`clnt_no`) ON UPDATE RESTRICT ON DELETE RESTRICT
)ENGINE=InnoDB;

-- 3. Добавить 5 клиентов (тестовые данные на свое усмотрение) в таблицу client.
INSERT INTO `client` (`cnlt_name`,`clnt_tel`, `clnt_region_no`)
	 VALUES ('Kovalenko Nikita', '+380506789415', '001'),
			('Moroz Vladyslav', '+380506759615', '002'),
            ('Vakulko Alexandr', '+380965759628', '002'),
            ('Petrova Maria', '+380966750013', '001'),
            ('Ivanov Sergiy', '+380505459628', '003')
;

-- 4. Добавить по 2 продажи для каждого сотрудника (тестовые данные на свое усмотрение ) в таблицу sales.
INSERT INTO `sales` (`clnt_no`,`product_no`)
	 VALUES ('1','101'),
            ('1','105'),
			('2','106'),
            ('2','101'),
            ('3','105'),
            ('3','105'),
            ('4','104'),
            ('4','101'),
            ('5','105'),
            ('5','101')
;

--  5. Из таблицы client, попробовать удалить клиента с clnt_no=1 и увидеть ожидаемую  ошибку. Ошибку зафиксировать в виде комментария через /* ошибка */
DELETE  
  FROM `client`
 WHERE clnt_no = '1'
 ;
/*Error Code: 1451. Cannot delete or update a parent row: a foreign key constraint fails (`employees`.`sales`, CONSTRAINT `sales1` FOREIGN KEY (`clnt_no`) REFERENCES `client` (`clnt_no`) ON DELETE RESTRICT ON UPDATE RESTRICT)*/

-- 6. Удалить из sales клиента по clnt_no=1, после чего повторить удаление из client по clnt_no=1 (ошибки в таком порядке не должно быть).
DELETE  
  FROM `sales`
 WHERE clnt_no = '1'
 ;
 
DELETE  
  FROM `client`
 WHERE clnt_no = '1'
 ;
 
-- 7. Из таблицы client удалить столбец clnt_region_no.
ALTER TABLE `client`
DROP COLUMN `clnt_region_no`;

-- 8. В таблице client переименовать поле clnt_tel в clnt_phone.
ALTER TABLE `client`
RENAME COLUMN `clnt_tel` TO `clnt_phone`;

-- 9. Удалить данные в таблице departments_dup с помощью DDL оператора truncate.

TRUNCATE TABLE `departments_dup`;
