-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Εξυπηρετητής: 127.0.0.1
-- Χρόνος δημιουργίας: 11 Ιαν 2024 στις 17:22:23
-- Έκδοση διακομιστή: 10.4.32-MariaDB
-- Έκδοση PHP: 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Βάση δεδομένων: `ludo_game`
--

DELIMITER $$
--
-- Διαδικασίες
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `checkPoint` (IN `newX` INT, IN `newY` INT)   BEGIN
    DECLARE other_piece VARCHAR(255);
    DECLARE p, p_color, piece_val VARCHAR(3);
    DECLARE oldXspot_of_other_piece , oldYspot_of_other_piece , destx, desty  INT;
     
    SET destx=newX ;
    SET desty=newY ;

    SELECT destx, desty;

    SELECT piece, oldX, oldY
    INTO other_piece, oldXspot_of_other_piece, oldYspot_of_other_piece
    FROM dice
    WHERE oldXspot_of_other_piece = destx AND oldYspot_of_other_piece = desty 
    LIMIT 1;

    CASE other_piece
        WHEN 'Y1' THEN
            CALL movePiece(destx, desty, 2, 3);
        WHEN 'Y2' THEN
            CALL movePiece(destx, desty, 3, 3);
        WHEN 'Y3' THEN
            CALL movePiece(destx, desty, 2, 2);
        WHEN 'Y4' THEN
            CALL movePiece(destx, desty, 3, 2);
        WHEN 'R1' THEN
            CALL movePiece(destx, desty, 9, 10);
        WHEN 'R2' THEN
            CALL movePiece(destx, desty, 10, 10);
        WHEN 'R3' THEN
            CALL movePiece(destx, desty, 9, 9);
        WHEN 'R4' THEN
            CALL movePiece(destx, desty, 10, 9);
    END CASE;

    UPDATE dice
    SET
        oldX = destx,
        oldY = desty,
        newX = CASE other_piece
                    WHEN 'Y1' THEN 2
                    WHEN 'Y2' THEN 3
                    WHEN 'Y3' THEN 2
                    WHEN 'Y4' THEN 3
                    WHEN 'R1' THEN 9
                    WHEN 'R2' THEN 10
                    WHEN 'R3' THEN 9
                    WHEN 'R4' THEN 10
               END,
        newY = CASE other_piece
                    WHEN 'Y1' THEN 3
                    WHEN 'Y2' THEN 3
                    WHEN 'Y3' THEN 2
                    WHEN 'Y4' THEN 2
                    WHEN 'R1' THEN 10
                    WHEN 'R2' THEN 10
                    WHEN 'R3' THEN 9
                    WHEN 'R4' THEN 9
               END
    WHERE piece = other_piece;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `checkTurn` ()   BEGIN
    DECLARE currentPlayerColor INT;
    DECLARE countRedPlayers INT;
    DECLARE countYellowPlayers INT;
    DECLARE countGreenPlayers INT;
    DECLARE countblackPlayers INT;

    DECLARE redPlayerExists INT;
    DECLARE yellowPlayerExists INT;
    DECLARE greenPlayerExists INT;
    DECLARE blackPlayerExists INT;

    DECLARE countTotalPlayers INT;

    SELECT COUNT(*) INTO countRedPlayers FROM game_status WHERE p_turn = 'R';
    SELECT COUNT(*) INTO countYellowPlayers FROM game_status WHERE p_turn = 'Y';
    SELECT COUNT(*) INTO countGreenPlayers FROM game_status WHERE p_turn = 'G';
    SELECT COUNT(*) INTO countblackPlayers FROM game_status WHERE p_turn = 'B';

    SELECT COUNT(*) INTO redPlayerExists FROM players WHERE piece_color = 'R' AND username IS NOT NULL;
    SELECT COUNT(*) INTO yellowPlayerExists FROM players WHERE piece_color = 'Y' AND username IS NOT NULL;
    SELECT COUNT(*) INTO greenPlayerExists FROM players WHERE piece_color = 'G' AND username IS NOT NULL;
    SELECT COUNT(*) INTO blackPlayerExists FROM players WHERE piece_color = 'B' AND username IS NOT NULL;

    SELECT COUNT(*) INTO countTotalPlayers FROM players WHERE username IS NOT NULL;

    -- If it is the turn of the red player
    IF(countRedPlayers = 1) THEN 
        -- If the total number of players is 2
        IF (countTotalPlayers = 2) THEN
            -- If it is the turn of the red player and the yellow and green players exist in the game
            IF (yellowPlayerExists = 1) THEN
                UPDATE game_status SET p_turn = 'Y' WHERE p_turn = 'R';
            END IF;

            -- If it is the turn of the red player and the blue player exists in the game
            IF (blackPlayerExists = 1) THEN
                UPDATE game_status SET p_turn = 'B' WHERE p_turn = 'R';
            END IF;

            -- If it is the turn of the red player and the green player exists in the game
            IF (greenPlayerExists = 1) THEN
                UPDATE game_status SET p_turn = 'G' WHERE p_turn = 'R';
            END IF;
        END IF;

        -- If the total number of players is 3 and the red, yellow, and green players exist
        IF (countTotalPlayers = 3) THEN
            IF (yellowPlayerExists = 1 AND greenPlayerExists = 1) THEN
                UPDATE game_status SET p_turn = 'G' WHERE p_turn = 'R';
            END IF;

            IF (yellowPlayerExists = 1 AND blackPlayerExists = 1) THEN
                UPDATE game_status SET p_turn = 'Y' WHERE p_turn = 'R';
            END IF;

            IF (blackPlayerExists = 1 AND greenPlayerExists = 1) THEN
                UPDATE game_status SET p_turn = 'G' WHERE p_turn = 'R';
            END IF;
        END IF;

        -- If the total number of players is 4
        IF (countTotalPlayers = 4) THEN
            UPDATE game_status SET p_turn = 'G' WHERE p_turn = 'R';
        END IF;
    END IF;

    -- If it is the turn of the yellow player
    IF(countYellowPlayers = 1) THEN 
        -- If the total number of players is 2
        IF (countTotalPlayers = 2) THEN
            -- If the yellow player's turn and only the blue and red players exist in the game
            IF (blackPlayerExists = 1) THEN UPDATE game_status SET p_turn='B' WHERE p_turn='Y';  END IF;

            -- If the yellow player's turn and only the red and green players exist in the game
            IF (redPlayerExists = 1) THEN UPDATE game_status SET p_turn='R' WHERE p_turn='Y';  END IF;

            -- If the yellow player's turn and only the green and blue players exist in the game
            IF (greenPlayerExists = 1) THEN UPDATE game_status SET p_turn='G' WHERE p_turn='Y';  END IF;
        END IF;

        -- If the total number of players is 3
        IF (countTotalPlayers = 3) THEN
            -- If the yellow player's turn and both the blue and green players exist
            IF (blackPlayerExists = 1 AND greenPlayerExists = 1) THEN UPDATE game_status SET p_turn = 'B' WHERE p_turn = 'Y'; END IF;

            -- If the yellow player's turn and both the blue and red players exist
            IF (blackPlayerExists = 1 AND redPlayerExists = 1) THEN UPDATE game_status SET p_turn = 'B' WHERE p_turn = 'Y'; END IF; 

            -- If the yellow player's turn and both the red and green players exist
            IF (redPlayerExists = 1 AND greenPlayerExists = 1) THEN UPDATE game_status SET p_turn = 'R' WHERE p_turn = 'Y'; END IF;
        END IF;

        -- If the total number of players is 4
        IF (countTotalPlayers = 4) THEN
            UPDATE game_status SET p_turn = 'B' WHERE p_turn = 'Y';
        END IF;
    END IF;

    -- If it is the turn of the green player
    IF(countGreenPlayers = 1) THEN 
        -- If the total number of players is 2
        IF (countTotalPlayers = 2) THEN
            -- If the green player's turn and only the blue and yellow players exist in the game
            IF (blackPlayerExists = 1) THEN UPDATE game_status SET p_turn='B' WHERE p_turn='G';  END IF;

            -- If the green player's turn and only the red and yellow players exist in the game
            IF (redPlayerExists = 1) THEN UPDATE game_status SET p_turn='R' WHERE p_turn='G';  END IF;

            -- If the green player's turn and only the red and yellow players exist in the game
            IF (yellowPlayerExists = 1) THEN UPDATE game_status SET p_turn='Y' WHERE p_turn='G';  END IF;
        END IF;

        -- If the total number of players is 3
        IF (countTotalPlayers = 3) THEN
            -- If the green player's turn and both the blue and yellow players exist
            IF (blackPlayerExists = 1 AND yellowPlayerExists = 1) THEN UPDATE game_status SET p_turn = 'B' WHERE p_turn = 'G'; END IF;

            -- If the green player's turn and both the blue and red players exist
            IF (blackPlayerExists = 1 AND redPlayerExists = 1) THEN UPDATE game_status SET p_turn = 'R' WHERE p_turn = 'G'; END IF; 

            -- If the green player's turn and both the red and yellow players exist
            IF (redPlayerExists = 1 AND yellowPlayerExists = 1) THEN UPDATE game_status SET p_turn = 'R' WHERE p_turn = 'G'; END IF;
        END IF;

        -- If the total number of players is 4
        IF (countTotalPlayers = 4) THEN
            UPDATE game_status SET p_turn = 'Y' WHERE p_turn = 'G';
        END IF;
    END IF;

    -- If it is the turn of the blue player
    IF(countblackPlayers = 1) THEN 
        -- If the total number of players is 2
        IF (countTotalPlayers = 2) THEN
            -- If the blue player's turn and only the green and yellow players exist in the game
            IF (greenPlayerExists = 1) THEN UPDATE game_status SET p_turn='G' WHERE p_turn='B';  END IF;

            -- If the blue player's turn and only the red and yellow players exist in the game
            IF (redPlayerExists = 1) THEN UPDATE game_status SET p_turn='R' WHERE p_turn='B';  END IF;

            -- If the blue player's turn and only the red and yellow players exist in the game
            IF (yellowPlayerExists = 1) THEN UPDATE game_status SET p_turn='Y' WHERE p_turn='B';  END IF;
        END IF;

        -- If the total number of players is 3
        IF (countTotalPlayers = 3) THEN
            -- If the blue player's turn and both the green and yellow players exist
            IF (greenPlayerExists = 1 AND yellowPlayerExists = 1) THEN UPDATE game_status SET p_turn = 'G' WHERE p_turn = 'B'; END IF;

            -- If the blue player's turn and both the green and red players exist
            IF (greenPlayerExists = 1 AND redPlayerExists = 1) THEN UPDATE game_status SET p_turn = 'R' WHERE p_turn = 'B'; END IF; 

            -- If the blue player's turn and both the red and yellow players exist
            IF (redPlayerExists = 1 AND yellowPlayerExists = 1) THEN UPDATE game_status SET p_turn = 'R' WHERE p_turn = 'B'; END IF;
        END IF;

        -- If the total number of players is 4
        IF (countTotalPlayers = 4) THEN
            UPDATE game_status SET p_turn = 'R' WHERE p_turn = 'B';  
        END IF;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `checkWinner` ()   BEGIN
    DECLARE yellowWinCount INT;
    DECLARE redWinCount INT;
    DECLARE blackWinCount INT;
    DECLARE greenWinCount INT;

    SELECT DISTINCT COUNT(*) INTO yellowWinCount FROM yellowwin;
    SELECT DISTINCT COUNT(*) INTO redWinCount FROM redwin;
    SELECT DISTINCT COUNT(*) INTO blackWinCount FROM blackwin;
    SELECT DISTINCT COUNT(*) INTO greenWinCount FROM greenwin;

    IF yellowWinCount = 4 THEN
        UPDATE game_status SET `status` ='ended' , result='Y';
    END IF;

    IF redWinCount = 4 THEN
        UPDATE game_status SET `status` ='ended' , result='R';
    END IF;

    IF blackWinCount = 4 THEN
        UPDATE game_status SET `status` ='ended' , result='B';
    END IF;

    IF greenWinCount = 4 THEN
        UPDATE game_status SET `status` ='ended' , result='G';
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `cleanBoard` ()   BEGIN
	REPLACE INTO  board SELECT * FROM  board_empty;
	
	
	DELETE FROM dice;
	  INSERT INTO dice(oldX, oldY, newX, newY, created_at ,p_turn, dice, piece)
        VALUES (2, 3, 5, 2,NULL, 'Y', 0, 'Y1'),
        (3,3,5,2,NULL,'Y',0,'Y2'),
        (2,2,5,2,NULL,'Y',0,'Y3'),
        (3,2,5,2,NULL,'Y',0,'Y4'),
        
        (2, 10, 2, 7,NULL, 'G', 0, 'G1'),
		  (3, 10, 2, 7,NULL, 'G', 0, 'G2'),
		  (2, 9, 2, 7,NULL, 'G', 0, 'G3'),
		  (3, 9, 2, 7,NULL, 'G', 0, 'G4'),
		  
		          (9, 3, 10, 5,NULL, 'B', 0, 'B1'),
		  (10, 3, 10, 5,NULL, 'B', 0, 'B2'),
		  (9, 2, 10, 5,NULL, 'B', 0, 'B3'),
		  (10, 2, 10, 5,NULL, 'B', 0, 'B4'),
        
 (9,10,7,10,NULL,'R',0,'R1'),
        (10,10,7,10,NULL,'R',0,'R2'),
        (9,9,7,10,NULL,'R',0,'R3'),
        (10,9,7,10,NULL,'R',0,'R4');
   		DELETE FROM yellowwin;
   		DELETE FROM redwin;
   				DELETE FROM greenwin;
   		DELETE FROM blackwin;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `cleanPlayers` ()   BEGIN
	REPLACE INTO  players SELECT * FROM players_empty;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `highlightB1` ()   BEGIN
