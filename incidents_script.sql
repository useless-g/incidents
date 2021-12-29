CREATE DATABASE INCIDENTS;

USE INCIDENTS;

CREATE TABLE IF NOT EXISTS incident(
    id INT UNSIGNED PRIMARY KEY NOT NULL,
    date DATE NOT NULL,
    type VARCHAR(100),
    decision ENUM('отказано в возбуждении дела', 
    'удовлетворено ходатайство о возбуждении уголовного дела с указанием регистрационного номера заведенного дела', 
    'отправлено по территориальному признаку') NOT NULL
);


CREATE TABLE IF NOT EXISTS person(
    id INT UNSIGNED PRIMARY KEY NOT NULL,
    фамилия VARCHAR(30) NOT NULL,
    имя VARCHAR(30) NOT NULL,
    отчество VARCHAR(30) NOT NULL,
    адрес VARCHAR(80) NOT NULL,
    судимости INT UNSIGNED
);


CREATE TABLE IF NOT EXISTS involvement(
    person_id INT UNSIGNED NOT NULL,
    incident_id INT UNSIGNED NOT NULL,
    role ENUM('виновник', 'потерпевший', 'подозреваемый', 'свидетель'),
    FOREIGN KEY (incident_id) REFERENCES incident (id)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
    FOREIGN KEY (person_id) REFERENCES person (id)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
    PRIMARY KEY (person_id, incident_id)
);


/* запрос для генерация протокола происшествия используется в protocol_incident*/
/* происшествие */
SELECT * FROM incident WHERE id = {id};

/* участники */
SELECT p.id, p.фамилия, p.имя, p.отчество, p.адрес, p.судимости, i.role
FROM person p LEFT JOIN involvement i
    ON p.id = i.person_id
WHERE i.incident_id = {id};



INSERT INTO incident
VALUES (1,'2021-07-06', 'убийство', 'отказано в возбуждении дела');,
(2,'2021-08-06', 'убийство', 'отказано в возбуждении дела'),
(3,'2021-04-06', 'убийство', 'отказано в возбуждении дела'),
(4,'2021-03-06', 'убийство', 'отказано в возбуждении дела'),
(5,'2021-08-30', 'убийство', 'отказано в возбуждении дела'),
(6,'2021-03-19', 'убийство', 'отказано в возбуждении дела'),
(7,'2021-02-06', 'убийство', 'отказано в возбуждении дела'),
(8,'2021-01-26', 'убийство', 'отказано в возбуждении дела'),
(9,'2021-10-16', 'убийство', 'отказано в возбуждении дела'),
(10,'2019-07-16', 'убийство', 'отказано в возбуждении дела'),
(11,'2020-07-16', 'убийство', 'отказано в возбуждении дела'),
(12,'2020-07-16', 'убийство', 'отказано в возбуждении дела');


UPDATE incident SET decision = 'удовлетворено ходатайство о возбуждении уголовного дела с указанием регистрационного номера заведенного дела' WHERE id > 9;

INSERT INTO person
VALUES (1,'иванов', 'иван', 'иванович', 'Невский проспект, дом 100, квартира 12', 0),
(2,'иванов', 'антон', 'иванович', 'Невский проспект, дом 100, квартира 11', 5),
(3,'иванов', 'сергей', 'иванович', 'Невский проспект, дом 100, квартира 10', 0),
(4,'иванов', 'даниил', 'иванович', 'Невский проспект, дом 100, квартира 9', 0),
(5,'иванов', 'никита', 'иванович', 'Невский проспект, дом 100, квартира 8', 47),
(6,'иванов', 'григорий', 'иванович', 'Невский проспект, дом 100, квартира 7', 0),
(7,'иванов', 'вадим', 'иванович', 'Невский проспект, дом 100, квартира 6', 0),
(8,'иванов', 'егор', 'иванович', 'Невский проспект, дом 100, квартира 5', 0),
(9,'иванов', 'артем', 'иванович', 'Невский проспект, дом 100, квартира 4', 0),
(10,'иванов', 'александр', 'иванович', 'Невский проспект, дом 100, квартира 3', 2),
(11,'иванов', 'максим', 'иванович', 'Невский проспект, дом 100, квартира 2', 1),
(12,'иванов', 'леонид', 'иванович', 'Невский проспект, дом 100, квартира 1', 1);


