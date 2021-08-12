/* Initialization Script
**
** Handles the creation of tables and stored procedures.
** Much of the mechanics for this game, including pack generation and champion creation occurs using stored procedures rather than external code.
*/
-- z-scores are almost certainly not right. I just did area z < z' = p, without taking into account that the area includes the area of the previous probability.
-- It's an easy fix. I just need to recalculate the z-scores properly.

DROP DATABASE elementarius_game; -- This line is just to delete old versions while working on the coding. It'll be gone in the final initialization script.
CREATE DATABASE elementarius_game;
USE elementarius_game;

DELIMITER $$

/* User Authentication Framework
**
** User authentication mirrors blockchain authentication. To sign in, a person will have to sign a chellenge message with their private key (RSA).
** This system could be used for any project really.
*/
CREATE TABLE Users (id INT NOT NULL auto_increment, username VARCHAR(60) NOT NULL, public_key TINYBLOB NOT NULL, PRIMARY KEY (id));

CREATE PROCEDURE register_user(IN username VARCHAR(60), IN pubkey TINYBLOB)
CREATE PROCEDURE request_challenge(IN uid INT UNSIGNED)
  READS SQL DATA SQL SECURITY INVOKER
  BEGIN

END;$$

-- Authenticate user, called after request_challenge
CREATE PROCEDURE authenticate_user(IN response TINYBLOB)
  READS SQL DATA SQL SECURITY INVOKER
  BEGIN

END;$$

CREATE TABLE User_Stats(id INT NOT NULL, packs SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  fire INT UNSIGNED NOT NULL DEFAULT 0, air INT UNSIGNED NOT NULL DEFAULT 0, water INT UNSIGNED NOT NULL DEFAULT 0, earth INT UNSIGNED NOT NULL DEFAULT 0,
  light INT UNSIGNED NOT NULL DEFAULT 0, darkness INT UNSIGNED NOT NULL DEFAULT 0, spirit INT UNSIGNED NOT NULL DEFAULT 0, PRIMARY KEY (id));

-- I don't know if I want the database to store the entire battle history or not
CREATE TABLE Battle_Stats (user_id INT NOT NULL, xp INT UNSIGNED NOT NULL DEFAULT 0, wins INT UNSIGNED NOT NULL DEFAULT 0, losses INT UNSIGNED NOT NULL DEFAULT 0, draws INT UNSIGNED NOT NULL DEFAULT 0, PRIMARY KEY (user_id));
CREATE TABLE Battle_Queue (user_id INT NOT NULL, )
CREATE TABLE Stones (id INT UNSIGNED NOT NULL auto_increment, owner_id INT UNSIGNED NOT NULL, mana_type VARCHAR(10) NOT NULL, stone_type VARCHAR(10), energy INT UNSIGNED NOT NULL, PRIMARY KEY (id));

-- Just temporary to try opening packs, etc.
INSERT INTO Users (username, public_key) VALUES ('admin', "----gotta make something up----");
INSERT INTO Battle_Stats (user_id, xp) VALUES (1, 0);

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
		  ELSEIF m_type = 'AIR' THEN UPDATE Users SET air = air + FLOOR(mana_amt) WHERE id = user_id;
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

-- Fuse stones of the same type together. Almost working.
CREATE PROCEDURE fuse_stones(IN id_array VARCHAR(1000))
  READS SQL DATA SQL SECURITY INVOKER
  BEGIN
    DECLARE id_array_local VARCHAR(1000);
    DECLARE start_pos SMALLINT;
    DECLARE comma_pos SMALLINT;
    DECLARE current_id VARCHAR(1000);
    DECLARE end_loop TINYINT;
    DECLARE first_stone BOOL;

	DECLARE o_id INT UNSIGNED DEFAULT 0;
    DECLARE m_type VARCHAR(10);
    DECLARE s_type VARCHAR(10);

    DECLARE total_energy SMALLINT UNSIGNED DEFAULT 0;
    DECLARE error_trigger BOOL;

    SET id_array_local = id_array;
    SET start_pos = 1;
    SET comma_pos = locate(',', id_array_local);
    SET first_stone = TRUE;
    SET error_trigger = FALSE;

    START TRANSACTION;
    REPEAT
         IF comma_pos > 0 THEN
             SET current_id = substring(id_array_local, start_pos, comma_pos - start_pos);
             SET end_loop = 0;
         ELSE
             SET current_id = substring(id_array_local, start_pos);
             SET end_loop = 1;
         END IF;

         SELECT owner_id, mana_type, stone_type, energy INTO @oid, @mt, @st, @en FROM Stones WHERE (id = current_id) GROUP BY id LIMIT 1;

         IF first_stone THEN
             SET first_stone = FALSE;
             SET o_id = @oid;
             SET m_type = @mt;
             SET s_type = @st;
         END IF;

		 IF @oid != o_id OR @mt != m_type OR @st != s_type THEN SET error_trigger = TRUE;
         ELSE
			SET total_energy = total_energy + @en;
            IF total_energy > 240100 THEN SET error_trigger = TRUE;
            ELSE DELETE FROM Stones WHERE id = current_id;
			END IF;
         END IF;
         IF end_loop = 0 THEN
             SET id_array_local = substring(id_array_local, comma_pos + 1);
             SET comma_pos = locate(',', id_array_local);
         END IF;
    UNTIL end_loop = 1 OR error_trigger

    END REPEAT;
    -- If all goes well, add stone and commit data: I wonder if this part actually works...
    IF error_trigger = FALSE THEN
		INSERT INTO Stones (owner_id, mana_type, stone_type, energy) VALUES (owner_id, m_type, s_type, total_energy);
		COMMIT;
	ELSE ROLLBACK; END IF;