SELECT b.x, b.y, b.b_path
FROM board b
JOIN dice d ON b.b_path >= d.oldPath AND b.b_path <= ( d.newPath)
WHERE d.piece='B1'
ORDER BY b.b_path ASC; 

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `highlightB2` ()   BEGIN
SELECT b.x, b.y, b.b_path
FROM board b
JOIN dice d ON b.b_path >= d.oldPath AND b.b_path <= ( d.newPath)
WHERE d.piece='B2'
ORDER BY b.b_path ASC; 

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `highlightB3` ()   BEGIN
SELECT b.x, b.y, b.b_path
FROM board b
JOIN dice d ON b.b_path >= d.oldPath AND b.b_path <= ( d.newPath)
WHERE d.piece='B3'
ORDER BY b.b_path ASC; 

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `highlightB4` ()   BEGIN
SELECT b.x, b.y, b.b_path
FROM board b
JOIN dice d ON b.b_path >= d.oldPath AND b.b_path <= ( d.newPath)
WHERE d.piece='B4'
ORDER BY b.b_path ASC; 

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `highlightG1` ()   BEGIN
SELECT b.x, b.y, b.g_path
FROM board b
JOIN dice d ON b.g_path >= d.oldPath AND b.g_path <= ( d.newPath)
WHERE d.piece='G1'
ORDER BY b.g_path ASC; 

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `highlightG2` ()   BEGIN
SELECT b.x, b.y, b.g_path
FROM board b
JOIN dice d ON b.g_path >= d.oldPath AND b.g_path <= ( d.newPath)
WHERE d.piece='G2'
ORDER BY b.g_path ASC; 

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `highlightG3` ()   BEGIN
SELECT b.x, b.y, b.g_path
FROM board b
JOIN dice d ON b.g_path >= d.oldPath AND b.g_path <= ( d.newPath)
WHERE d.piece='G3'
ORDER BY b.g_path ASC; 

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `highlightG4` ()   BEGIN
SELECT b.x, b.y, b.g_path
FROM board b
JOIN dice d ON b.g_path >= d.oldPath AND b.g_path <= ( d.newPath)
WHERE d.piece='G4'
ORDER BY b.g_path ASC; 

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `highlightR1` ()   BEGIN
SELECT b.x, b.y, b.r_path
FROM board b
JOIN dice d ON b.r_path >= d.oldPath AND b.r_path <= ( d.newPath)
WHERE d.piece='R1'
ORDER BY b.r_path ASC; 

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `highlightR2` ()   BEGIN
SELECT b.x, b.y, b.r_path
FROM board b
JOIN dice d ON b.r_path >= d.oldPath AND b.r_path <= ( d.newPath)
WHERE d.piece='R2'
ORDER BY b.r_path ASC;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `highlightR3` ()   BEGIN
SELECT b.x, b.y, b.r_path
FROM board b
JOIN dice d ON b.r_path >= d.oldPath AND b.r_path <= ( d.newPath)
WHERE d.piece='R3'
ORDER BY b.r_path ASC;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `highlightR4` ()   BEGIN
SELECT b.x, b.y, b.r_path
FROM board b
JOIN dice d ON b.r_path >= d.oldPath AND b.r_path <= ( d.newPath)
WHERE d.piece='R4'
ORDER BY b.r_path ASC;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `highlightY1` ()   BEGIN
SELECT b.x, b.y, b.y_path
FROM board b
JOIN dice d ON b.y_path >= d.oldPath AND b.y_path <= ( d.newPath)
WHERE d.piece='Y1'
ORDER BY b.y_path ASC;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `highlightY2` ()   BEGIN
SELECT b.x, b.y, b.y_path
FROM board b
JOIN dice d ON b.y_path >= d.oldPath AND b.y_path <= ( d.newPath)
WHERE d.piece='Y2'
ORDER BY b.y_path ASC;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `highlightY3` ()   BEGIN
SELECT b.x, b.y, b.y_path
FROM board b
JOIN dice d ON b.y_path >= d.oldPath AND b.y_path <= ( d.newPath)
WHERE d.piece='Y3'
ORDER BY b.y_path ASC;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `highlightY4` ()   BEGIN
SELECT b.x, b.y, b.y_path
FROM board b
JOIN dice d ON b.y_path >= d.oldPath AND b.y_path <= ( d.newPath)
WHERE d.piece='Y4'
ORDER BY b.y_path ASC;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `movePiece` (IN `x1` INT, IN `y1` INT, IN `x2` INT, IN `y2` INT)   BEGIN
    DECLARE p, p_color, piece_val VARCHAR(3);
    DECLARE color_val ENUM('R','G','B','Y');
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
           ROLLBACK;
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'An error occurred, transaction rolled back.';
    END;
    START TRANSACTION;
    SELECT piece, piece_color INTO p, p_color
    FROM `board`
WHERE x = x1 AND y = y1;
 IF p IS NOT NULL AND (p_color IN ('Y', 'R', 'G', 'B')) THEN    -- Move the piece to the destination coordinates
    UPDATE `board`
    SET piece = NULL, piece_color = NULL
    WHERE x = x1 AND y = y1;
COMMIT;
    UPDATE `board`
    SET piece = p, piece_color = p_color
    WHERE x = x2 AND y = y2;
    COMMIT;
    ELSE
    ROLLBACK;
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Piece does not exist at the specified coordinates.';
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `resetStatus` ()   BEGIN
    UPDATE game_status
    SET status = 'started'
    WHERE status = 'ended';
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `returnLosers` ()   BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE missingPiece VARCHAR(10);

       DECLARE allPiecesCursor CURSOR FOR
        SELECT 'G1' UNION SELECT 'G2' UNION SELECT 'G3' UNION SELECT 'G4'
        UNION SELECT 'B1' UNION SELECT 'B2' UNION SELECT 'B3' UNION SELECT 'B4'
      UNION  SELECT 'Y1' UNION SELECT 'Y2' UNION SELECT 'Y3' UNION SELECT 'Y4'
        UNION SELECT 'R1' UNION SELECT 'R2' UNION SELECT 'R3' UNION SELECT 'R4';
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    OPEN allPiecesCursor;
    read_loop: LOOP
        FETCH allPiecesCursor INTO missingPiece;
       IF NOT EXISTS (SELECT 1 FROM board WHERE piece = missingPiece) 
    THEN
		    IF missingPiece LIKE 'Y1' THEN
                 UPDATE   board  
                 SET piece_color='Y', piece= 'Y1', y_path= NULL,b_path =NULL,r_path =NULL,g_path= NULL
WHERE  X=2  AND  y=3;			 
ELSEIF missingPiece LIKE 'Y2' THEN
UPDATE   board  
SET piece_color='Y', piece= 'Y2', y_path= NULL,b_path =NULL,r_path =NULL,g_path= NULL
					 WHERE  X=3  AND y=3    ;
          

   ELSEIF missingPiece LIKE 'Y3' THEN
    UPDATE   board  
			     	   SET piece_color='Y', piece= 'Y3', y_path= NULL,b_path =NULL,r_path =NULL,g_path= NULL
					 WHERE  X=2  AND Y=2    ;
   ELSEIF missingPiece LIKE 'Y4' THEN
    UPDATE   board  
			        SET piece_color='Y', piece= 'Y4', y_path= NULL,b_path =NULL,r_path =NULL,g_path= NULL
					 WHERE  X=3  AND Y=2    ;

       	 -- an efage antipalos  pioni tou kokkinou
			    
           ELSEIF missingPiece LIKE 'R1' THEN
 UPDATE   board  
                  SET piece_color='R', piece= 'R1', y_path= NULL,b_path =NULL,r_path =NULL,g_path= NULL
					 WHERE  X=9  AND Y=10    ;

 ELSEIF missingPiece LIKE 'R2' THEN
 UPDATE   board  
                 SET piece_color='R', piece= 'R2', y_path= NULL,b_path =NULL,r_path =NULL,g_path= NULL
					 WHERE  X=10  AND Y=10    ;

 ELSEIF missingPiece LIKE 'R3' THEN
 UPDATE   board  
                SET piece_color='R', piece= 'R3', y_path= NULL,b_path =NULL,r_path =NULL,g_path= NULL
WHERE  X=9  AND Y=9;	 
 ELSEIF missingPiece LIKE 'R4' THEN
 UPDATE   board  
 SET piece_color='R', piece= 'R1', y_path= NULL,b_path =NULL,r_path =NULL,g_path= NULL
WHERE  X=10 AND Y=9;
ELSEIF missingPiece LIKE 'G1' THEN
 UPDATE   board  
SET piece_color='G', piece= 'G1', y_path= NULL,b_path =NULL,r_path =NULL,g_path= NULL
WHERE  X=2  AND Y=10;
ELSEIF missingPiece LIKE 'G2' THEN
 UPDATE   board  
 SET piece_color='G', piece= 'G2', y_path= NULL,b_path =NULL,r_path =NULL,g_path= NULL
 WHERE  X=3  AND Y=10 ;	
 ELSEIF missingPiece LIKE 'G3' THEN
 UPDATE   board  
 SET piece_color='G', piece= 'G3', y_path= NULL,b_path =NULL,r_path =NULL,g_path= NULL
WHERE  X=2  AND Y=9    ;	
ELSEIF missingPiece LIKE 'G4' THEN
UPDATE   board  
SET piece_color='G', piece= 'G4', y_path= NULL,b_path =NULL,r_path =NULL,g_path= NULL
 WHERE  X=3  AND Y=9;	   
