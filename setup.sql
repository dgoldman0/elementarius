DROP DATABASE elementarius_game;
CREATE DATABASE elementarius_game;
USE elementarius_game;

CREATE TABLE Users (id INT NOT NULL auto_increment, username VARCHAR(60) NOT NULL, xp INT UNSIGNED NOT NULL DEFAULT 0,
  packs SMALLINT UNSIGNED NOT NULL DEFAULT 0, fire INT NOT NULL DEFAULT 0, air INT NOT NULL DEFAULT 0, water INT NOT NULL DEFAULT 0,
  earth INT NOT NULL DEFAULT 0, light INT NOT NULL DEFAULT 0, darkness INT NOT NULL DEFAULT 0, spirit INT NOT NULL DEFAULT 0, PRIMARY KEY (id));

CREATE TABLE Stones (id INT UNSIGNED NOT NULL auto_increment, owner_id INT UNSIGNED NOT NULL, mana_type VARCHAR(10) NOT NULL, stone_type VARCHAR(10), energy INT UNSIGNED NOT NULL, PRIMARY KEY (id));

INSERT INTO Users (username, packs) VALUES ('admin', 10);

DELIMITER $$

CREATE PROCEDURE normal(IN iterations TINYINT, OUT result FLOAT)
READS SQL DATA SQL SECURITY INVOKER
BEGIN
  DECLARE total FLOAT;
  DECLARE cnt TINYINT;
  SET total = 0;
  SET cnt = 0;

  WHILE cnt < iterations DO
    -- random_bytes is a cryptographically secure random number genreator, so each byte should be an iid. As a result, we can sum them to make them approximately normal.
    SET total = total + ASCII(CAST(random_bytes(1) AS CHAR));
    SET cnt = cnt + 1;
  END WHILE;

  -- Normalize
  SET result = ((total / 255) - iterations/2) / sqrt(iterations/12);
  SELECT @result;
END;$$

-- Generate a pack and distribute it to the user. Output results as string for log.

