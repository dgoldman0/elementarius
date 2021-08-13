USE elementarius_game;

DELIMITER $$

CREATE TABLE questions();

-- Selects a question and creates the session variables, including the timestamp of when the question was requested
CREATE PROCEDURE request_question()
  READS SQL DATA SQL SECURITY INVOKER
  BEGIN

  -- Check logged in
  IF @session THEN
    -- Check if there is a question set up
    IF @question_active THEN
    ELSE
      -- Set up question for user
    END IF;
  ELSE
  END IF;
END;$$

CREATE PROCEDURE answer_question()
  READS SQL DATA SQL SECURITY INVOKER
  BEGIN

  -- Check if there is a question set up
  IF @question_active THEN
  ELSE
  END IF;
END;$$

DELIMITER ;