ELSEIF missingPiece LIKE 'B1' THEN
UPDATE   board  
SET piece_color='B', piece= 'B1', y_path= NULL,b_path =NULL,r_path =NULL,g_path= NULL
WHERE  X=9  AND Y=3 ; 						ELSEIF missingPiece LIKE 'B2' THEN
UPDATE   board  
SET piece_color='B', piece= 'B2', y_path= NULL,b_path =NULL,r_path =NULL,g_path= NULL
 WHERE  X=10  AND Y=3;	
 ELSEIF missingPiece LIKE 'B3' THEN
 UPDATE   board  
SET piece_color='B', piece= 'B3', y_path= NULL,b_path =NULL,r_path =NULL,g_path= NULL
 WHERE  X=9  AND Y=2;	
ELSEIF missingPiece LIKE 'B4' THEN
 UPDATE   board  
 SET piece_color='B', piece= 'B4', y_path= NULL,b_path =NULL,r_path =NULL,g_path= NULL
	WHERE  X=10 AND Y=2    ;		  	  
		END IF;		   
      	END IF;
        IF done THEN
            LEAVE read_loop;
        END IF;
    END LOOP;
    CLOSE allPiecesCursor;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `rollDice` (IN `piece_num` VARCHAR(10), IN `@ranDiceResult` INT)   BEGIN
    DECLARE curX INT;
    DECLARE curY INT;
    DECLARE curYpath INT;
    DECLARE curRpath INT;
    DECLARE curGpath INT;
    DECLARE curBpath INT;
    DECLARE newX  INT;
    DECLARE newY  INT;
    DECLARE newPath INT;
    DECLARE oldPath INT;
    DECLARE newYpath INT;
    DECLARE newRpath INT;
    DECLARE newGpath INT;
    DECLARE newBpath INT;
    DECLARE diceResult INT;
    DECLARE ranDiceResult INT;
 

    -- Use exception handling to rollback on error
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION

    -- Start the transaction
    START TRANSACTION;


SET  ranDiceResult = @ranDiceResult;

-- Update the dice table with the generated dice result
UPDATE dice SET dice =  ranDiceResult;
  CASE piece_num
        WHEN 1 THEN
            -- Get the current coordinates of the piece
            SELECT x, y, y_path INTO curX, curY, curYpath
            FROM board
            WHERE piece_color = 'Y' AND piece = 'Y1'; 
IF (curYpath IS NULL) THEN
    SET newX = 5;
    SET newY = 2;
    SET newPath=1;
    
  	call checkPoint(newX, newY);
    -- Update the existing record in the dice table
    UPDATE dice
    SET
        oldX = curX,
        oldY = curY,
        newX = newX,
        newY = newY,
        p_turn = 'Y',
        dice =  @ranDiceResult,
        oldPath= NULL,
        newPath=1
    WHERE piece = 'Y1';
     
ELSE
    SET newYpath = curYpath +  @ranDiceResult;
IF newYpath <= 39 THEN
    -- Calculate the new coordinates
    SELECT X, Y INTO newX, newY
    FROM `board`
    WHERE y_path = newYpath;
 
    -- Update the existing record in the dice table
    UPDATE dice
    SET
        oldX = curX,
        oldY = curY,
        newX = newX,
        newY = newY,
        p_turn = 'Y',
        dice =  @ranDiceResult,
        oldPath=curYpath,
        newPath=newYpath
    WHERE piece = 'Y1'  ;
 -- IF newYpath  = 39 THEN
  END IF;
 IF (newYpath >38 OR (newX=100 AND newY=1)) THEN
    UPDATE dice
    SET
    oldX = curX,
        oldY = curY ,
        newX = 100,
        newY = 1,
        p_turn = 'Y',
       dice =  @ranDiceResult,
        oldPath=curYpath,
        newPath=41
    WHERE piece = 'Y1';
    END IF;
END IF;
   CALL `move_piece`(curX, curY, newX, newY);
-- Commit the transaction if everything is successful
        WHEN 2 THEN
             -- Get the current coordinates of the piece
            SELECT x, y, y_path INTO curX, curY, curYpath
            FROM board
            WHERE piece_color = 'Y' AND piece = 'Y2';
IF (curYpath IS NULL) THEN
    SET newX = 5;
    SET newY = 2;
        SET newPath=1;
    	call checkPoint(newX, newY);
    -- Update the existing record in the dice table
    UPDATE dice
    SET
        oldX = curX,
        oldY = curY,
        newX = newX,
        newY = newY,
        p_turn = 'Y',
         dice =  @ranDiceResult,
        oldPath= NULL,
        newPath=1
    WHERE piece = 'Y2';
ELSE
    SET newYpath = curYpath +  @ranDiceResult;
IF newYpath <=   39 THEN
    -- Calculate the new coordinates
    SELECT X, Y INTO newX, newY
    FROM `board`
    WHERE y_path = newYpath;
    -- Update the existing record in the dice table
    UPDATE dice
    SET
        oldX = curX,
        oldY = curY,
        newX = newX,
        newY = newY,
        p_turn = 'Y',
       dice =  @ranDiceResult,
        oldPath=curYpath,
        newPath=newYpath
    WHERE piece = 'Y2';
END IF;
 IF (newYpath  >38 OR newX=100   AND newY=2) THEN
    UPDATE dice
    SET
        oldX = curX,
        oldY = curY ,
        newX = 100,
        newY = 2,
        p_turn = 'Y',
       dice =  @ranDiceResult,
        oldPath=curYpath,
        newPath=42
    WHERE piece = 'Y2';
    END IF;
END IF;
         -- CALL Y2_dice();
        WHEN 3 THEN
             -- Get the current coordinates of the piece
            SELECT x, y, y_path INTO curX, curY, curYpath
            FROM board
            WHERE piece_color = 'Y' AND piece = 'Y3';
IF (curYpath IS NULL) THEN
    SET newX = 5;
    SET newY = 2;
        SET newPath=1;
	call checkPoint(newX, newY);
    -- Update the existing record in the dice table
    UPDATE dice
    SET
        oldX = curX,
        oldY = curY,
        newX = newX,
        newY = newY,
        p_turn = 'Y',
         dice =  @ranDiceResult,
        oldPath= NULL,
        newPath=1
    WHERE piece = 'Y3';
ELSE
    SET newYpath = curYpath +  @ranDiceResult;
IF newYpath <= 39 THEN
    -- Calculate the new coordinates
    SELECT X, Y INTO newX, newY
    FROM `board`
    WHERE y_path = newYpath;
    -- Update the existing record in the dice table
    UPDATE dice
    SET
        oldX = curX,
        oldY = curY,
        newX = newX,
        newY = newY,
        p_turn = 'Y',
         dice =  @ranDiceResult,
        oldPath=curYpath,
        newPath=newYpath
    WHERE piece = 'Y3';
END IF;
 IF (newYpath >38 OR newX=100 AND newY=3) THEN
    UPDATE dice
    SET
    oldX = curX,
        oldY = curY ,
        newX = 100,
        newY = 3,
        p_turn = 'Y',
       dice =  @ranDiceResult,
        oldPath=curYpath,
        newPath=43
    WHERE piece = 'Y3';
      
     END IF;
END IF;
         --  CALL Y3_dice();

        WHEN 4 THEN
              -- Get the current coordinates of the piece
            SELECT x, y, y_path INTO curX, curY, curYpath
            FROM board
            WHERE piece_color = 'Y' AND piece = 'Y4';
IF (curYpath IS NULL) THEN
    SET newX = 5;
    SET newY = 2;
        SET newPath=1;
      call checkPoint(newX, newY);
       
    -- Update the existing record in the dice table
    UPDATE dice
    SET
        oldX = curX,
        oldY = curY,
        newX = newX,
        newY = newY,
        p_turn = 'Y',
       dice =  @ranDiceResult,
        oldPath= NULL,
        newPath=1
    WHERE piece = 'Y4';
ELSE
    SET newYpath = curYpath +  @ranDiceResult;
IF newYpath <= 39 THEN
    -- Calculate the new coordinates
    SELECT X, Y INTO newX, newY
    FROM `board`
    WHERE y_path = newYpath;
    -- Update the existing record in the dice table
    UPDATE dice
    SET
        oldX = curX,
        oldY = curY,
        newX = newX,
        newY = newY,
        p_turn = 'Y',
      dice =  @ranDiceResult,
        oldPath=curYpath,
        newPath=newYpath
    WHERE piece = 'Y4';
END IF;
 IF (newYpath  >38 OR newX=100   AND newY=4) THEN
    UPDATE dice
    SET
        oldX = curX,
        oldY = curY ,
        newX = 100,
        newY = 4,
        p_turn = 'Y',
       dice =  @ranDiceResult,
        oldPath=curYpath,
        newPath=44
    WHERE piece = 'Y4';
     
    END IF;
END IF;
 
-- pioni 1  tou maurou
WHEN 11 THEN
            -- Get the current coordinates of the piece
            SELECT x, y, b_path INTO curX, curY, curBpath
            FROM board
            WHERE piece_color = 'B' AND piece = 'B1'; 
IF (curBpath IS NULL) THEN
    SET newX = 10;
    SET newY = 5;
    SET newPath=1;
    UPDATE dice
    SET
        oldX = curX,
        oldY = curY,
        newX = newX,
        newY = newY,
        p_turn = 'B',
        dice =  @ranDiceResult,
        oldPath= NULL,
        newPath=1
    WHERE piece = 'B1';
ELSE
    SET newBpath = curBpath +  @ranDiceResult;
IF newBpath <= 39 THEN
    -- Calculate the new coordinates
    SELECT X, Y INTO newX, newY
    FROM `board`
    WHERE b_path = newBpath;
    UPDATE dice
    SET
        oldX = curX,
        oldY = curY,
        newX = newX,
        newY = newY,
        p_turn = 'B',
        dice =  @ranDiceResult,
        oldPath=curBpath,
        newPath=newBpath
    WHERE piece = 'B1'  ;
 -- IF newYpath  = 39 THEN
  END IF;
 IF (newBpath >38 OR (newX=20 AND newY=1)) THEN
    UPDATE dice
    SET
    oldX = curX,
        oldY = curY ,
        newX = 20,
        newY = 1,
        p_turn = 'B',
       dice =  @ranDiceResult,
        oldPath=curBpath,
        newPath=41
    WHERE piece = 'B1';
    END IF;
END IF;
-- pioni 2 tou maurou
WHEN 22 THEN
            -- Get the current coordinates of the piece
            SELECT x, y, b_path INTO curX, curY, curBpath
            FROM board
            WHERE piece_color = 'B' AND piece = 'B2'; 
IF (curBpath IS NULL) THEN

    SET newX = 10;
    SET newY = 5;
    SET newPath=1;
    
  	call checkPoint(newX, newY);
    -- Update the existing record in the dice table
    UPDATE dice
    SET
        oldX = curX,
        oldY = curY,
        newX = newX,
        newY = newY,
        p_turn = 'B',
        dice =  @ranDiceResult,
        oldPath= NULL,
        newPath=1
    WHERE piece = 'B2';
ELSE
    SET newBpath = curBpath +  @ranDiceResult;
