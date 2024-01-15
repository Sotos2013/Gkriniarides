<?php
function displayPiece($positionX, $positionY) {
    global $mysqli;

    $query = 'SELECT * FROM board WHERE x=? AND y=?';
    $statement = $mysqli->prepare($query);
    $statement->bind_param('ii', $positionX, $positionY);
    $statement->execute();
    $result = $statement->get_result();
    header('Content-type: application/json');
    echo json_encode($result->fetch_all(MYSQLI_ASSOC), JSON_PRETTY_PRINT);
}
function showPiece($x,$y) {
	global $mysqli;
	
	$sql = 'select * from board where x=? and y=?';
	$st = $mysqli->prepare($sql);
	$st->bind_param('ii',$x,$y);
	$st->execute();
	$res = $st->get_result();
	header('Content-type: application/json');
	print json_encode($res->fetch_all(MYSQLI_ASSOC), JSON_PRETTY_PRINT);
}
function movePiece($startX, $startY, $targetX, $targetY, $userToken) {
    if ($userToken == null || $userToken == '') {
        header("HTTP/1.1 400 Bad Request");
        print json_encode(['errorMessage' => "Token is not set."]);
        exit;
    }

    $playerColor = curColor($userToken);
    if ($playerColor == null) {
        header("HTTP/1.1 400 Bad Request");
        print json_encode(['errorMessage' => "You are not a player of this game."]);
        exit;
    }

    performMove($startX, $startY, $targetX, $targetY);

    displayBoard();
    exit;
}

function performMove($startX, $startY, $endX, $endY) {
    global $mysqli;

    $query = 'CALL movePiece(?, ?, ?, ?);';
    $statement = $mysqli->prepare($query);
    $statement->bind_param('iiii', $startX, $startY, $endX, $endY);
    $statement->execute();
}


function displayBoardByPlayer($pieceColor) {
    global $mysqli;

    $originalBoard = readBoard();
    $board = convertBoard($originalBoard);
    $gameStatus = readStatus();

    if ($gameStatus['status'] == 'started' && $gameStatus['p_turn'] == $pieceColor && $pieceColor != null) {
        $numberOfValidMoves = addValidMovesToBoard($board, $pieceColor);
    }

    header('Content-type: application/json');
    echo json_encode($originalBoard, JSON_PRETTY_PRINT);
}
function redWin() {
    global $mysqli;
    $mysqli->query("CALL Winners();");
    $sql = 'SELECT DISTINCT piece FROM redwin WHERE id>0';
    $result = $mysqli->query($sql);
    $pieceValues = array();
    if ($result->num_rows > 0) {
        while ($row = $result->fetch_assoc()) {
            $pieceValues[] = $row["piece"];
        }
    }
    header('Content-type: application/json');
    echo json_encode(['pieceValues' => $pieceValues], JSON_PRETTY_PRINT);
}
function blackWin() {
    global $mysqli;
    $mysqli->query("CALL Winners();");
    $sql = 'SELECT DISTINCT piece FROM blackwin WHERE id>0';
    $result = $mysqli->query($sql);
    $pieceValues = array();
    if ($result->num_rows > 0) {
        while ($row = $result->fetch_assoc()) {
            $pieceValues[] = $row["piece"];
        }
    }
    header('Content-type: application/json');
    echo json_encode(['pieceValues' => $pieceValues], JSON_PRETTY_PRINT);
}
function yellowWin() {
    global $mysqli;
    $mysqli->query("CALL Winners();");
    $sql = 'SELECT DISTINCT piece FROM yellowwin WHERE id>0';
    $result = $mysqli->query($sql);
    $pieceValues = array();
    if ($result->num_rows > 0) {
        while ($row = $result->fetch_assoc()) {
            $pieceValues[] = $row["piece"];
        }
    }
    header('Content-type: application/json');
    echo json_encode(['pieceValues' => $pieceValues], JSON_PRETTY_PRINT);
}
function greenWin() {
    global $mysqli;
    $mysqli->query("CALL Winners();");
    $sql = 'SELECT DISTINCT piece FROM greenwin WHERE id>0';
    $result = $mysqli->query($sql);
    $pieceValues = array();
    if ($result->num_rows > 0) {
        while ($row = $result->fetch_assoc()) {
            $pieceValues[] = $row["piece"];
        }
    }
    header('Content-type: application/json');
    echo json_encode(['pieceValues' => $pieceValues], JSON_PRETTY_PRINT);
}


