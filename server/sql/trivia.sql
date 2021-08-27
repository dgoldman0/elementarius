USE elementarius_game;

DELIMITER $$

-- The list of questions, and the correct answer
CREATE TABLE Questions(id INT UNSIGNED NOT NULL auto_increment, question VARCHAR(256) NOT NULL, correct_answer VARCHAR(256) NOT NULL, PRIMARY KEY (id));

-- The list of all answers related to a question w/ question_id
CREATE TABLE Answers(id INT UNSIGNED NOT NULL auto_increment, question_id INT UNSIGNED NOT NULL, answer VARCHAR(256) NOT NULL, PRIMARY KEY (id));

-- Selects a question and creates the session variables, including the timestamp of when the question was requested
CREATE PROCEDURE request_question(OUT question VARCHAR(256))
  READS SQL DATA SQL SECURITY INVOKER
  BEGIN

  /* Will require check if logged in soon, but I'll skip authentication for now.
  IF @session THEN
    -- Check if there is a question set up
    IF @question_active THEN
    ELSE
      -- Set up question for user
    END IF;
  ELSE
  END IF;
  */
  SELECT id, question INTO @id, @question FROM Questions ORDER BY RAND() LIMIT 1;
  SET @q_id = @id;
  SET @question_active = TRUE;
  SET question = @question;
  -- Set time limit
  -- After time has elapsed, penalize user


  SELECT @question;
  
END;$$

CREATE PROCEDURE get_question_options(IN qid INT UNSIGNED)
  READS SQL DATA SQL SECURITY INVOKER
  BEGIN
  
  IF @question_active THEN 
	SELECT answer FROM Answers WHERE question_id = @q_id;
  END IF;
END;$$

CREATE PROCEDURE answer_question(IN answer VARCHAR(256))
  READS SQL DATA SQL SECURITY INVOKER
  BEGIN

  -- Check if there is a question set up
  IF @question_active THEN
   
   SELECT correct_answer = answer INTO @correct FROM Questions;
   
  ELSE
   -- Figure way to return error
   SELECT * FROM nothing;
  END IF;
END;$$

DELIMITER ;