IF newBpath <= 39 THEN
    -- Calculate the new coordinates
    SELECT X, Y INTO newX, newY
    FROM `board`
    WHERE b_path = newBpath;
    -- Update the existing record in the dice table
    UPDATE dice
    SET
        oldX = curX,
        oldY = curY,
        newX = newX,
        newY = newY,
        p_turn = 'B',
        dice =  @ranDiceResult,
        oldPath=curBpath,
        newPath=newBpath
    WHERE piece = 'B2'  ;
  END IF;
 IF (newBpath >38 OR (newX=20 AND newY=2)) THEN
    UPDATE dice
    SET
    oldX = curX,
        oldY = curY ,
        newX = 20,
        newY = 2,
        p_turn = 'B',
       dice =  @ranDiceResult,
        oldPath=curBpath,
        newPath=42
    WHERE piece = 'B2';
    END IF;
END IF;
-- pioni 3 tou maurou
WHEN 33 THEN
            -- Get the current coordinates of the piece
            SELECT x, y, b_path INTO curX, curY, curBpath
            FROM board
            WHERE piece_color = 'B' AND piece = 'B3'; 
IF (curBpath IS NULL) THEN
    SET newX = 10;
    SET newY = 5;
    SET newPath=1;
    UPDATE dice
    SET
        oldX = curX,
        oldY = curY,
        newX = newX,
        newY = newY,
        p_turn = 'B',
        dice =  @ranDiceResult,
        oldPath= NULL,
        newPath=1
    WHERE piece = 'B3';
ELSE
    SET newBpath = curBpath +  @ranDiceResult;
IF newBpath <= 39 THEN
    -- Calculate the new coordinates
    SELECT X, Y INTO newX, newY
    FROM `board`
    WHERE b_path = newBpath;
    -- Update the existing record in the dice table
    UPDATE dice
    SET
        oldX = curX,
        oldY = curY,
        newX = newX,
        newY = newY,
        p_turn = 'B',
        dice =  @ranDiceResult,
        oldPath=curBpath,
        newPath=newBpath
    WHERE piece = 'B3'  ;
  END IF;
 IF (newBpath >38 OR (newX=20 AND newY=3)) THEN
    UPDATE dice
    SET
    oldX = curX,
        oldY = curY ,
        newX = 20,
        newY = 3,
        p_turn = 'B',
       	dice =  @ranDiceResult,
        oldPath=curBpath,
        newPath=43
    WHERE piece = 'B3';
    END IF;
END IF;
-- pioni 4 tou maurou
WHEN 44 THEN
	-- Get the current coordinates of the piece
    SELECT x, y, b_path INTO curX, curY, curBpath
    FROM board
    WHERE piece_color = 'B' AND piece = 'B4'; 
IF (curBpath IS NULL) THEN
    SET newX = 10;
    SET newY = 5;
    SET newPath=1;
  	call checkPoint(newX, newY);
    -- Update the existing record in the dice table
    UPDATE dice
    SET
        oldX = curX,
        oldY = curY,
        newX = newX,
        newY = newY,
        p_turn = 'B',
        dice =  @ranDiceResult,
        oldPath= NULL,
        newPath=1
    WHERE piece = 'B4';
ELSE
    SET newBpath = curBpath +  @ranDiceResult;
IF newBpath <= 39 THEN
    -- Calculate the new coordinates
    SELECT X, Y INTO newX, newY
    FROM `board`
    WHERE b_path = newBpath;
    -- Update the existing record in the dice table
    UPDATE dice
    SET
        oldX = curX,
        oldY = curY,
        newX = newX,
        newY = newY,
        p_turn = 'B',
        dice =  @ranDiceResult,
        oldPath=curBpath,
        newPath=newBpath
    WHERE piece = 'B4'  ;
  END IF;
 IF (newBpath >38 OR (newX=20 AND newY=4)) THEN
    UPDATE dice
    SET
    oldX = curX,
        oldY = curY ,
        newX = 20,
        newY = 4,
        p_turn = 'B',
       dice =  @ranDiceResult,
        oldPath=curBpath,
        newPath=44
    WHERE piece = 'B4';
    END IF;
END IF;
	-- pioni 1 tou red
    WHEN 111 THEN
    SELECT x, y, r_path INTO curX, curY, curRpath
FROM board
WHERE piece_color = 'R' AND piece = 'R1';        
-- If the piece exists, calculate the new coordinates
IF (curRpath IS NULL) THEN
    SET newX = 7;
    SET newY = 10;
      SET newPath=1;
      call checkPoint(newX, newY);
    -- Update the existing record in the dice table
    UPDATE dice
    SET
        oldX = curX,
        oldY = curY,
        newX = newX,
        newY = newY,
        p_turn = 'R',
       	dice =  @ranDiceResult,
        oldPath= NULL,
        newPath=1
    WHERE piece = 'R1';
ELSE
    SET newRpath = curRpath +  @ranDiceResult;
IF newRpath <= 39 THEN
    -- Calculate the new coordinates
    SELECT X, Y INTO newX, newY
    FROM `board`
    WHERE r_path = newRpath;
    UPDATE dice
    SET
        oldX = curX,
        oldY = curY,
        newX = newX,
        newY = newY,
        p_turn = 'R',
       dice =  @ranDiceResult,
        oldPath= curRpath,
        newPath=newRpath
    WHERE piece = 'R1';
END IF;
 IF (newRpath  >38 OR newX=30    AND newY=1) THEN
    UPDATE dice
    SET
        oldX = curX,
        oldY = curY ,
        newX = 30 ,
        newY = 1,
        p_turn = 'R',
       dice =  @ranDiceResult,
        oldPath=curRpath,
        newPath=41
    WHERE piece = 'R1';
     
END IF;
END IF;
-- pioni 2 tou kokkinou
WHEN 222 THEN
	SELECT x, y, r_path INTO curX, curY, curRpath
	FROM board
	WHERE piece_color = 'R' AND piece = 'R2';
-- If the piece exists, calculate the new coordinates
IF (curRpath IS NULL) THEN
    SET newX = 7;
    SET newY = 10;
        SET newPath=1;
     	call checkPoint(newX, newY);
    -- Update the existing record in the dice table
    UPDATE dice
    SET
        oldX = curX,
        oldY = curY,
        newX = newX,
        newY = newY,
        p_turn = 'R',
       	dice =  @ranDiceResult,
        oldPath= NULL,
        newPath=1
    WHERE piece = 'R2';
ELSE
    SET newRpath = curRpath +  @ranDiceResult;
IF newRpath <= 39 THEN
    -- Calculate the new coordinates
    SELECT X, Y INTO newX, newY
    FROM `board`
    WHERE r_path = newRpath;
    -- Update the existing record in the dice table
    UPDATE dice
    SET
        oldX = curX,
        oldY = curY,
        newX = newX,
        newY = newY,
        p_turn = 'R',
       	dice =  @ranDiceResult,
        oldPath=curRpath,
        newPath=newRpath
    WHERE piece = 'R2';
END IF;
 IF (newRpath  >38 OR newX=30   AND newY=2) THEN
    UPDATE dice
    SET
        oldX = curX,
        oldY = curY ,
        newX = 30 ,
        newY = 2,
        p_turn = 'R',
       dice =  @ranDiceResult,
        oldPath=curRpath,
        newPath=42
    WHERE piece = 'R2';        
    END IF;
END IF;        
-- pioni 3 tou kokkinou
	WHEN 333 THEN
   		SELECT x, y, r_path INTO curX, curY, curRpath
		FROM board
		WHERE piece_color = 'R' AND piece = 'R3';
-- If the piece exists, calculate the new coordinates
IF (curRpath IS NULL) THEN
    SET newX = 7;
    SET newY = 10;
        SET newPath=1;
      	call checkPoint(newX, newY);
    -- Update the existing record in the dice table
    UPDATE dice
    SET
        oldX = curX,
        oldY = curY,
        newX = newX,
        newY = newY,
        p_turn = 'R',
        dice =  @ranDiceResult,
        oldPath= NULL,
        newPath=1
    WHERE piece = 'R3';
ELSE
    SET newRpath = curRpath +  @ranDiceResult;
IF newRpath <= 39 THEN
    -- Calculate the new coordinates
    SELECT X, Y INTO newX, newY
    FROM `board`
    WHERE r_path = newRpath;
   call checkPoint(newX, newY);
    -- Update the existing record in the dice table
    UPDATE dice
    SET
        oldX = curX,
        oldY = curY,
        newX = newX,
        newY = newY,
        p_turn = 'R',
        dice =  @ranDiceResult,
        oldPath=curRpath,
        newPath=newRpath
    WHERE piece = 'R3';
END IF;
 IF (newRpath  >38 OR newX=30    AND newY=3) THEN
    UPDATE dice
    SET
        oldX = curX,
        oldY = curY ,
        newX = 30 ,
        newY = 3,
        p_turn = 'R',
       	dice =  @ranDiceResult,
        oldPath=curRpath,
        newPath=43
    WHERE piece = 'R3';
    END IF;
END IF;
-- pioni 4 tou kokkinou
WHEN 444 THEN
	SELECT x, y, r_path INTO curX, curY, curRpath
	FROM board
	WHERE piece_color = 'R' AND piece = 'R4';
-- If the piece exists, calculate the new coordinates
IF (curRpath IS NULL) THEN
    SET newX = 7;
    SET newY = 10;
    SET newPath=1;
    call checkPoint(newX, newY);
    -- Update the existing record in the dice table
    UPDATE dice
    SET
        oldX = curX,
        oldY = curY,
        newX = newX,
        newY = newY,
        p_turn = 'R',
       	dice =  @ranDiceResult,
        oldPath= NULL,
        newPath=1
    WHERE piece = 'R4';
ELSE
    SET newRpath = curRpath +  @ranDiceResult;
IF newRpath <= 39 THEN
    -- Calculate the new coordinates
    SELECT X, Y INTO newX, newY
    FROM `board`
    WHERE r_path = newRpath;
    -- Update the existing record in the dice table
    UPDATE dice
    SET
        oldX = curX,
        oldY = curY,
        newX = newX,
        newY = newY,
        p_turn = 'R',
        dice =  @ranDiceResult,
        oldPath=curRpath,
        newPath=newRpath
    WHERE piece = 'R4';
END IF;
 IF (newRpath  >38 OR newX=30     AND newY=4) THEN
    UPDATE dice
    SET
        oldX = curX,
        oldY = curY ,
        newX = 30 ,
        newY = 4,
        p_turn = 'R',
       	dice =  @ranDiceResult,
        oldPath=curRpath,
        newPath=44
    WHERE piece = 'R4';
    END IF;
END IF;
-- pioni 1 tou prasinou
WHEN 1111 THEN
	SELECT x, y, g_path INTO curX, curY, curGpath
	FROM board
	WHERE piece_color = 'G' AND piece = 'G1';
-- If the piece exists, calculate the new coordinates
IF (curGpath IS NULL) THEN
    SET newX = 2;
    SET newY = 7;
      SET newPath=1;
    -- Update the existing record in the dice table
    UPDATE dice
    SET
        oldX = curX,
        oldY = curY,
        newX = newX,
        newY = newY,
        p_turn = 'G',
       	dice =  @ranDiceResult,
        oldPath= NULL,
        newPath=1
    WHERE piece = 'G1';
ELSE
    SET newGpath = curGpath +  @ranDiceResult;
IF newGpath <= 39 THEN
    -- Calculate the new coordinates
    SELECT X, Y INTO newX, newY
    FROM `board`
    WHERE g_path = newGpath;
    UPDATE dice
    SET
        oldX = curX,
        oldY = curY,
        newX = newX,
        newY = newY,
        p_turn = 'G',
       dice =  @ranDiceResult,
        oldPath= curGpath,
        newPath=newGpath
    WHERE piece = 'G1';
