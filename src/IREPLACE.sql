DELIMITER $$

DROP FUNCTION IF EXISTS `IREPLACE`$$

CREATE FUNCTION `IREPLACE`(str TEXT, needle CHAR(255), str_rep CHAR(255)) RETURNS TEXT CHARSET latin1
BEGIN
    DECLARE return_str TEXT DEFAULT '';
    DECLARE lower_str TEXT;
    DECLARE lower_needle TEXT;
    DECLARE pos INT DEFAULT 1;
    DECLARE old_pos INT DEFAULT 1;
    SELECT LOWER(str) INTO lower_str;
    SELECT LOWER(needle) INTO lower_needle;
    SELECT LOCATE(lower_needle, lower_str, pos) INTO pos;
    WHILE pos > 0 DO
        SELECT CONCAT(return_str, SUBSTR(str, old_pos, pos-old_pos), str_rep) INTO return_str;
        SELECT pos + CHAR_LENGTH(needle) INTO pos;
        SELECT pos INTO old_pos;
        SELECT LOCATE(lower_needle, lower_str, pos) INTO pos;
    END WHILE;
    SELECT CONCAT(return_str, SUBSTR(str, old_pos, CHAR_LENGTH(str))) INTO return_str;
    RETURN return_str;
END$$

DELIMITER ;