function rollDice() {
    global $mysqli;

    $query = "CALL rollDiceOUT(@ranDiceResult)";
    $statement = $mysqli->prepare($query);
    $statement->execute();

    $result = $statement->get_result();
    $data = $result->fetch_all(MYSQLI_ASSOC);
    $statement->close();

    header('Content-type: application/json');
    echo json_encode($data, JSON_PRETTY_PRINT);

    $pieceNumbers = array(1, 2, 3, 4, 111, 222, 333, 444,1111,2222,3333,4444,11,22,33,44);

    foreach ($pieceNumbers as $pieceNum) {
        $queryRollDice = "CALL rollDice(?, @ranDiceResult)";
        $statementRollDice = $mysqli->prepare($queryRollDice);

        if (!$statementRollDice) {
            echo "Error in prepare statement: " . $mysqli->error;
        } else {
            $statementRollDice->bind_param("i", $pieceNum);
            $statementRollDice->execute();
            $statementRollDice->close();
        }
    }
}

function rollDiceForPiece($pieceNum) {
    switch ($pieceNum) {
        case 'Y1':
            rollDiceFor('Y1');
            break;
        case 'Y2':
            rollDiceFor('Y2');
            break;
        case 'Y3':
            rollDiceFor('Y3');
            break;
        case 'Y4':
            rollDiceFor('Y4');
            break;
        case 'R1':
            rollDiceFor('R1');
            break;
        case 'R2':
            rollDiceFor('R2');
            break;
        case 'R3':
            rollDiceFor('R3');
            break;
        case 'R4':
            rollDiceFor('R4');
            break;
        case 'B1':
            rollDiceFor('B1');
            break;
        case 'B2':
            rollDiceFor('B2');
            break;
        case 'B3':
            rollDiceFor('B3');
            break;
        case 'B4':
            rollDiceFor('B4');
            break;
        case 'G1':
            rollDiceFor('G1');
            break;
        case 'G2':
            rollDiceFor('G2');
            break;
        case 'G3':
            rollDiceFor('G3');
            break;
        case 'G4':
            rollDiceFor('G4');
            break;
        default:
            echo "Invalid piece number.";
            break;
    }
}


function rollDiceFor($pieceNum) {
    global $mysqli;

    $validPieces = ['Y1', 'Y2', 'Y3', 'Y4', 'R1', 'R2', 'R3', 'R4', 'B1', 'B2', 'B3', 'B4', 'G1', 'G2', 'G3', 'G4'];

    if (in_array($pieceNum, $validPieces)) {
        $query = "CALL rollDiceFor{$pieceNum}();";
        executeRollDiceQuery($mysqli, $query);
    } else {
        echo "Invalid piece number.";
    }
}

function executeRollDiceQuery($mysqli, $query) {
    $statement = $mysqli->prepare($query);
    $statement->execute();

    $result = $statement->get_result();
    $data = $result->fetch_all(MYSQLI_ASSOC);

    header('Content-type: application/json');
    echo json_encode($data, JSON_PRETTY_PRINT);
}

function displayBoard() {
    global $mysqli;
    $query = 'SELECT * FROM board';
    executeRollDiceQuery($mysqli, $query);
}

function convertBoard(&$originalBoard) {
    $board = [];
    foreach ($originalBoard as $i => &$row) {
        $board[$row['x']][$row['y']] = &$row;
    }
    return ($board);
}

function readBoard() {
    global $mysqli;
    $query = 'SELECT * FROM board';
    $statement = $mysqli->prepare($query);
    $statement->execute();
    $result = $statement->get_result();
    return ($result->fetch_all(MYSQLI_ASSOC));
}

function resetBoard() {
    global $mysqli;
    $query = 'CALL cleanBoard()';
    $mysqli->query($query);
    displayBoard();
}
function resetStatus() {
    global $mysqli;
    $query = 'CALL resetStatus()';
    $mysqli->query($query);
}
?>