CREATE DATABASE elementarius_game;
USE elementarius_game;

CREATE TABLE Users (id INT NOT NULL auto_increment, username VARCHAR(60) NOT NULL, xp INT UNSIGNED NOT NULL DEFAULT 0,
  packs SMALLINT UNSIGNED NOT NULL DEFAULT 0, fire INT NOT NULL DEFAULT 0, air INT NOT NULL DEFAULT 0, water INT NOT NULL DEFAULT 0,
  earth INT NOT NULL DEFAULT 0, light INT NOT NULL DEFAULT 0, darkness INT NOT NULL DEFAULT 0, spirit INT NOT NULL DEFAULT 0);

CREATE TABLE Stones (id INT UNSIGNED NOT NULL auto_increment, owner_id INT UNSIGNED NOT NULL, mana_type VARCHAR(10) NOT NULL, stone_type VARCHAR(10), energy SMALLINT UNSIGNED NOT NULL);

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

  -- total will have a mean of 255n/2 and variance of 255n/12
  -- Normalize
  SET result = ((total / 255 / iterations) - 0.5) * sqrt(12);
  SELECT @result;
END;$$

-- Generate a pack and distribute it to the user

CREATE PROCEDURE open_pack(user_id INT)
READS SQL DATA SQL SECURITY INVOKER
BEGIN

  DECLARE count TINYINT;
  DECLARE m_type TINYINT;

  DECLARE mana_rnd FLOAT;
  DECLARE mana_amt SMALLINT;
  DECLARE stone_type TINYINT;
  DECLARE stone_energy TINYINT;
  DECLARE type_rnd FLOAT;

  SET count = 0;

  -- I should make sure that a user by user_id actually exists!

  REPEAT

    SET mana_amt = 0;
    CALL normal(16, @a);
    
	SELECT @a as mana_rnd;
    
    -- Make sure that the z-scores are correct for one tail!
    IF mana_rnd < -0.8958 THEN
      SET m_type = 'FIRE';
    ELSEIF mana_rnd < -0.3309 THEN
      SET m_type = 'AIR';
    ELSEIF mana_rnd < 0.1397 THEN
      SET m_type = 'WATER';
    ELSEIF mana_rnd < 0.6456 THEN
      SET m_type = 'EARTH';
    ELSEIF mana_rnd < 1.0444 THEN
      SET m_type = 'LIGHT';
    ELSEIF mana_rnd < 1.7862 THEN
      SET m_type = 'DARKNESS';
    ELSE
      SET m_type = 'SPIRIT';
    END IF;
    
	CALL normal(16, @a);
    SELECT @a as a;
    IF a > -1.2816 THEN
      -- Create mana
      CALL normal(16, @m);
      SELECT @m as m;
      
      SET mana_amt = EXP(m) * 100;
      IF mana_amt < 50 THEN SET mana_amt = 50; ELSEIF mana_amt > 1000 THEN SET mana_amt = 1000; END IF;

      -- Update user's quantity of mana
      IF @mana_type = 'FIRE' THEN UPDATE Users SET fire = fire + mana_amt;
      ELSEIF m_type = 'AIR' THEN UPDATE Users SET fire = air + mana_amt;
      ELSEIF m_type = 'WATER' THEN UPDATE Users SET water = water + mana_amt;
      ELSEIF m_type = 'EARTH' THEN UPDATE Users SET earth = earth + mana_amt;
      ELSEIF m_type = 'LIGHT' THEN UPDATE Users SET light = light + mana_amt;
      ELSEIF m_type = 'DARKNESS' THEN UPDATE Users SET darkness = darkness + mana_amt;
      ELSEIF m_type = 'SPIRIT' THEN UPDATE Users SET spirit = spirit + mana_amt;
      END IF;
    ELSE
      -- Create a mana stone!

      -- Determine what kind of stone should be created
      CALL normal(16, @a);
      SELECT @a as a;
      SET type_rnd = a;

      IF type_rnd < -1.6449 THEN SET stone_type = 'INSIGHT';
      ELSEIF type_rnd < -0.6745 THEN SET stone_type = 'CREATION';
      ELSE SET stone_type = 'LIFE';
      END IF

      -- Determine what rarity stone should be created
      DECLARE rarity_rnd FLOAT;
      SET rarity_rnd = CALL normal(16);

      IF rarity_rnd < -3.384196 THEN stone_energy = 100;
      ELSEIF stone_rnd < -2.764 THEN stone_energy = 700;
      ELSEIF stone_rnd < -2.047 THEN stone_energy = 4900;
      ELSEIF stone_rnd < -1.068 THEN stone_energy = 34300;
      ELSE stone_energy = 240100;
      END IF

      -- Add new mana stone of the created type to the inventory
      INSERT INTO Stones (owner_id, mana_type, stone_type, energy) VALUES (user_id, m_type, @stone_type, stone_energy);

    END IF;
    
    SET count = count + 1;
  UNTIL count = 4 END REPEAT;
-- I want this statement to return a list of the results as well so that it can be presented to the user.
END;$$

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
    DECLARE stone_type TINYINT;
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
DELIMITER;
