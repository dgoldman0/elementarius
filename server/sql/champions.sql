/* Debating whether or not to add an actual indicator of rarity based on the stone rarity used to create the creature. Rarity could provide other benefits or just create a shiny version.
**
** Right now champions are just tied to the owner, but eventually I really want them tied to Provincial titles.
**   But such actions would require some kind of communication with the blockchain network, which cannot be done through MYSQL - unless I customize MYSQL itself!
*/

USE elementarius_game;

DELIMITER $$

CREATE TABLE Champions (id INT UNSIGNED NOT NULL auto_increment, owner_id INT UNSIGNED NOT NULL, energy INT UNSIGNED NOT NULL,
  fire SMALLINT NOT NULL, air SMALLINT NOT NULL, water SMALLINT NOT NULL, earth SMALLINT NOT NULL, light SMALLINT NOT NULL, darkness SMALLINT NOT NULL, spirit SMALLINT NOT NULL,
  speed SMALLINT NOT NULL, strength SMALLINT NOT NULL, dexterity SMALLINT NOT NULL, charisma SMALLINT NOT NULL,
  max_health SMALLINT UNSIGNED NOT NULL, age SMALLINT UNSIGNED NOT NULL DEFAULT 0, health SMALLINT UNSIGNED NOT NULL,
  xp INT UNSIGNED NOT NULL DEFAULT 0, leveled BOOL NOT NULL DEFAULT TRUE,
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

CREATE PROCEDURE level_champion(IN c_id INT UNSIGNED)
READS SQL DATA SQL SECURITY INVOKER
BEGIN

END;$$

/* Generates the actual battle results between two champions
**
** This is the initial version of the battle engine. It doesn't take into account all stats, so it's pure alpha version right now.
**
*/

CREATE PROCEDURE battle(IN first INT UNSIGNED, IN second INT UNSIGNED)
  READS SQL DATA SQL SECURITY INVOKER
  BEGIN

  -- Determine who goes first.

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

CREATE TABLE Battle_Queue (user_id INT NOT NULL, champion_id INT NOT NULL);

CREATE TRIGGER check_queue BEFORE INSERT ON Battle_Queue
  BEGIN

  -- Check if this champion is already fighting. If it is, don't let it fight again.

  -- See if there's a champion waiting that matches well with the current champion.

  -- If so, remove the old battle request from the queue and trigger match

  -- If not, add the new request to the queue and create a timer to remove the request after timeout
END

DELIMITER ;