INSERT INTO involvement
VALUES (1, 12, 'подозреваемый'),
(2, 12, 'потерпевший'),
(3, 12, 'подозреваемый'),
(4, 11, 'потерпевший'),
(5, 11, 'свидетель'),
(6, 11, 'подозреваемый'),
(6, 10, 'виновник'),
(7, 10, 'потерпевший'),
(7, 9, 'виновник'),
(8, 9, 'потерпевший'),
(1, 9, 'подозреваемый'),
(3, 9, 'свидетель'),
(12, 8, 'потерпевший'),
(5, 8, 'виновник'),
(4, 7, 'свидетель'),
(3, 7, 'виновник'),
(11, 6, 'свидетель'),
(10, 5, 'виновник'),
(8, 5, 'свидетель'),
(9, 5, 'потерпевший'),
(9, 4, 'виновник'),
(10, 4, 'потерпевший'),
(11, 3, 'виновник'),
(12, 3, 'свидетель'),
(7, 3, 'виновник'),
(1, 3, 'потерпевший'),
(3, 2, 'виновник'),
(2, 1, 'свидетель'),
(4, 1, 'свидетель');


SET GLOBAL log_bin_trust_function_creators = 1;


DROP FUNCTION IF EXISTS amount_in_time;
DELIMITER $$
CREATE FUNCTION amount_in_time (a DATE, b DATE) RETURNS INT
BEGIN
    DECLARE amount INT DEFAULT 0;
    SELECT COUNT(*) INTO amount FROM incident WHERE date BETWEEN a AND b;
    RETURN amount;
END $$
DELIMITER ;

DROP FUNCTION IF EXISTS amount_for_person;
DELIMITER $$
CREATE FUNCTION amount_for_person (id INT) RETURNS INT
BEGIN
    DECLARE amountfp INT DEFAULT 0;
    SELECT COUNT(*) INTO amountfp FROM involvement WHERE person_id = id;
    RETURN amountfp;
END $$
DELIMITER ;


DROP PROCEDURE IF EXISTS insert_person;
DELIMITER $$
CREATE PROCEDURE insert_person(id INT, фамилия VARCHAR(30), имя VARCHAR(30), отчество VARCHAR(30), адрес VARCHAR(80), судимости INT)
BEGIN
INSERT INTO person VALUES(id , фамилия, имя, отчество, адрес, судимости);
END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS insert_incident;
DELIMITER $$
CREATE PROCEDURE insert_incident(id INT,
    date DATE,
    type VARCHAR(100),
    decision ENUM('отказано в возбуждении дела', 
    'удовлетворено ходатайство о возбуждении уголовного дела с указанием регистрационного номера заведенного дела', 
    'отправлено по территориальному признаку'))
BEGIN
INSERT INTO incident VALUES(id, date, type, decision);
END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS insert_involvement;
DELIMITER $$
CREATE PROCEDURE insert_involvement(person_id INT, incident_id INT, role ENUM('виновник', 'потерпевший', 'подозреваемый', 'свидетель'))
BEGIN
INSERT INTO involvement VALUES(person_id, incident_id, role);
END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS update_person;
DELIMITER $$
CREATE PROCEDURE update_person(_id INT, _фамилия VARCHAR(30), _имя VARCHAR(30), _отчество VARCHAR(30), _адрес VARCHAR(80), _судимости INT)
BEGIN
UPDATE person SET фамилия = _фамилия, имя = _имя, отчество = отчество, адрес = _адрес, судимости = _судимости
WHERE id = _id;
END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS update_incident;
DELIMITER $$
CREATE PROCEDURE update_incident(_id INT,
    _date DATE,
    _type VARCHAR(100),
    _decision ENUM('отказано в возбуждении дела', 
    'удовлетворено ходатайство о возбуждении уголовного дела с указанием регистрационного номера заведенного дела', 
    'отправлено по территориальному признаку'))
BEGIN
UPDATE incident SET date = _date, type = _type, decision = _decision
WHERE id = _id;
END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS update_involvement;
DELIMITER $$
CREATE PROCEDURE update_involvement(_person_id INT, _incident_id INT, _role ENUM('виновник', 'потерпевший', 'подозреваемый', 'свидетель'))
BEGIN
UPDATE involvement SET role = _role
WHERE person_id = _person_id AND incident_id = _incident_id;
END$$
DELIMITER ;


DROP TRIGGER IF EXISTS суд;
DELIMITER $$
CREATE TRIGGER суд AFTER UPDATE ON involvement
FOR EACH ROW
BEGIN
	UPDATE person SET судимости = судимости + 1 
    WHERE OLD.person_id = person.id AND OLD.role <> 'виновник' AND NEW.role = 'виновник';
END $$
DELIMITER ;


DROP TRIGGER IF EXISTS обвинение;
DELIMITER $$
CREATE TRIGGER обвинение AFTER INSERT ON involvement
FOR EACH ROW
BEGIN
	UPDATE person SET судимости = судимости + 1 
    WHERE NEW.person_id = person.id AND NEW.role = 'виновник';
END $$
DELIMITER ;