END;$$

/* Debating whether or not to add an actual indicator of rarity based on the stone rarity used to create the creature. Rarity could provide other benefits or just create a shiny version.
**
** Right now champions are just tied to the owner, but eventually I really want them tied to Provincial titles.
**   But such actions would require some kind of communication with the blockchain network, which cannot be done through MYSQL - unless I customize MYSQL itself!
*/

CREATE TABLE Champions (id INT UNSIGNED NOT NULL auto_increment, owner_id INT UNSIGNED NOT NULL, energy INT UNSIGNED NOT NULL,
  fire SMALLINT NOT NULL, air SMALLINT NOT NULL, water SMALLINT NOT NULL, earth SMALLINT NOT NULL, light SMALLINT NOT NULL, darkness SMALLINT NOT NULL, spirit SMALLINT NOT NULL,
  speed SMALLINT NOT NULL, strength SMALLINT NOT NULL, dexterity SMALLINT NOT NULL, charisma SMALLINT NOT NULL,
  max_health SMALLINT UNSIGNED NOT NULL, age SMALLINT UNSIGNED NOT NULL DEFAULT 0, health SMALLINT UNSIGNED NOT NULL,
  xp UNSIGNED INT NOT NULL DEFAULT 0, leveled BOOL NOT NULL DEFAULT TRUE,
  PRIMARY KEY (id));

/* Create a champion using mana stones and mana
**
** Uses a combination of a mana stone and mana to craft champions. The more mana used, the better the stats. The better the mana stone used, the better the stats as well.
**
** I still need to create an output variable to return results
**
**
** I should adjust this system so that the min and max stats will be based on the champion's level. As the champion levels up, stats can be rerolled.
**
*/
CREATE PROCEDURE create_champion(IN o_id INT UNSIGNED, IN s_id INT UNSIGNED,
  m_fire INT UNSIGNED, m_air INT UNSIGNED, m_water INT UNSIGNED, m_earth INT UNSIGNED,
  m_light INT UNSIGNED, m_darkness INT UNSIGNED, m_spirit INT UNSIGNED)

  READS SQL DATA SQL SECURITY INVOKER
