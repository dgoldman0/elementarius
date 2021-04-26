/* Database Setup
//
// - Users
//   + id
//   + username
//   + XP
//   + packs
//   + fire
//   + air
//   + water
//   + earth
//   + light
//   + darkness
//   + spirit
//
// - Stones
//   + id
//   + owner_id
//   + mana_type
//   + stone_type
//   + energy (total energy - number of crystals that have been merged together)

*/

const MANA_FIRE     = 0;
const MANA_AIR      = 1;
const MANA_WATER    = 2;
const MANA_EARTH    = 3;
const MANA_LIGHT    = 4;
const MANA_DARKNESS = 5;
const MANA_SPIRT    = 6;

const STONE_INSIGHT   = 10;
const STONE_CREATION  = 11;
const STONE_LIFE      = 12;

const RARITY_COMMON     = 20;
const RARITY_UNCOMMON   = 21;
const RARITY_RARE       = 22;
const RARITY_EPIC       = 23;
const RARITY_LEGENDARY  = 24;

// Perform basic DB initialization
function initializeDB() {
  // Make sure the DB isn't already initialized

  // Create tables

  // Create stored procedures

  // Generate an approximately normally distributed random number. I don't even know if I need this. Maybe I can just use random_bytes for everything.

  let normal =
    `CREATE PROCEDURE normal(iterations TINYINT)
    READS SQL DATA SQL SECURITY INVOKER
    BEGIN
      DECLARE total FLOAT;
      DECLARE cnt TINYINT;
      SET total = 0;
      SET cnt = 0;

      WHILE cnt < iterations DO
        // random_bytes is a cryptographically secure random number genreator, so each byte should be an iid. As a result, we can sum them to make them approximately normal.
        SET total = total + ASCII(CAST(random_bytes(1) AS CHAR));
        SET cnt = cnt + 1;
      END WHILE;

      // total will have a mean of 255n/2 and variance of 255n/12
      DECLARE value FLOAT

      // Normalize
      SET value = ((total / 255 / iterations) - 0.5) * sqrt(12)
      SELECT @value
    END`;

  // Generate a pack and distribute it to the user
  let open_pack =
    `CREATE PROCEDURE open_pack(user_id INT)
    READS SQL DATA SQL SECURITY INVOKER
    BEGIN

      DECLARE count TINYINT;
      DECLARE @mana_type TINYINT;

      SET count = 0;

      // I should make sure that a user by user_id actually exists!

      REPEAT
        DECLARE mana_rnd FLOAT;
        DECLARE mana_amt SMALLINT;
        DECLARE @stone_type TINYINT;
        DECLARE stone_energy TINYINT;

        SET mana_amt = 0;
        SET mana_rnd = CALL normal(16);

        // Make sure that the z-scores are correct for one tail!
        IF mana_rnd < -0.8958 THEN
          SET @mana_type = " + ` + MANA_FIRE + `
        ELSE IF mana_rnd < -0.3309 THEN
          SET @mana_type = " + ` + MANA_AIR + `
        ELSE IF mana_rnd < 0.1397 THEN
          SET @mana_type = ` + MANA_WATER + `
        ELSE IF mana_rnd < 0.6456 THEN
          SET @mana_type = ` + MANA_EARTH + `
        ELSE IF mana_rnd < 1.0444 THEN
          SET @mana_type = ` + MANA_LIGHT + `
        ELSE IF mana_rnd < 1.7862 THEN
          SET @mana_type = " + ` + MANA_DARKNESS + `
        ELSE
          SET @mana_type = " + ` + MANA_SPIRIT + `
        END IF

        IF CALL normal(16) > -1.2816 THEN
          // Create mana
          SET mana_amt = EXP(CALL normal(16)) * 100;
          IF mana_amt < 50 THEN mana_amt = 50 ELSE IF mana_amt > 1000 THEN mana_amt = 1000 END IF;

          // Update user's quantity of mana
          IF @mana_type = ` + MANA_FIRE + ` THEN UPDATE Users SET fire = fire + mana_amt;" +
          ELSE IF @mana_type = ` + MANA_AIR + ` THEN UPDATE Users SET fire = air + mana_amt;" +
          ELSE IF @mana_type = ` + MANA_WATER + ` THEN UPDATE Users SET fire = water + mana_amt;" +
          ELSE IF @mana_type = ` + MANA_EARTH + ` THEN UPDATE Users SET fire = earth + mana_amt;" +
          ELSE IF @mana_type = ` + MANA_LIGHT + ` THEN UPDATE Users SET fire = light + mana_amt;" +
          ELSE IF @mana_type = ` + MANA_DARKNESS + ` THEN UPDATE Users SET fire = darkness + mana_amt;" +
          ELSE IF @mana_type = ` + MANA_SPIRIT + ` THEN UPDATE Users SET fire = spirit + mana_amt;" +
          END IF
        ELSE
          // Create a mana stone!

          // Determine what kind of stone should be created
          DECLARE type_rnd FLOAT;
          SET type_rnd = CALL normal(16);

          IF type_rnd < -1.6449 THEN @stone_type = ` + STONE_INSIGHT + `
          ELSE IF type_rnd < -0.6745 THEN @stone_type = ` + STONE_CREATION + `
          ELSE @stone_type = ` + STONE_LIFE + `
          END IF

          // Determine what rarity stone should be created
          DECLARE rarity_rnd FLOAT;
          SET rarity_rnd = CALL normal(16);

          IF rarity_rnd < -3.384196 THEN stone_energy = 100;
          ELSE IF stone_rnd < -2.764 THEN stone_energy = 700;
          ELSE IF stone_rnd < -2.047 THEN stone_energy = 4900;
          ELSE IF stone_rnd < -1.068 THEN stone_energy = 34300;
          ELSE stone_energy = 240100;
          END IF

          // Add new mana stone of the created type to the inventory
          INSERT INTO Stones (owner_id, mana_type, stone_type, energy) VALUES (user_id, @mana_type, @stone_type, stone_energy);

        END IF
        SET count = count + 1
      UNTIL count = 4
      END REPEAT;
    // I want this statement to return a list of the results as well so that it can be presented to the user.
    END`;

  // Method partially taken from https://somedevtips.com/web/mysql-procedure-array-parameter/
  // Still need to convert this code to multiline string for code cleanliness
  let fstones =
    "CREATE PROCEDURE fuse_stones(IN id_list VARCHAR(1000))" +
                "READS SQL DATA SQL SECURITY INVOKER " +
                "BEGIN " +
                  "DECLARE id_list_local VARCHAR(1000);" +
                  "DECLARE start_pos SMALLINT;" +
                  "DECLARE comma_pos SMALLINT;" +
                  "DECLARE current_id VARCHAR(1000);" +
                  "DECLARE end_loop TINYINT;" +
                  "DECLARE first_stone BOOL;" +
                  "DECLARE mana_type TINYINT;" +
                  "DECLARE stone_type TINYINT;" +
                  "DECLARE total_energy SMALLINT;" +
                  "DECLARE error BOOL;" +

                  "SET id_array_local = id_array;" +
                  "SET start_pos = 1;" +
                  "SET comma_pos = locate(',', id_array_local);" +
                  "SET first_stone = TRUE;" +
                  "SET error = FALSE;" + ;

                  "START TRANSACTION;" +
                  "REPEAT " +
                       "IF comma_pos > 0 THEN " +
                           "SET current_id = substring(id_array_local, start_pos, comma_pos - start_pos);" +
                           "SET end_loop = 0;" +
                       "ELSE " +
                           "SET current_id = substring(id_array_local, start_pos);" +
                           "SET end_loop = 1;" +
                       "END IF;" +

                       // If first stone, store mana type and stone type.
                       // Then make sure the next stone in the list is of the same type.
                       // Finally start adding stone energy together or throw error if not same type.
                       // I need to figure out how to terminate the loop and throw a catch
                       "SELECT mana_type AS mt, stone_type AS st, energy FROM Stones WHERE (id = current_id);" +

                       "IF first_stone THEN " +
                           "SET first_stone = FALSE" +
                           "SET mana_type = mt" +
                           "SET stone_type = st" +
                       "END IF " +

                       "IF end_loop = 0 THEN " +
                           "SET id_array_local = substring(id_array_local, comma_pos + 1);" +
                           "SET comma_pos = locate(',', id_array_local);" +
                       "END IF;" +
                  "UNTIL end_loop = 1" +

                  "END REPEAT;" +
                  "IF error = FALSE THEN COMMIT ELSE ROLLBACK" + // If all goes well, commit data
                "END";
}

// Create a new user for the game
function newUser() {

}

// Create the contents of a pack.
function generatePack() {

}

// Create the contents of a slot for a pack.
function generateSlot() {

}

// Create a mana stone from mana
function createStone() {

}

// Fuse mana stones
function fuseStones(for_user, stone_list) {

}