CREATE PROCEDURE open_pack(user_id INT, OUT results VARCHAR(2500))
READS SQL DATA SQL SECURITY INVOKER
BEGIN

  DECLARE count TINYINT;
  DECLARE m_type VARCHAR (10);

  DECLARE mana_amt FLOAT;
  DECLARE s_type VARCHAR(10);
  DECLARE stone_energy INT UNSIGNED;
  DECLARE type_rnd FLOAT;
  DECLARE rarity_rnd FLOAT;

  SET count = 0;
  SET results = "";

  -- Make sure user exists and there are enough packs.
  SELECT (count(*) AND packs > 0) INTO @enough_packs FROM Users WHERE id = user_id GROUP BY id LIMIT 1;

  IF @enough_packs = 1 THEN
	  UPDATE Users SET packs = packs - 1 WHERE id = user_id; -- Remove a pack from the user's inventory
	  REPEAT

		SET mana_amt = 0;
		CALL normal(16, @rnd);
		
		-- Make sure that the z-scores are correct for one tail!
		IF @rnd < -0.8958 THEN
		  SET m_type = 'FIRE';
		ELSEIF @rnd < -0.3309 THEN
		  SET m_type = 'AIR';
		ELSEIF @rnd < 0.1397 THEN
		  SET m_type = 'WATER';
		ELSEIF @rnd < 0.6456 THEN
		  SET m_type = 'EARTH';
		ELSEIF @rnd < 1.0444 THEN
		  SET m_type = 'LIGHT';
		ELSEIF @rnd < 1.7862 THEN
		  SET m_type = 'DARKNESS';
		ELSE
		  SET m_type = 'SPIRIT';
		END IF;
			
		SELECT m_type;
		
		CALL normal(16, @a);
		IF @a > -1.2816 THEN
		  -- Create mana
		  CALL normal(16, @m);
		  
		  SET mana_amt = EXP(@m) * 100;
		  IF mana_amt < 50 THEN SET mana_amt = 50; ELSEIF mana_amt > 1000 THEN SET mana_amt = 1000; END IF;

		  -- Update user's quantity of mana
		  IF m_type = 'FIRE' THEN UPDATE Users SET fire = fire + FLOOR(mana_amt) WHERE id = user_id;
		  ELSEIF m_type = 'AIR' THEN UPDATE Users SET fire = air + FLOOR(mana_amt) WHERE id = user_id;
		  ELSEIF m_type = 'WATER' THEN UPDATE Users SET water = water + FLOOR(mana_amt) WHERE id = user_id;
		  ELSEIF m_type = 'EARTH' THEN UPDATE Users SET earth = earth + FLOOR(mana_amt) WHERE id = user_id;
		  ELSEIF m_type = 'LIGHT' THEN UPDATE Users SET light = light + FLOOR(mana_amt) WHERE id = user_id;
		  ELSEIF m_type = 'DARKNESS' THEN UPDATE Users SET darkness = darkness + FLOOR(mana_amt) WHERE id = user_id;
		  ELSEIF m_type = 'SPIRIT' THEN UPDATE Users SET spirit = spirit + FLOOR(mana_amt) WHERE id = user_id;
		  END IF;
		  
		  SET results = concat(concat(results, "MANA: ", m_type), concat(", ", CAST(mana_amt AS char(50))));
		ELSE
		  -- Create a mana stone!

		  -- Determine what kind of stone should be created
		  CALL normal(16, @stype);

		  IF @stype < -1.6449 THEN SET s_type = 'LIFE';
		  ELSEIF @stype < -0.6745 THEN SET s_type = 'CREATION';
		  ELSE SET s_type = 'INSIGHT';
		  END IF;

		  -- Determine what rarity stone should be created
		  CALL normal(32, @rnd);

		  IF @rnd < -3.384196 THEN SET stone_energy = 240100;
		  ELSEIF @rnd < -2.764 THEN SET stone_energy = 34300;
		  ELSEIF @rnd < -2.047 THEN SET stone_energy = 4900;
		  ELSEIF @rnd < -1.068 THEN SET stone_energy = 700;
		  ELSE SET stone_energy = 100;
		  END IF;

		  -- Add new mana stone of the created type to the inventory
		  INSERT INTO Stones (owner_id, mana_type, stone_type, energy) VALUES (user_id, m_type, s_type, stone_energy);
		  SET results = concat(concat(concat(results, "STONE: "), concat(m_type, ", ")), concat(concat(s_type,", "), CAST(stone_energy as CHAR(50))));
		END IF;
		
		SET count = count + 1;
		If count < 5 THEN SET results = CONCAT(results, "; "); END IF;
	  UNTIL count = 5 END REPEAT;
	ELSE 
		SET results = "ERR: Not enough packs";
	END IF;
END;$$
DELIMITER ;

/*
CREATE PROCEDURE fuse_stones(IN id_list VARCHAR(1000))
  READS SQL DATA SQL SECURITY INVOKER
  BEGIN
    DECLARE id_list_local VARCHAR(1000);
    DECLARE start_pos SMALLINT;
    DECLARE comma_pos SMALLINT;
    DECLARE current_id VARCHAR(1000);
    DECLARE end_loop TINYINT;
    DECLARE first_stone BOOL;
    DECLARE mana_type TINYINT;
    DECLARE s_type TINYINT;
    DECLARE total_energy SMALLINT;
    DECLARE error BOOL;

    SET id_array_local = id_array;
    SET start_pos = 1;
    SET comma_pos = locate(',', id_array_local);
    SET first_stone = TRUE;
    SET error = FALSE;

    START TRANSACTION;
    REPEAT
         IF comma_pos > 0 THEN
             SET current_id = substring(id_array_local, start_pos, comma_pos - start_pos);
             SET end_loop = 0;
         ELSE
             SET current_id = substring(id_array_local, start_pos);
             SET end_loop = 1;
         END IF;

         -- If first stone, store mana type and stone type.
         -- Then make sure the next stone in the list is of the same type.
         -- Finally start adding stone energy together or throw error if not same type.
         -- I need to figure out how to terminate the loop and throw a catch
         SELECT mana_type AS mt, stone_type AS st, energy FROM Stones WHERE (id = current_id);

         IF first_stone THEN
             SET first_stone = FALSE
             SET mana_type = mt
             SET stone_type = st
         END IF

         IF end_loop = 0 THEN
             SET id_array_local = substring(id_array_local, comma_pos + 1);
             SET comma_pos = locate(',', id_array_local);
         END IF
    UNTIL end_loop = 1

    END REPEAT;
    -- If all goes well, commit data
    IF error = FALSE THEN COMMIT ELSE ROLLBACK;
END;$$
*/
