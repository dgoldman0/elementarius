/* Database Setup
//
// - Users
//   + id
//   + username
//   + XP
//   + packs
//   + fire
//   + earth
//   + water
//   + air
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

/*

// Perform basic DB initialization
function initializeDB() {
  // Make sure the DB isn't already initialized

  // Create tables

  // Create stored programs
  // Method partially taken from https://somedevtips.com/web/mysql-procedure-array-parameter/
  let fstones = "CREATE PROCEDURE fuse_stones(IN id_list VARCHAR(1000))" +
                "READS SQL DATA SQL SECURITY INVOKER" +
                "BEGIN" +
                  "DECLARE id_list_local VARCHAR(1000)" +
                  "DECLARE start_pos SMALLINT" +
                  "DECLARE comma_pos SMALLINT" +
                  "DECLARE current_id VARCHAR(1000)" +
                  "DECLARE end_loop TINYINT" +
                  "DECLARE first_stone BOOL" +
                  "DECLARE mana_type TINYINT" +
                  "DECLARE stone_type TINYINT" +
                  "DECLARE total_energy SMALLINT" +

                  "SET id_array_local = id_array;" +
                  "SET start_pos = 1;" +
                  "SET comma_pos = locate(',', id_array_local);" +
                  "SET first_stone = TRUE;" +

                  "BEGIN TRY"
                    "REPEAT" +
                         "IF comma_pos > 0 THEN" +
                             "SET current_id = substring(id_array_local, start_pos, comma_pos - start_pos);" +
                             "SET end_loop = 0;" +
                         "ELSE" +
                             "SET current_id = substring(id_array_local, start_pos);" +
                             "SET end_loop = 1;" +
                         "END IF;" +

                         // If first stone, store mana type and stone type.
                         // Then make sure the next stone in the list is of the same type.
                         // Finally start adding stone energy together or throw error if not same type.
                         // I need to figure out how to terminate the loop and throw a catch
                         "SELECT mana_type AS mt, stone_type AS st, energy FROM Stones WHERE (id = current_id);" +

                         "IF first_stone THEN" +
                             "SET first_stone = FALSE" +
                             "SET mana_type = mt" +
                             "SET stone_type = st" +
                         "END IF" +

                         "IF end_loop = 0 THEN" +
                             "SET id_array_local = substring(id_array_local, comma_pos + 1);" +
                             "SET comma_pos = locate(',', id_array_local);" +
                         "END IF;" +
                    "UNTIL end_loop = 1" +

                    "END REPEAT;" +
                    "COMMIT" + // If all goes well, commit data
                   "END TRY";
                "END";

  // Generate a pack and distribute it to the user
  let open_pack = "CREATE PROCEDURE open_pack(user_id INT)" +
                "READS SQL DATA SQL SECURITY INVOKER" +
                "BEGIN" +

                // I want this statement to return a list of the results as well so that it can be presented to the user.
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