BEGIN
  DECLARE p_fire SMALLINT;
  DECLARE p_air SMALLINT;
  DECLARE p_water SMALLINT;
  DECLARE p_earth SMALLINT;
  DECLARE p_light SMALLINT;
  DECLARE p_darkness SMALLINT;
  DECLARE p_spirit SMALLINT;
  DECLARE sp SMALLINT;
  DECLARE str SMALLINT;
  DECLARE dex SMALLINT;
  DECLARE cha SMALLINT;
  DECLARE mh SMALLINT;
  DECLARE boost FLOAT;

  SELECT mana_type, stone_type, energy INTO @mt, @st, @en FROM Stones WHERE id = s_id AND owner_id = o_id GROUP BY id LIMIT 1;

  -- Check to make sure there are enough resources.
  SELECT fire >= m_fire AND air >= m_air AND water >= m_water AND earth >= m_earth AND light >= m_light AND darkness >= m_darkness AND spirit >= M_darkness INTO @enough FROM Users WHERE id = u_id GROUP BY id LIMIT 1;
  IF @enough AND @st = 'LIFE' THEN

	-- Delete mana from user's mana pool
    UPDATE Users SET fire = fire - m_fire, air = air - m_air, water = water - m_water, earth = earth - m_earth,  light = light - m_light, darkness = darkness - m_darkness, spirit = spirit - m_spiirt WHERE id = u_id;

    -- Calculate how much power the champion has for each element
    CALL normal(16, @rnd);
    SET boost = LOG(@en) * EXP(@rnd);
    SET p_fire = FLOOR(-50 + boost * LOG(m_fire + 1));
    SET p_air = FLOOR(-50 + boost * LOG(m_air + 1));
    SET p_water = FLOOR(-50 + boost * LOG(m_water + 1));
    SET p_earth = FLOOR(-50 + boost * LOG(m_earth + 1));
    SET p_light = FLOOR(-50 + boost * LOG(m_light + 1));
    SET p_darkness = -50 + boost + LOG(m_darkness + 1);
    SET p_spirit = -50 + boost * LOG(m_spirit + 1);

    -- Adjust power for the type of stone being used
    IF @mt = 'FIRE' THEN SET p_fire = p_fire + 5*LOG(@en);
    ELSEIF @mt = 'AIR' THEN SET p_air = p_air + 5*LOG(@en);
    ELSEIF @mt = 'WATER' THEN SET p_water = p_water + 5*LOG(@en);
    ELSEIF @mt = 'EARTH' THEN SET p_earth = p_earth + 5*LOG(@en);
    ELSEIF @mt = 'LIGHT' THEN SET p_light = p_light + 5*LOG(@en);
    ELSEIF @mt = 'DARKNESS' THEN SET p_darkness = p_darkness + 5*LOG(@en);
    ELSEIF @mt = 'SPIRIT' THEN SEt p_spirit = p_spirit + 5*LOG(@en);
    END IF;

    -- Adjust for cutoffs
    SET @min = FLOOR(-50 + 4 * LOG(@en - 99));
    SET @max = CEIL(150 + 100 * LOG(@en - 99));

    IF p_fire < @min THEN SET p_fire = @min; ELSEIF p_fire > @max THEN SET p_fire = @max; END IF;
    IF p_air < @min THEN SET p_air = @min; ELSEIF p_air > @max THEN SET p_air = @max; END IF;
    IF p_water < @min THEN SET p_water = @min; ELSEIF p_water > @max THEN SET p_water = @max; END IF;
    IF p_earth < @min THEN SET p_earth = @min; ELSEIF p_earth > @max THEN SET p_earth = @max; END IF;
    IF p_light < @min THEN SET p_light = @min; ELSEIF p_light > @max THEN SET p_light = @max; END IF;
    IF p_darkness < @min THEN SET p_darkness = @min; ELSEIF p_darkness > @max THEN SET p_darkness = @max; END IF;
    IF p_spirit < @min THEN SET p_spirit = @min; ELSEIF p_spirit > @max THEN SET p_spirit = @max; END IF;

    CALL normal(16, @rnd);
    SET sp = 25 * @rnd + boost;
    IF sp < @min THEN SET sp = @min; ELSEIF sp > @max THEN SET sp = @max; END IF;

    CALL normal(16, @rnd);
    SET sp = 25 * @rnd + boost;
    IF str < @min THEN SET str = @min; ELSEIF str > @max THEN SET str = @max; END IF;

    CALL normal(16, @rnd);
    SET dex = 25 * @rnd + boost;
    IF dex < @min THEN SET dex = @min; ELSEIF dex > @max THEN SET dex = @max; END IF;

    CALL normal(16, @rnd);
    SET cha = 25 * @rnd + boost;
    IF cha < @min THEN SET cha = @min; ELSEIF cha > @max THEN SET cha = @max; END IF;

    CALL normal(16, @rnd);
    SET mh = 1000 + EXP(@rnd) * (LOG(@en - 99) + 1);

    INSERT INTO Champions (owner_id, energy, fire, air, water, earth, light, darkness, spirit, speed, dexterity, charisma, max_health)
      VALUES (o_id, @en, p_fire, p_air, p_water, p_earth, p_light, p_darkness, p_spirit, sp, dex, cha, mh);

	-- Determine whether stone breaks. These probabilities should be correct.

    CALL normal(32, @rnd);
    IF (@rnd < -2.498 AND @en = 240100) OR
		(@rnd < -2.241 AND @en < 240100 AND @en >= 34300) OR
		(@rnd < -1.96 AND @en < 34300 AND @en >= 4900) OR
		(@rnd < -1.645 AND @en < 4900 AND @en >= 700) OR
        (@rnd < -1.282 AND @en < 700)
			THEN DELETE FROM Stones WHERE id = s_id;
    END IF;
  END IF;
END;$$

-- Champion Leveling

CREATE PROCEDURE level_champion(IN c_id UNSIGNED INT)
READS SQL DATA SQL SECURITY INVOKER
BEGIN

END;$$

/* Generates the actual battle results between two champions
**
** This is the initial version of the battle engine. It doesn't take into account all stats, so it's pure alpha version right now.
**
*/

CREATE PROCEDURE champion_battle(IN first INT UNSIGNED, IN second INT UNSIGNED)
  READS SQL DATA SQL SECURITY INVOKER
  BEGIN

-- Update to have speed rolls random
  CALL normal(32, @rnd1);
  CALL normal(32, @rnd2);
  SELECT c1.speed + @rnd1 > c2.speed + @rnd2 INTO @initiative FROM users c1, users c2 WHERE c1.id = first AND c2.id = SECOND;

  /* Half the difference between the two champion's XP goes to the winner and comes from the loser.
  **
  */

END;$$

/* Battle Queue
** The battle queue is required to ensure that champions will be matched with champions of similar XP
** Method: A user will be able to submit a new battle request to the server. The server will then check to see if there's an appropriate match.
** Each new addition to the queue will wait for a pairing.
** If a pairing cannot be made within a certain amount of time, an automatic event trigger will remove it.
*/

DELIMITER ;
