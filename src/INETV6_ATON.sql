DELIMITER $$

DROP FUNCTION IF EXISTS `INETV6_ATON`$$

CREATE FUNCTION `INETV6_ATON`(addr TEXT) RETURNS BLOB
    DETERMINISTIC
BEGIN
    DECLARE ret TEXT CHARSET BINARY;
    DECLARE tmpText TEXT;
    
    IF addr IS NULL THEN
        RETURN NULL;
    END IF;
    
    /* IPv4 */
    SET ret = UNHEX(HEX(INET_ATON(addr)));
    IF ret IS NOT NULL THEN
        SET ret = CONCAT(REPEAT(X'00', 4 - LENGTH(ret)), ret);
    END IF;
    
    /* IPv6 */
    IF ret IS NULL THEN
        /* normalize: die letzten 4 Bytes dürfen wie IPv4 formatiert werden */
        IF addr REGEXP ":[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}$" THEN
            /* split IPv4 address notation part */
            SET tmpText = REVERSE(addr);
            SET tmpText = SUBSTRING(tmpText, 1, INSTR(tmpText, ":") - 1);
            SET tmpText = REVERSE(tmpText);
            SET addr    = SUBSTRING(addr, 1, LENGTH(addr) - LENGTH(tmpText));
            
            /* convert IPv4 adderss notation into HEX:HEX notation */
            SET tmpText = INSERT(HEX(INET_ATON(tmpText)), 5, 0, ":");
            
            /* concat both parts */
            SET addr = CONCAT(addr, tmpText);
        END IF; 
        
        /* normalize: Ein oder mehrere aufeinander folgende Blöcke, deren Wert 0 (bzw. 0000) beträgt, dürfen ausgelassen werden. */
        CASE (LENGTH(addr) - LENGTH(REPLACE(addr, ":", "")))
            WHEN 6 THEN SET addr = REPLACE(addr, "::", ":0000:0000:");
            WHEN 5 THEN SET addr = REPLACE(addr, "::", ":0000:0000:0000:");
            WHEN 4 THEN SET addr = REPLACE(addr, "::", ":0000:0000:0000:0000:");
            WHEN 3 THEN SET addr = REPLACE(addr, "::", ":0000:0000:0000:0000:0000:");
            WHEN 2 THEN SET addr = REPLACE(addr, "::", ":0000:0000:0000:0000:0000:0000:");
            ELSE BEGIN END;
        END CASE;
        
        /* normalize: führende nullen dürfen weg gelassen werden */
        CASE LENGTH(SUBSTRING_INDEX(addr, ":", 1))
            WHEN 3 THEN SET addr = CONCAT("0", addr);
            WHEN 2 THEN SET addr = CONCAT("00", addr);
            WHEN 1 THEN SET addr = CONCAT("000", addr);
            WHEN 0 THEN SET addr = CONCAT("0000", addr);
            ELSE BEGIN END;
        END CASE;
        CASE LENGTH(SUBSTRING_INDEX(addr, ":", 2))
            WHEN 8 THEN SET addr = CONCAT(SUBSTRING(addr, 1, 5), "0", SUBSTRING(addr, 6));
            WHEN 7 THEN SET addr = CONCAT(SUBSTRING(addr, 1, 5), "00", SUBSTRING(addr, 6));
            WHEN 6 THEN SET addr = CONCAT(SUBSTRING(addr, 1, 5), "000", SUBSTRING(addr, 6));
            ELSE BEGIN END;
        END CASE;
        CASE LENGTH(SUBSTRING_INDEX(addr, ":", 3))
            WHEN 13 THEN SET addr = CONCAT(SUBSTRING(addr, 1, 10), "0", SUBSTRING(addr, 11));
            WHEN 12 THEN SET addr = CONCAT(SUBSTRING(addr, 1, 10), "00", SUBSTRING(addr, 11));
            WHEN 11 THEN SET addr = CONCAT(SUBSTRING(addr, 1, 10), "000", SUBSTRING(addr, 11));
            ELSE BEGIN END;
        END CASE;
        CASE LENGTH(SUBSTRING_INDEX(addr, ":", 4))
            WHEN 18 THEN SET addr = CONCAT(SUBSTRING(addr, 1, 15), "0", SUBSTRING(addr, 16));
            WHEN 17 THEN SET addr = CONCAT(SUBSTRING(addr, 1, 15), "00", SUBSTRING(addr, 16));
            WHEN 16 THEN SET addr = CONCAT(SUBSTRING(addr, 1, 15), "000", SUBSTRING(addr, 16));
            ELSE BEGIN END;
        END CASE;
        CASE LENGTH(SUBSTRING_INDEX(addr, ":", 5))
            WHEN 23 THEN SET addr = CONCAT(SUBSTRING(addr, 1, 20), "0", SUBSTRING(addr, 21));
            WHEN 22 THEN SET addr = CONCAT(SUBSTRING(addr, 1, 20), "00", SUBSTRING(addr, 21));
            WHEN 21 THEN SET addr = CONCAT(SUBSTRING(addr, 1, 20), "000", SUBSTRING(addr, 21));
            ELSE BEGIN END;
        END CASE;
        CASE LENGTH(SUBSTRING_INDEX(addr, ":", 6))
            WHEN 28 THEN SET addr = CONCAT(SUBSTRING(addr, 1, 25), "0", SUBSTRING(addr, 26));
            WHEN 27 THEN SET addr = CONCAT(SUBSTRING(addr, 1, 25), "00", SUBSTRING(addr, 26));
            WHEN 26 THEN SET addr = CONCAT(SUBSTRING(addr, 1, 25), "000", SUBSTRING(addr, 26));
            ELSE BEGIN END;
        END CASE;
        CASE LENGTH(SUBSTRING_INDEX(addr, ":", 7))
            WHEN 33 THEN SET addr = CONCAT(SUBSTRING(addr, 1, 30), "0", SUBSTRING(addr, 31));
            WHEN 32 THEN SET addr = CONCAT(SUBSTRING(addr, 1, 30), "00", SUBSTRING(addr, 31));
            WHEN 31 THEN SET addr = CONCAT(SUBSTRING(addr, 1, 30), "000", SUBSTRING(addr, 31));
            ELSE BEGIN END;
        END CASE;
        CASE LENGTH(addr)
            WHEN 38 THEN SET addr = CONCAT(SUBSTRING(addr, 1, 35), "0", SUBSTRING(addr, 36));
            WHEN 37 THEN SET addr = CONCAT(SUBSTRING(addr, 1, 35), "00", SUBSTRING(addr, 36));
            WHEN 36 THEN SET addr = CONCAT(SUBSTRING(addr, 1, 35), "000", SUBSTRING(addr, 36));
            WHEN 35 THEN SET addr = CONCAT(addr, "0000");
            ELSE BEGIN END;
        END CASE;
        /* return IPv6 in binary format if it's a valid address */
        IF addr REGEXP "[0-9a-fA-F]{4,4}:[0-9a-fA-F]{4,4}:[0-9a-fA-F]{4,4}:[0-9a-fA-F]{4,4}:[0-9a-fA-F]{4,4}:[0-9a-fA-F]{4,4}:[0-9a-fA-F]{4,4}:[0-9a-fA-F]{4,4}" THEN
            SET ret = UNHEX(REPLACE(addr, ":", ""));
        END IF;
    END IF;
    
    RETURN ret;
END$$

DELIMITER ;