END IF;
 IF (newGpath  >38 OR newX=40    AND newY=1) THEN
    UPDATE dice
    SET
        oldX = curX,
        oldY = curY ,
        newX = 40 ,
        newY = 1,
        p_turn = 'G',
       	dice =  @ranDiceResult,
        oldPath=curGpath,
        newPath=41
    WHERE piece = 'G1';
END IF;
END IF;
-- pioni 2 tou prasinou
	WHEN 2222 THEN
    	SELECT x, y, g_path INTO curX, curY, curGpath
		FROM board
		WHERE piece_color = 'G' AND piece = 'G2';
-- If the piece exists, calculate the new coordinates
IF (curGpath IS NULL) THEN
    SET newX = 2;
    SET newY = 7;
    SET newPath=1;
    -- Update the existing record in the dice table
    UPDATE dice
    SET
        oldX = curX,
        oldY = curY,
        newX = newX,
        newY = newY,
        p_turn = 'G',
       	dice =  @ranDiceResult,
        oldPath= NULL,
        newPath=1
    WHERE piece = 'G2';
ELSE
    SET newGpath = curGpath +  @ranDiceResult;
IF newGpath <= 39 THEN
    -- Calculate the new coordinates
    SELECT X, Y INTO newX, newY
    FROM `board`
    WHERE g_path = newGpath;
    UPDATE dice
    SET
        oldX = curX,
        oldY = curY,
        newX = newX,
        newY = newY,
        p_turn = 'G',
       dice =  @ranDiceResult,
        oldPath= curGpath,
        newPath=newGpath
    WHERE piece = 'G2';
END IF;
 IF (newGpath  >38 OR newX=40    AND newY=2) THEN
    UPDATE dice
    SET
        oldX = curX,
        oldY = curY ,
        newX = 40 ,
        newY = 2,
        p_turn = 'G',
       	dice =  @ranDiceResult,
        oldPath=curGpath,
        newPath=42
    WHERE piece = 'G2';
END IF;
END IF;
-- pioni 3 tou prasinou
WHEN 3333 THEN
	SELECT x, y, g_path INTO curX, curY, curGpath
	FROM board
	WHERE piece_color = 'G' AND piece = 'G3';    
-- If the piece exists, calculate the new coordinates
IF (curGpath IS NULL) THEN
    SET newX = 2;
    SET newY = 7;
      SET newPath=1;
    -- Update the existing record in the dice table
    UPDATE dice
    SET
        oldX = curX,
        oldY = curY,
        newX = newX,
        newY = newY,
        p_turn = 'G',
       	dice =  @ranDiceResult,
        oldPath= NULL,
        newPath=1
    WHERE piece = 'G3';
ELSE
    SET newGpath = curGpath +  @ranDiceResult;
IF newGpath <= 39 THEN
    -- Calculate the new coordinates
    SELECT X, Y INTO newX, newY
    FROM `board`
    WHERE g_path = newGpath;
    UPDATE dice
    SET
        oldX = curX,
        oldY = curY,
        newX = newX,
        newY = newY,
        p_turn = 'G',
       	dice =  @ranDiceResult,
        oldPath= curGpath,
        newPath=newGpath
    WHERE piece = 'G3';
END IF;
 IF (newGpath  >38 OR newX=40    AND newY=3) THEN
    UPDATE dice
    SET
        oldX = curX,
        oldY = curY ,
        newX = 40 ,
        newY = 3,
        p_turn = 'G',
       dice =  @ranDiceResult,
        oldPath=curGpath,
        newPath=43
    WHERE piece = 'G3';
END IF;
END IF;
-- pioni 4 tou prasinou
WHEN 4444 THEN
	SELECT x, y, g_path INTO curX, curY, curGpath
	FROM board
	WHERE piece_color = 'G' AND piece = 'G4';    
-- If the piece exists, calculate the new coordinates
IF (curGpath IS NULL) THEN
    SET newX = 2;
    SET newY = 7;
      SET newPath=1;
    -- Update the existing record in the dice table
    UPDATE dice
    SET
        oldX = curX,
        oldY = curY,
        newX = newX,
        newY = newY,
        p_turn = 'G',
       	dice =  @ranDiceResult,
        oldPath= NULL,
        newPath=1
    WHERE piece = 'G4';
ELSE
    SET newGpath = curGpath +  @ranDiceResult;
IF newGpath <= 39 THEN
    -- Calculate the new coordinates
    SELECT X, Y INTO newX, newY
    FROM `board`
    WHERE g_path = newGpath;
    UPDATE dice
    SET
        oldX = curX,
        oldY = curY,
        newX = newX,
        newY = newY,
        p_turn = 'G',
       	dice =  @ranDiceResult,
        oldPath= curGpath,
        newPath=newGpath
    WHERE piece = 'G4';
END IF;
 IF (newGpath  >38 OR newX=40    AND newY=4) THEN
    UPDATE dice
    SET
        oldX = curX,
        oldY = curY ,
        newX = 40 ,
        newY = 4,
        p_turn = 'G',
      	dice =  @ranDiceResult,
        oldPath=curGpath,
        newPath=44
    WHERE piece = 'G4';
END IF;
END IF;
	ELSE
    	-- Default case
   		ROLLBACK;
        SIGNAL SQLSTATE '45000'
        	SET MESSAGE_TEXT = 'Invalid piece parameter.';
    END CASE;
    COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `rollDiceForB1` ()   BEGIN
   SELECT * FROM  dice WHERE piece = 'B1' ORDER BY `created_at` DESC LIMIT 1 ;
 
 
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `rollDiceForB2` ()   BEGIN
   SELECT * FROM  dice WHERE piece = 'B2' ORDER BY `created_at` DESC LIMIT 1 ; 
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `rollDiceForB3` ()   BEGIN
   SELECT * FROM  dice WHERE piece = 'B3' ORDER BY `created_at` DESC LIMIT 1 ; 
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `rollDiceForB4` ()   BEGIN
   SELECT * FROM  dice WHERE piece = 'B4' ORDER BY `created_at` DESC LIMIT 1 ; 
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `rollDiceForG1` ()   BEGIN
   SELECT * FROM  dice WHERE piece = 'G1' ORDER BY `created_at` DESC LIMIT 1 ;
 
 
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `rollDiceForG2` ()   BEGIN
   SELECT * FROM  dice WHERE piece = 'G2' ORDER BY `created_at` DESC LIMIT 1 ;
 
 
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `rollDiceForG3` ()   BEGIN
   SELECT * FROM  dice WHERE piece = 'G3' ORDER BY `created_at` DESC LIMIT 1 ;
 
 
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `rollDiceForG4` ()   BEGIN
   SELECT * FROM  dice WHERE piece = 'G4' ORDER BY `created_at` DESC LIMIT 1 ;
 
 
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `rollDiceForR1` ()   BEGIN
   SELECT * FROM  dice WHERE piece = 'R1' ORDER BY `created_at` DESC LIMIT 1 ;
 
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `rollDiceForR2` ()   BEGIN
   SELECT * FROM  dice WHERE piece = 'R2' ORDER BY `created_at` DESC LIMIT 1 ;
 
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `rollDiceForR3` ()   BEGIN
   SELECT * FROM  dice WHERE piece = 'R3' ORDER BY `created_at` DESC LIMIT 1 ;
 
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `rollDiceForR4` ()   BEGIN
   SELECT * FROM  dice WHERE piece = 'R4' ORDER BY `created_at` DESC LIMIT 1 ;
 
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `rollDiceForY1` ()   BEGIN
   SELECT * FROM  dice WHERE piece = 'Y1' ORDER BY `created_at` DESC LIMIT 1 ;
 
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `rollDiceForY2` ()   BEGIN
   SELECT * FROM  dice WHERE piece = 'Y2' ORDER BY `created_at` DESC LIMIT 1 ;
 
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `rollDiceForY3` ()   BEGIN
   SELECT * FROM  dice WHERE piece = 'Y3' ORDER BY `created_at` DESC LIMIT 1 ;
 
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `rollDiceForY4` ()   BEGIN
   SELECT * FROM  dice WHERE piece = 'Y4' ORDER BY `created_at` DESC LIMIT 1 ;
 
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `rollDiceOUT` (OUT `generated_dice_result` INT)   BEGIN
    SET  generated_dice_result = FLOOR(1 + RAND() * 6);
 SELECT  generated_dice_result ;
 
 -- prwtos paiktis yellow
 CALL rollDice(1, generated_dice_result); 
 CALL rollDice(2,generated_dice_result); 
 CALL rollDice(3, generated_dice_result);
 CALL rollDice(4, generated_dice_result);
 
 -- paiktis black
  CALL rollDice(11, generated_dice_result); 
 CALL rollDice(22,generated_dice_result); 
 CALL rollDice(33, generated_dice_result);
 CALL rollDice(44, generated_dice_result);
 
 
 -- paiktis red
 CALL rollDice(111, generated_dice_result);
 CALL rollDice(222, generated_dice_result);
 CALL rollDice(333, generated_dice_result);
 CALL rollDice(444, generated_dice_result);
 
 
 -- paiktis green
 CALL rollDice(1111, generated_dice_result);
 CALL rollDice(2222, generated_dice_result);
 CALL rollDice(3333, generated_dice_result);
 CALL rollDice(4444, generated_dice_result);
 
 
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Winners` ()   BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE winPiece VARCHAR(10);
    DECLARE allPiecesCursor CURSOR FOR
        SELECT 'G1' UNION SELECT 'G2' UNION SELECT 'G3' UNION SELECT 'G4'
        UNION SELECT 'B1' UNION SELECT 'B2' UNION SELECT 'B3' UNION SELECT 'B4'
      UNION  SELECT 'Y1' UNION SELECT 'Y2' UNION SELECT 'Y3' UNION SELECT 'Y4'
        UNION SELECT 'R1' UNION SELECT 'R2' UNION SELECT 'R3' UNION SELECT 'R4';
        
    -- Use a NOT FOUND handler to exit the loop
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
  -- Open the cursor
    OPEN allPiecesCursor;

    -- Loop through all possible pieces
    read_loop: LOOP
        -- Fetch the next piece
        FETCH allPiecesCursor INTO winPiece; 
  IF NOT EXISTS (SELECT 1 FROM yellowwin WHERE piece = winPiece  ) THEN    
 
            IF EXISTS (SELECT 1 FROM board WHERE piece = winPiece AND (X = 100 AND y = 1 )) THEN
            INSERT INTO yellowwin (piece, piece_color,id) VALUES ('Y1', 'Y',1);
        END IF;
            IF EXISTS (SELECT 1 FROM board WHERE piece = winPiece AND (X = 100 AND Y =   2 )) THEN
            INSERT INTO yellowwin (piece, piece_color,id) VALUES ('Y2', 'Y',2);
        END IF; 
		      IF EXISTS (SELECT 1 FROM board WHERE piece = winPiece AND (X = 100 AND Y = 3 )) THEN
            INSERT INTO yellowwin (piece, piece_color,id) VALUES ('Y3', 'Y',3);
        END IF;
            IF EXISTS (SELECT 1 FROM board WHERE piece = winPiece AND (X = 100 AND Y = 4 )) THEN
            INSERT INTO yellowwin (piece, piece_color,id) VALUES ('Y4', 'Y',4);
        END IF;
        END IF;  
  IF NOT EXISTS (SELECT 1 FROM blackwin WHERE piece = winPiece  ) THEN    
 
            IF EXISTS (SELECT 1 FROM board WHERE piece = winPiece AND (X = 20 AND Y = 1 )) THEN
            INSERT INTO blackwin (piece, piece_color,id) VALUES ('B1', 'B',1);
        END IF;
            IF EXISTS (SELECT 1 FROM board WHERE piece = winPiece AND (X = 20 AND Y = 2 )) THEN
            INSERT INTO blackwin (piece, piece_color,id) VALUES ('B2', 'B',2);
        END IF; 
		      IF EXISTS (SELECT 1 FROM board WHERE piece = winPiece AND (X = 20 AND Y = 3 )) THEN
            INSERT INTO blackwin (piece, piece_color,id) VALUES ('B3', 'B',3);
        END IF;
            IF EXISTS (SELECT 1 FROM board WHERE piece = winPiece AND (X = 20 AND Y = 4 )) THEN
            INSERT INTO blackwin (piece, piece_color,id) VALUES ('B4', 'B',4);
        END IF;
        END IF;  
       IF NOT EXISTS (SELECT 1 FROM redwin WHERE piece = winPiece  ) THEN  
            IF EXISTS (SELECT 1 FROM board WHERE piece = winPiece AND (X = 30 AND Y = 1 )) THEN
            INSERT INTO redwin (piece, piece_color,id) VALUES ('R1', 'R',1);
        END IF;
            IF EXISTS (SELECT 1 FROM board WHERE piece = winPiece AND (X = 30 AND Y =  2 )) THEN
            INSERT INTO redwin (piece, piece_color,id) VALUES ('R2', 'R',2);
        END IF;
            IF EXISTS (SELECT 1 FROM board WHERE piece = winPiece AND (X = 30 AND Y =  3 )) THEN
            INSERT INTO redwin (piece, piece_color,id) VALUES ('R3', 'R',3);
        END IF;
             IF EXISTS (SELECT 1 FROM board WHERE piece = winPiece AND (X = 30 AND Y =  4 )) THEN
            INSERT INTO redwin (piece, piece_color,id) VALUES ('R4', 'R',4);
        END IF;
        END IF;   
  IF NOT EXISTS (SELECT 1 FROM greenwin WHERE piece = winPiece  ) THEN    
 
            IF EXISTS (SELECT 1 FROM board WHERE piece = winPiece AND (X = 40 AND Y = 1 )) THEN
            INSERT INTO greenwin (piece, piece_color,id) VALUES ('G1', 'G',1);
        END IF;
            IF EXISTS (SELECT 1 FROM board WHERE piece = winPiece AND (X = 40 AND Y = 2 )) THEN
            INSERT INTO greenwin (piece, piece_color,id) VALUES ('G2', 'G',2);
        END IF; 
		      IF EXISTS (SELECT 1 FROM board WHERE piece = winPiece AND (X = 40 AND Y = 3 )) THEN
            INSERT INTO greenwin (piece, piece_color,id) VALUES ('G3', 'G',3);
        END IF;
            IF EXISTS (SELECT 1 FROM board WHERE piece = winPiece AND (X = 40 AND Y = 4 )) THEN
            INSERT INTO greenwin (piece, piece_color,id) VALUES ('G4', 'G',4);
        END IF;
        END IF;   
	CALL checkWinner(); 
        IF done THEN
            LEAVE read_loop;
        END IF;
    END LOOP;
    CLOSE allPiecesCursor;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Δομή πίνακα για τον πίνακα `blackwin`
--

CREATE TABLE `blackwin` (
  `piece` varchar(50) NOT NULL,
  `piece_color` varchar(50) NOT NULL,
  `id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Δομή πίνακα για τον πίνακα `board`
