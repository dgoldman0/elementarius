/* Initialization Script
**
** Handles the creation of tables and stored procedures.
** Much of the mechanics for this game, including pack generation and champion creation occurs using stored procedures rather than external code.
*/

/* Notes
** z-scores are almost certainly not right. I just did area z < z' = p, without taking into account that the area includes the area of the previous probability.
** It's an easy fix. I just need to recalculate the z-scores properly.
**
** I think I want to ensure that I revoke all privileges for anonymous access, and then grant specific execute privileges to SPs that should be publicly accessible
*/

DROP DATABASE IF EXISTS elementarius_game; -- This line is just to delete old versions while working on the coding. It'll be gone in the final initialization script.
CREATE DATABASE elementarius_game;

USE elementarius_game;

DELIMITER $$

/* User Authentication Framework
**
** Not operational for now. I'll figure it out at a later time, or maybe just skip it and create a very minimal interface in Node. 
** 
** User authentication mirrors blockchain authentication. To sign in, a person will have to sign a chellenge message with their private key (RSA).
**
** This system could be used for any project really. Indeed, it could be replaced with an actual plugin, though this does fine, I think.
** RSA public key in DER format is 540 hex characters
*/
CREATE TABLE Users (id INT NOT NULL auto_increment, username VARCHAR(60) NOT NULL, public_key VARCHAR(540) NOT NULL, PRIMARY KEY (id), UNIQUE KEY (username), UNIQUE KEY (public_key));

CREATE PROCEDURE register_user(IN username VARCHAR(60), IN pubkey VARCHAR(540))
  READS SQL DATA SQL SECURITY INVOKER
  BEGIN

  -- Make sure the key is formatted correctly (that it's a proper RSA public key)
END;$$

-- GRANT EXECUTE ON register_user TO ''@'%';

CREATE PROCEDURE request_challenge(IN uid INT UNSIGNED)
  READS SQL DATA SQL SECURITY INVOKER
  BEGIN

  SET @requested_id = uid;
END;$$

-- GRANT EXECUTE ON request_challenge TO ''@'%';

-- Authenticate user, called after request_challenge
CREATE PROCEDURE authenticate_user(IN response TINYBLOB)
  READS SQL DATA SQL SECURITY INVOKER
  BEGIN

  -- If authenticated, create a session

  SET @uid = @requested_id;

END;$$

-- GRANT EXECUTE ON authenticate_user TO ''@'%';

CREATE TABLE User_Stats(id INT NOT NULL, packs SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  fire INT UNSIGNED NOT NULL DEFAULT 0, air INT UNSIGNED NOT NULL DEFAULT 0, water INT UNSIGNED NOT NULL DEFAULT 0, earth INT UNSIGNED NOT NULL DEFAULT 0,
  light INT UNSIGNED NOT NULL DEFAULT 0, darkness INT UNSIGNED NOT NULL DEFAULT 0, spirit INT UNSIGNED NOT NULL DEFAULT 0, PRIMARY KEY (id));

-- I don't know if I want the database to store the entire battle history or not
CREATE TABLE Battle_Stats (user_id INT NOT NULL, xp INT UNSIGNED NOT NULL DEFAULT 0, wins INT UNSIGNED NOT NULL DEFAULT 0, losses INT UNSIGNED NOT NULL DEFAULT 0, draws INT UNSIGNED NOT NULL DEFAULT 0, PRIMARY KEY (user_id));
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
DELIMITER ;