--

CREATE TABLE `board` (
  `x` int(11) NOT NULL DEFAULT 0,
  `y` int(11) NOT NULL DEFAULT 0,
  `b_color` enum('R','G','B','Y','W','MIX','GR','BR','BY','GY') NOT NULL,
  `piece_color` enum('R','G','B','Y') DEFAULT NULL,
  `piece` varchar(3) DEFAULT NULL,
  `y_path` int(11) DEFAULT NULL CHECK (`y_path` is null or `y_path` >= 1 and `y_path` <= 44),
  `b_path` int(11) DEFAULT NULL CHECK (`b_path` is null or `b_path` >= 1 and `b_path` <= 44),
  `r_path` int(11) DEFAULT NULL CHECK (`r_path` is null or `r_path` >= 1 and `r_path` <= 44),
  `g_path` int(11) DEFAULT NULL CHECK (`g_path` is null or `g_path` >= 1 and `g_path` <= 44)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Άδειασμα δεδομένων του πίνακα `board`
--

INSERT INTO `board` (`x`, `y`, `b_color`, `piece_color`, `piece`, `y_path`, `b_path`, `r_path`, `g_path`) VALUES
(1, 1, 'Y', NULL, NULL, NULL, NULL, NULL, NULL),
(1, 2, 'Y', NULL, NULL, NULL, NULL, NULL, NULL),
(1, 3, 'Y', NULL, NULL, NULL, NULL, NULL, NULL),
(1, 4, 'Y', NULL, NULL, NULL, NULL, NULL, NULL),
(1, 5, 'W', NULL, NULL, 7, 16, 25, 34),
(1, 6, 'W', NULL, NULL, 8, 17, 26, 35),
(1, 7, 'W', NULL, NULL, 9, 18, 27, NULL),
(1, 8, 'G', NULL, NULL, NULL, NULL, NULL, NULL),
(1, 9, 'G', NULL, NULL, NULL, NULL, NULL, NULL),
(1, 10, 'G', NULL, NULL, NULL, NULL, NULL, NULL),
(1, 11, 'G', NULL, NULL, NULL, NULL, NULL, NULL),
(2, 1, 'Y', NULL, NULL, NULL, NULL, NULL, NULL),
(2, 2, 'W', 'Y', 'Y3', NULL, NULL, NULL, NULL),
(2, 3, 'W', 'Y', 'Y1', NULL, NULL, NULL, NULL),
(2, 4, 'Y', NULL, NULL, NULL, NULL, NULL, NULL),
(2, 5, 'W', NULL, NULL, 6, 15, 24, 33),
(2, 6, 'G', NULL, NULL, NULL, NULL, NULL, 36),
(2, 7, 'G', NULL, NULL, 10, 19, 28, 1),
(2, 8, 'G', NULL, NULL, NULL, NULL, NULL, NULL),
(2, 9, 'W', 'G', 'G3', NULL, NULL, NULL, NULL),
(2, 10, 'W', 'G', 'G1', NULL, NULL, NULL, NULL),
(2, 11, 'G', NULL, NULL, NULL, NULL, NULL, NULL),
(3, 1, 'Y', NULL, NULL, NULL, NULL, NULL, NULL),
(3, 2, 'W', 'Y', 'Y4', NULL, NULL, NULL, NULL),
(3, 3, 'W', 'Y', 'Y2', NULL, NULL, NULL, NULL),
(3, 4, 'Y', NULL, NULL, NULL, NULL, NULL, NULL),
(3, 5, 'W', NULL, NULL, 5, 14, 23, 32),
(3, 6, 'G', NULL, NULL, NULL, NULL, NULL, 37),
(3, 7, 'W', NULL, NULL, 11, 20, 29, 2),
(3, 8, 'G', NULL, NULL, NULL, NULL, NULL, NULL),
(3, 9, 'W', 'G', 'G4', NULL, NULL, NULL, NULL),
(3, 10, 'W', 'G', 'G2', NULL, NULL, NULL, NULL),
(3, 11, 'G', NULL, NULL, NULL, NULL, NULL, NULL),
(4, 1, 'Y', NULL, NULL, NULL, NULL, NULL, NULL),
(4, 2, 'Y', NULL, NULL, NULL, NULL, NULL, NULL),
(4, 3, 'Y', NULL, NULL, NULL, NULL, NULL, NULL),
(4, 4, 'Y', NULL, NULL, NULL, NULL, NULL, NULL),
(4, 5, 'W', NULL, NULL, 4, 13, 22, 31),
(4, 6, 'G', NULL, NULL, NULL, NULL, NULL, 38),
(4, 7, 'W', NULL, NULL, 12, 21, 30, 3),
(4, 8, 'G', NULL, NULL, NULL, NULL, NULL, NULL),
(4, 9, 'G', NULL, NULL, NULL, NULL, NULL, NULL),
(4, 10, 'G', NULL, NULL, NULL, NULL, NULL, NULL),
(4, 11, 'G', NULL, NULL, NULL, NULL, NULL, NULL),
(5, 1, 'W', NULL, NULL, NULL, 9, 18, 27),
(5, 2, 'Y', NULL, NULL, 1, 10, 19, 28),
(5, 3, 'W', NULL, NULL, 2, 11, 20, 29),
(5, 4, 'W', NULL, NULL, 3, 12, 21, 30),
(5, 5, 'GY', NULL, NULL, NULL, NULL, NULL, NULL),
(5, 6, 'G', NULL, NULL, NULL, NULL, NULL, 39),
(5, 7, 'GR', NULL, NULL, NULL, NULL, NULL, NULL),
(5, 8, 'W', NULL, NULL, 13, 22, 31, 4),
(5, 9, 'W', NULL, NULL, 14, 23, 32, 5),
(5, 10, 'W', NULL, NULL, 15, 24, 33, 6),
(5, 11, 'W', NULL, NULL, 16, 25, 34, 7),
(6, 1, 'W', NULL, NULL, 35, 8, 17, 26),
(6, 2, 'Y', NULL, NULL, 36, NULL, NULL, NULL),
(6, 3, 'Y', NULL, NULL, 37, NULL, NULL, NULL),
(6, 4, 'Y', NULL, NULL, 38, NULL, NULL, NULL),
(6, 5, 'Y', NULL, NULL, 39, NULL, NULL, NULL),
(6, 6, 'MIX', NULL, NULL, NULL, NULL, NULL, NULL),
(6, 7, 'R', NULL, NULL, NULL, NULL, 39, NULL),
(6, 8, 'R', NULL, NULL, NULL, NULL, 38, NULL),
(6, 9, 'R', NULL, NULL, NULL, NULL, 37, NULL),
(6, 10, 'R', NULL, NULL, NULL, NULL, 36, NULL),
(6, 11, 'W', NULL, NULL, 17, 26, 35, 8),
(7, 1, 'W', NULL, NULL, 34, 7, 16, 25),
(7, 2, 'W', NULL, NULL, 33, 6, 15, 24),
(7, 3, 'W', NULL, NULL, 32, 5, 14, 23),
(7, 4, 'W', NULL, NULL, 31, 4, 13, 22),
(7, 5, 'BY', NULL, NULL, NULL, NULL, NULL, NULL),
(7, 6, 'B', NULL, NULL, NULL, 39, NULL, NULL),
(7, 7, 'BR', NULL, NULL, NULL, NULL, NULL, NULL),
(7, 8, 'W', NULL, NULL, 21, 30, 3, 12),
(7, 9, 'W', NULL, NULL, 20, 29, 2, 11),
(7, 10, 'R', NULL, NULL, 19, 28, 1, 10),
(7, 11, 'W', NULL, NULL, 18, 27, NULL, 9),
(8, 1, 'B', NULL, NULL, NULL, NULL, NULL, NULL),
(8, 2, 'B', NULL, NULL, NULL, NULL, NULL, NULL),
(8, 3, 'B', NULL, NULL, NULL, NULL, NULL, NULL),
(8, 4, 'B', NULL, NULL, NULL, NULL, NULL, NULL),
(8, 5, 'W', NULL, NULL, 30, 3, 12, 21),
(8, 6, 'B', NULL, NULL, NULL, 38, NULL, NULL),
(8, 7, 'W', NULL, NULL, 22, 31, 4, 13),
(8, 8, 'R', NULL, NULL, NULL, NULL, NULL, NULL),
(8, 9, 'R', NULL, NULL, NULL, NULL, NULL, NULL),
(8, 10, 'R', NULL, NULL, NULL, NULL, NULL, NULL),
(8, 11, 'R', NULL, NULL, NULL, NULL, NULL, NULL),
(9, 1, 'B', NULL, NULL, NULL, NULL, NULL, NULL),
(9, 2, 'W', 'B', 'B3', NULL, NULL, NULL, NULL),
(9, 3, 'W', 'B', 'B1', NULL, NULL, NULL, NULL),
(9, 4, 'B', NULL, NULL, NULL, NULL, NULL, NULL),
(9, 5, 'W', NULL, NULL, 29, 2, 11, 20),
(9, 6, 'B', NULL, NULL, NULL, 37, NULL, NULL),
(9, 7, 'W', NULL, NULL, 23, 32, 5, 14),
(9, 8, 'R', NULL, NULL, NULL, NULL, NULL, NULL),
(9, 9, 'W', 'R', 'R3', NULL, NULL, NULL, NULL),
(9, 10, 'W', 'R', 'R1', NULL, NULL, NULL, NULL),
(9, 11, 'R', NULL, NULL, NULL, NULL, NULL, NULL),
(10, 1, 'B', NULL, NULL, NULL, NULL, NULL, NULL),
(10, 2, 'W', 'B', 'B4', NULL, NULL, NULL, NULL),
(10, 3, 'W', 'B', 'B2', NULL, NULL, NULL, NULL),
(10, 4, 'B', NULL, NULL, NULL, NULL, NULL, NULL),
(10, 5, 'B', NULL, NULL, 28, 1, 10, 19),
(10, 6, 'B', NULL, NULL, NULL, 36, NULL, NULL),
(10, 7, 'W', NULL, NULL, 24, 33, 6, 15),
(10, 8, 'R', NULL, NULL, NULL, NULL, NULL, NULL),
(10, 9, 'W', 'R', 'R4', NULL, NULL, NULL, NULL),
(10, 10, 'W', 'R', 'R2', NULL, NULL, NULL, NULL),
(10, 11, 'R', NULL, NULL, NULL, NULL, NULL, NULL),
(11, 1, 'B', NULL, NULL, NULL, NULL, NULL, NULL),
(11, 2, 'B', NULL, NULL, NULL, NULL, NULL, NULL),
(11, 3, 'B', NULL, NULL, NULL, NULL, NULL, NULL),
(11, 4, 'B', NULL, NULL, NULL, NULL, NULL, NULL),
(11, 5, 'W', NULL, NULL, 27, NULL, 9, 18),
(11, 6, 'W', NULL, NULL, 26, 35, 8, 17),
(11, 7, 'W', NULL, NULL, 25, 34, 7, 16),
(11, 8, 'R', NULL, NULL, NULL, NULL, NULL, NULL),
(11, 9, 'R', NULL, NULL, NULL, NULL, NULL, NULL),
(11, 10, 'R', NULL, NULL, NULL, NULL, NULL, NULL),
(11, 11, 'R', NULL, NULL, NULL, NULL, NULL, NULL),
(30, 1, '', NULL, NULL, NULL, NULL, 41, NULL),
(30, 2, '', NULL, NULL, NULL, NULL, 42, NULL),
(30, 3, '', NULL, NULL, NULL, NULL, 43, NULL),
(30, 4, '', NULL, NULL, NULL, NULL, 44, NULL),
(100, 1, '', NULL, NULL, 41, NULL, NULL, NULL),
(100, 2, '', NULL, NULL, 42, NULL, NULL, NULL),
(100, 3, '', NULL, NULL, 43, NULL, NULL, NULL),
(100, 4, '', NULL, NULL, 44, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Δομή πίνακα για τον πίνακα `board_empty`
--

CREATE TABLE `board_empty` (
  `x` int(11) NOT NULL DEFAULT 0,
  `y` int(11) NOT NULL DEFAULT 0,
  `b_color` enum('R','G','B','Y','W','MIX','GR','BR','BY','GY') NOT NULL,
  `piece_color` enum('R','G','B','Y') DEFAULT NULL,
  `piece` varchar(3) DEFAULT NULL,
  `y_path` int(11) DEFAULT NULL CHECK (`y_path` is null or `y_path` >= 1 and `y_path` <= 44),
  `b_path` int(11) DEFAULT NULL CHECK (`b_path` is null or `b_path` >= 1 and `b_path` <= 44),
  `r_path` int(11) DEFAULT NULL CHECK (`r_path` is null or `r_path` >= 1 and `r_path` <= 44),
  `g_path` int(11) DEFAULT NULL CHECK (`g_path` is null or `g_path` >= 1 and `g_path` <= 44)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Άδειασμα δεδομένων του πίνακα `board_empty`
--

INSERT INTO `board_empty` (`x`, `y`, `b_color`, `piece_color`, `piece`, `y_path`, `b_path`, `r_path`, `g_path`) VALUES
(1, 1, 'Y', NULL, NULL, NULL, NULL, NULL, NULL),
(1, 2, 'Y', NULL, NULL, NULL, NULL, NULL, NULL),
(1, 3, 'Y', NULL, NULL, NULL, NULL, NULL, NULL),
(1, 4, 'Y', NULL, NULL, NULL, NULL, NULL, NULL),
(1, 5, 'W', NULL, NULL, 7, 16, 25, 34),
(1, 6, 'W', NULL, NULL, 8, 17, 26, 35),
(1, 7, 'W', NULL, NULL, 9, 18, 27, NULL),
(1, 8, 'G', NULL, NULL, NULL, NULL, NULL, NULL),
(1, 9, 'G', NULL, NULL, NULL, NULL, NULL, NULL),
(1, 10, 'G', NULL, NULL, NULL, NULL, NULL, NULL),
(1, 11, 'G', NULL, NULL, NULL, NULL, NULL, NULL),
(2, 1, 'Y', NULL, NULL, NULL, NULL, NULL, NULL),
(2, 2, 'W', 'Y', 'Y3', NULL, NULL, NULL, NULL),
(2, 3, 'W', 'Y', 'Y1', NULL, NULL, NULL, NULL),
(2, 4, 'Y', NULL, NULL, NULL, NULL, NULL, NULL),
(2, 5, 'W', NULL, NULL, 6, 15, 24, 33),
(2, 6, 'G', NULL, NULL, NULL, NULL, NULL, 36),
(2, 7, 'G', NULL, NULL, 10, 19, 28, 1),
(2, 8, 'G', NULL, NULL, NULL, NULL, NULL, NULL),
(2, 9, 'W', 'G', 'G3', NULL, NULL, NULL, NULL),
(2, 10, 'W', 'G', 'G1', NULL, NULL, NULL, NULL),
(2, 11, 'G', NULL, NULL, NULL, NULL, NULL, NULL),
(3, 1, 'Y', NULL, NULL, NULL, NULL, NULL, NULL),
(3, 2, 'W', 'Y', 'Y4', NULL, NULL, NULL, NULL),
(3, 3, 'W', 'Y', 'Y2', NULL, NULL, NULL, NULL),
(3, 4, 'Y', NULL, NULL, NULL, NULL, NULL, NULL),
(3, 5, 'W', NULL, NULL, 5, 14, 23, 32),
(3, 6, 'G', NULL, NULL, NULL, NULL, NULL, 37),
(3, 7, 'W', NULL, NULL, 11, 20, 29, 2),
(3, 8, 'G', NULL, NULL, NULL, NULL, NULL, NULL),
(3, 9, 'W', 'G', 'G4', NULL, NULL, NULL, NULL),
(3, 10, 'W', 'G', 'G2', NULL, NULL, NULL, NULL),
(3, 11, 'G', NULL, NULL, NULL, NULL, NULL, NULL),
(4, 1, 'Y', NULL, NULL, NULL, NULL, NULL, NULL),
(4, 2, 'Y', NULL, NULL, NULL, NULL, NULL, NULL),
(4, 3, 'Y', NULL, NULL, NULL, NULL, NULL, NULL),
(4, 4, 'Y', NULL, NULL, NULL, NULL, NULL, NULL),
(4, 5, 'W', NULL, NULL, 4, 13, 22, 31),
(4, 6, 'G', NULL, NULL, NULL, NULL, NULL, 38),
(4, 7, 'W', NULL, NULL, 12, 21, 30, 3),
(4, 8, 'G', NULL, NULL, NULL, NULL, NULL, NULL),
(4, 9, 'G', NULL, NULL, NULL, NULL, NULL, NULL),
(4, 10, 'G', NULL, NULL, NULL, NULL, NULL, NULL),
(4, 11, 'G', NULL, NULL, NULL, NULL, NULL, NULL),
(5, 1, 'W', NULL, NULL, NULL, 9, 18, 27),
(5, 2, 'Y', NULL, NULL, 1, 10, 19, 28),
(5, 3, 'W', NULL, NULL, 2, 11, 20, 29),
(5, 4, 'W', NULL, NULL, 3, 12, 21, 30),
(5, 5, 'GY', NULL, NULL, NULL, NULL, NULL, NULL),
(5, 6, 'G', NULL, NULL, NULL, NULL, NULL, 39),
(5, 7, 'GR', NULL, NULL, NULL, NULL, NULL, NULL),
(5, 8, 'W', NULL, NULL, 13, 22, 31, 4),
(5, 9, 'W', NULL, NULL, 14, 23, 32, 5),
(5, 10, 'W', NULL, NULL, 15, 24, 33, 6),
(5, 11, 'W', NULL, NULL, 16, 25, 34, 7),
(6, 1, 'W', NULL, NULL, 35, 8, 17, 26),
(6, 2, 'Y', NULL, NULL, 36, NULL, NULL, NULL),
(6, 3, 'Y', NULL, NULL, 37, NULL, NULL, NULL),
(6, 4, 'Y', NULL, NULL, 38, NULL, NULL, NULL),
(6, 5, 'Y', NULL, NULL, 39, NULL, NULL, NULL),
(6, 6, 'MIX', NULL, NULL, NULL, NULL, NULL, NULL),
(6, 7, 'R', NULL, NULL, NULL, NULL, 39, NULL),
(6, 8, 'R', NULL, NULL, NULL, NULL, 38, NULL),
(6, 9, 'R', NULL, NULL, NULL, NULL, 37, NULL),
(6, 10, 'R', NULL, NULL, NULL, NULL, 36, NULL),
(6, 11, 'W', NULL, NULL, 17, 26, 35, 8),
(7, 1, 'W', NULL, NULL, 34, 7, 16, 25),
(7, 2, 'W', NULL, NULL, 33, 6, 15, 24),
(7, 3, 'W', NULL, NULL, 32, 5, 14, 23),
(7, 4, 'W', NULL, NULL, 31, 4, 13, 22),
(7, 5, 'BY', NULL, NULL, NULL, NULL, NULL, NULL),
(7, 6, 'B', NULL, NULL, NULL, 39, NULL, NULL),
(7, 7, 'BR', NULL, NULL, NULL, NULL, NULL, NULL),
(7, 8, 'W', NULL, NULL, 21, 30, 3, 12),
(7, 9, 'W', NULL, NULL, 20, 29, 2, 11),
(7, 10, 'R', NULL, NULL, 19, 28, 1, 10),
(7, 11, 'W', NULL, NULL, 18, 27, NULL, 9),
(8, 1, 'B', NULL, NULL, NULL, NULL, NULL, NULL),
(8, 2, 'B', NULL, NULL, NULL, NULL, NULL, NULL),
(8, 3, 'B', NULL, NULL, NULL, NULL, NULL, NULL),
(8, 4, 'B', NULL, NULL, NULL, NULL, NULL, NULL),
(8, 5, 'W', NULL, NULL, 30, 3, 12, 21),
(8, 6, 'B', NULL, NULL, NULL, 38, NULL, NULL),
(8, 7, 'W', NULL, NULL, 22, 31, 4, 13),
(8, 8, 'R', NULL, NULL, NULL, NULL, NULL, NULL),
(8, 9, 'R', NULL, NULL, NULL, NULL, NULL, NULL),
(8, 10, 'R', NULL, NULL, NULL, NULL, NULL, NULL),
(8, 11, 'R', NULL, NULL, NULL, NULL, NULL, NULL),
(9, 1, 'B', NULL, NULL, NULL, NULL, NULL, NULL),
(9, 2, 'W', 'B', 'B3', NULL, NULL, NULL, NULL),
(9, 3, 'W', 'B', 'B1', NULL, NULL, NULL, NULL),
(9, 4, 'B', NULL, NULL, NULL, NULL, NULL, NULL),
(9, 5, 'W', NULL, NULL, 29, 2, 11, 20),
(9, 6, 'B', NULL, NULL, NULL, 37, NULL, NULL),
(9, 7, 'W', NULL, NULL, 23, 32, 5, 14),
(9, 8, 'R', NULL, NULL, NULL, NULL, NULL, NULL),
(9, 9, 'W', 'R', 'R3', NULL, NULL, NULL, NULL),
(9, 10, 'W', 'R', 'R1', NULL, NULL, NULL, NULL),
(9, 11, 'R', NULL, NULL, NULL, NULL, NULL, NULL),
(10, 1, 'B', NULL, NULL, NULL, NULL, NULL, NULL),
(10, 2, 'W', 'B', 'B4', NULL, NULL, NULL, NULL),
(10, 3, 'W', 'B', 'B2', NULL, NULL, NULL, NULL),
(10, 4, 'B', NULL, NULL, NULL, NULL, NULL, NULL),
(10, 5, 'B', NULL, NULL, 28, 1, 10, 19),
(10, 6, 'B', NULL, NULL, NULL, 36, NULL, NULL),
(10, 7, 'W', NULL, NULL, 24, 33, 6, 15),
(10, 8, 'R', NULL, NULL, NULL, NULL, NULL, NULL),
(10, 9, 'W', 'R', 'R4', NULL, NULL, NULL, NULL),
(10, 10, 'W', 'R', 'R2', NULL, NULL, NULL, NULL),
(10, 11, 'R', NULL, NULL, NULL, NULL, NULL, NULL),
(11, 1, 'B', NULL, NULL, NULL, NULL, NULL, NULL),
(11, 2, 'B', NULL, NULL, NULL, NULL, NULL, NULL),
(11, 3, 'B', NULL, NULL, NULL, NULL, NULL, NULL),
(11, 4, 'B', NULL, NULL, NULL, NULL, NULL, NULL),
(11, 5, 'W', NULL, NULL, 27, NULL, 9, 18),
(11, 6, 'W', NULL, NULL, 26, 35, 8, 17),
(11, 7, 'W', NULL, NULL, 25, 34, 7, 16),
(11, 8, 'R', NULL, NULL, NULL, NULL, NULL, NULL),
(11, 9, 'R', NULL, NULL, NULL, NULL, NULL, NULL),
(11, 10, 'R', NULL, NULL, NULL, NULL, NULL, NULL),
(11, 11, 'R', NULL, NULL, NULL, NULL, NULL, NULL),
(30, 1, '', NULL, NULL, NULL, NULL, 41, NULL),
(30, 2, '', NULL, NULL, NULL, NULL, 42, NULL),
(30, 3, '', NULL, NULL, NULL, NULL, 43, NULL),
(30, 4, '', NULL, NULL, NULL, NULL, 44, NULL),
(100, 1, '', NULL, NULL, 41, NULL, NULL, NULL),
(100, 2, '', NULL, NULL, 42, NULL, NULL, NULL),
(100, 3, '', NULL, NULL, 43, NULL, NULL, NULL),
(100, 4, '', NULL, NULL, 44, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Δομή πίνακα για τον πίνακα `dice`
--

CREATE TABLE `dice` (
  `oldX` tinyint(4) DEFAULT NULL,
  `oldY` tinyint(4) DEFAULT NULL,
  `newX` tinyint(4) DEFAULT NULL,
  `newY` tinyint(4) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `p_turn` enum('R','G','B','Y') DEFAULT NULL,
  `piece` varchar(3) NOT NULL,
  `dice` tinyint(4) DEFAULT NULL,
  `oldPath` tinyint(4) DEFAULT NULL,
  `newPath` tinyint(4) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Άδειασμα δεδομένων του πίνακα `dice`
--

INSERT INTO `dice` (`oldX`, `oldY`, `newX`, `newY`, `created_at`, `p_turn`, `piece`, `dice`, `oldPath`, `newPath`) VALUES
(9, 3, 10, 5, '2024-01-10 15:20:16', 'B', 'B1', 0, NULL, NULL),
(10, 3, 10, 5, '2024-01-10 15:20:16', 'B', 'B2', 0, NULL, NULL),
(9, 2, 10, 5, '2024-01-10 15:20:16', 'B', 'B3', 0, NULL, NULL),
(10, 2, 10, 5, '2024-01-10 15:20:16', 'B', 'B4', 0, NULL, NULL),
(2, 10, 2, 7, '2024-01-10 15:20:16', 'G', 'G1', 0, NULL, NULL),
(3, 10, 2, 7, '2024-01-10 15:20:16', 'G', 'G2', 0, NULL, NULL),
(2, 9, 2, 7, '2024-01-10 15:20:16', 'G', 'G3', 0, NULL, NULL),
(3, 9, 2, 7, '2024-01-10 15:20:16', 'G', 'G4', 0, NULL, NULL),
(9, 10, 7, 10, '2024-01-10 15:20:16', 'R', 'R1', 0, NULL, NULL),
(10, 10, 7, 10, '2024-01-10 15:20:16', 'R', 'R2', 0, NULL, NULL),
(9, 9, 7, 10, '2024-01-10 15:20:16', 'R', 'R3', 0, NULL, NULL),
(10, 9, 7, 10, '2024-01-10 15:20:16', 'R', 'R4', 0, NULL, NULL),
(2, 3, 5, 2, '2024-01-10 15:20:16', 'Y', 'Y1', 0, NULL, NULL),
(3, 3, 5, 2, '2024-01-10 15:20:16', 'Y', 'Y2', 0, NULL, NULL),
(2, 2, 5, 2, '2024-01-10 15:20:16', 'Y', 'Y3', 0, NULL, NULL),
(3, 2, 5, 2, '2024-01-10 15:20:16', 'Y', 'Y4', 0, NULL, NULL);

-- --------------------------------------------------------

--
-- Δομή πίνακα για τον πίνακα `game_status`
--

CREATE TABLE `game_status` (
  `status` enum('not active','initialized','started','ended','aborded') NOT NULL DEFAULT 'not active',
  `p_turn` enum('R','G','B','Y') DEFAULT NULL,
  `result` enum('R','G','B','Y','D') DEFAULT NULL,
  `last_change` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Άδειασμα δεδομένων του πίνακα `game_status`
--

INSERT INTO `game_status` (`status`, `p_turn`, `result`, `last_change`) VALUES
('ended', 'Y', 'R', '2024-01-10 15:18:57');

--
-- Δείκτες `game_status`
--
DELIMITER $$
CREATE TRIGGER `game_status_update` BEFORE UPDATE ON `game_status` FOR EACH ROW BEGIN
SET NEW.last_change = NOW();
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Δομή πίνακα για τον πίνακα `greenwin`
--

CREATE TABLE `greenwin` (
  `piece` varchar(50) NOT NULL,
  `piece_color` varchar(50) NOT NULL,
  `id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Δομή πίνακα για τον πίνακα `players`
--

CREATE TABLE `players` (
  `username` varchar(20) DEFAULT NULL,
  `piece_color` enum('B','R','G','Y') NOT NULL,
  `token` varchar(100) DEFAULT NULL,
  `last_action` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Άδειασμα δεδομένων του πίνακα `players`
--

INSERT INTO `players` (`username`, `piece_color`, `token`, `last_action`) VALUES
(NULL, 'B', NULL, NULL),
('newuser', 'R', 'deee32b1ac5d126f8593beb4fc775ae3', '2024-01-10 15:18:47'),
(NULL, 'G', NULL, NULL),
(NULL, 'Y', NULL, NULL);

-- --------------------------------------------------------

--
-- Δομή πίνακα για τον πίνακα `players_empty`
--

CREATE TABLE `players_empty` (
  `username` varchar(20) DEFAULT NULL,
  `piece_color` enum('B','R','G','Y') NOT NULL,
  `token` varchar(100) DEFAULT NULL,
  `last_action` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Άδειασμα δεδομένων του πίνακα `players_empty`
--

INSERT INTO `players_empty` (`username`, `piece_color`, `token`, `last_action`) VALUES
(NULL, 'B', NULL, NULL),
(NULL, 'R', NULL, NULL),
(NULL, 'G', NULL, NULL),
(NULL, 'Y', NULL, NULL);

-- --------------------------------------------------------

--
-- Δομή πίνακα για τον πίνακα `redwin`
--

CREATE TABLE `redwin` (
  `piece` varchar(50) NOT NULL,
  `piece_color` varchar(50) NOT NULL,
  `id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Άδειασμα δεδομένων του πίνακα `redwin`
--

INSERT INTO `redwin` (`piece`, `piece_color`, `id`) VALUES
('R1', 'R', 1),
('R2', 'R', 2),
('R3', 'R', 3),
('R4', 'R', 4);

-- --------------------------------------------------------

--
-- Δομή πίνακα για τον πίνακα `yellowwin`
--

CREATE TABLE `yellowwin` (
  `piece` varchar(50) NOT NULL,
  `piece_color` varchar(50) NOT NULL,
  `id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Ευρετήρια για άχρηστους πίνακες
--

--
-- Ευρετήρια για πίνακα `blackwin`
--
ALTER TABLE `blackwin`
  ADD PRIMARY KEY (`piece`,`piece_color`,`id`) USING BTREE;

--
-- Ευρετήρια για πίνακα `board`
--
ALTER TABLE `board`
  ADD PRIMARY KEY (`x`,`y`);

--
-- Ευρετήρια για πίνακα `board_empty`
--
ALTER TABLE `board_empty`
  ADD PRIMARY KEY (`x`,`y`);

--
-- Ευρετήρια για πίνακα `dice`
--
ALTER TABLE `dice`
  ADD PRIMARY KEY (`piece`,`created_at`) USING BTREE;

--
-- Ευρετήρια για πίνακα `greenwin`
--
ALTER TABLE `greenwin`
  ADD PRIMARY KEY (`piece`,`piece_color`,`id`) USING BTREE;

--
-- Ευρετήρια για πίνακα `players`
--
ALTER TABLE `players`
  ADD PRIMARY KEY (`piece_color`);

--
-- Ευρετήρια για πίνακα `players_empty`
--
ALTER TABLE `players_empty`
  ADD PRIMARY KEY (`piece_color`);

--
-- Ευρετήρια για πίνακα `redwin`
--
ALTER TABLE `redwin`
  ADD PRIMARY KEY (`piece`,`piece_color`,`id`);

--
-- Ευρετήρια για πίνακα `yellowwin`
--
ALTER TABLE `yellowwin`
  ADD PRIMARY KEY (`piece`,`piece_color`,`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
