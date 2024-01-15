<?php
function showPlayStatus() {
    global $mysqli;
    $sql = 'select * from game_status';
    $st = $mysqli->prepare($sql);
    $st->execute();
    $res = $st->get_result();
    
    $gameStatus = $res->fetch_all(MYSQLI_ASSOC);

    if (!$gameStatus) {
        // Καμία ή κακομορφη απάντηση, επιστροφή
        return;
    }

    header('Content-type: application/json');
    print json_encode($gameStatus, JSON_PRETTY_PRINT);
}


function handleUser($method, $b,$input) {
	if($method=='GET') {
		displayUser($b);
	} else if($method=='PUT') {
        setUser($b,$input);
    } 	 
}
function readStatus() {
	global $mysqli;
	
	$sql = 'select * from game_status';
	$st = $mysqli->prepare($sql);

	$st->execute();
	$res = $st->get_result();
	$status = $res->fetch_assoc();
	return($status);
}
function updateGameStatus() {
    global $mysqli;
    $currentStatus = readCurrentStatus();
    $newStatus = null;
    $newTurn = null;
    $inactivePlayersQuery = $mysqli->prepare('SELECT COUNT(*) AS aborted FROM players WHERE last_action < (NOW() - INTERVAL 5 MINUTE)');
    $inactivePlayersQuery->execute();
    $inactivePlayersResult = $inactivePlayersQuery->get_result();
    $abortedCount = $inactivePlayersResult->fetch_assoc()['aborted'];

    if ($abortedCount > 0) {
        $updateInactivePlayers = "UPDATE players SET username=NULL, token=NULL WHERE last_action < (NOW() - INTERVAL 5 MINUTE)";
        $updateInactivePlayersQuery = $mysqli->prepare($updateInactivePlayers);
        $updateInactivePlayersQuery->execute();

        if ($currentStatus['status'] == 'started') {
            $newStatus = 'aborted';
        }
    }

    $activePlayersQuery = 'SELECT COUNT(*) AS active_players FROM players WHERE username IS NOT NULL';
    $activePlayersStatement = $mysqli->prepare($activePlayersQuery);
    $activePlayersStatement->execute();
    $activePlayersResult = $activePlayersStatement->get_result();
    $activePlayersCount = $activePlayersResult->fetch_assoc()['active_players'];

    switch ($activePlayersCount) {
        case 0: $newStatus = 'not active'; break;
        case 1: $newStatus = 'initialized'; break;
        case 2:
        case 3:
        case 4:
            $newStatus = 'started';
            if ($currentStatus['turn'] == null) {
                $newTurn = 'Y';
            }
            break;
    }

    $updateGameStatusQuery = 'UPDATE game_status SET status=?, turn=?';
    $updateGameStatusStatement = $mysqli->prepare($updateGameStatusQuery);
    $updateGameStatusStatement->bind_param('ss', $newStatus, $newTurn);
    $updateGameStatusStatement->execute();
}

function readCurrentStatus() {
    global $mysqli;

    $statusQuery = 'SELECT * FROM game_status';
    $statusStatement = $mysqli->prepare($statusQuery);

    $statusStatement->execute();
    $statusResult = $statusStatement->get_result();
    $currentStatus = $statusResult->fetch_assoc();

    return $currentStatus;
}
function displayUsers() {
    global $mysqli;
    $query = 'SELECT username, piece_color FROM players';
    $statement = $mysqli->prepare($query);
    $statement->execute();
    $result = $statement->get_result();
    header('Content-type: application/json');
    print json_encode($result->fetch_all(MYSQLI_ASSOC), JSON_PRETTY_PRINT);
}

function displayUserByColor($color) {
    global $mysqli;
    $query = 'SELECT username, piece_color FROM players WHERE piece_color=?';
    $statement = $mysqli->prepare($query);
    $statement->bind_param('s', $color);
    $statement->execute();
    $result = $statement->get_result();
    header('Content-type: application/json');
    print json_encode($result->fetch_all(MYSQLI_ASSOC), JSON_PRETTY_PRINT);
}

function setUserByColor($color, $input) {
    if (!isset($input['username']) || $input['username'] == '') {
        header("HTTP/1.1 400 Bad Request");
        print json_encode(['errormesg' => "No username given."]);
        exit;
    }
    $username = $input['username'];
    global $mysqli;
    $queryCheckPlayer = 'SELECT COUNT(*) AS c FROM players WHERE piece_color=? AND username IS NOT NULL';
    $statementCheckPlayer = $mysqli->prepare($queryCheckPlayer);
    $statementCheckPlayer->bind_param('s', $color);
    $statementCheckPlayer->execute();
    $resultCheckPlayer = $statementCheckPlayer->get_result();
    $countResult = $resultCheckPlayer->fetch_all(MYSQLI_ASSOC);

    if ($countResult[0]['c'] > 0) {
        header("HTTP/1.1 400 Bad Request");
        print json_encode(['errormesg' => "Player $color is already set. Please select another color."]);
        exit;
    }
    $queryUpdatePlayer = 'UPDATE players SET username=?, token=MD5(CONCAT( ?, NOW())) WHERE piece_color=?';
    $statementUpdatePlayer = $mysqli->prepare($queryUpdatePlayer);
    $statementUpdatePlayer->bind_param('sss', $username, $username, $color);
    $statementUpdatePlayer->execute();


    $queryGetPlayer = 'SELECT * FROM players WHERE piece_color=?';
    $statementGetPlayer = $mysqli->prepare($queryGetPlayer);
    $statementGetPlayer->bind_param('s', $color);
    $statementGetPlayer->execute();
    $resultGetPlayer = $statementGetPlayer->get_result();
    header('Content-type: application/json');
    print json_encode($resultGetPlayer->fetch_all(MYSQLI_ASSOC), JSON_PRETTY_PRINT);
}

function processUser($method, $color, $input) {
    if ($method == 'GET') {
        displayUserByColor($color);
    } else if ($method == 'PUT') {
        setUserByColor($color, $input);
    }     
}

function resetPlayers() {
    global $mysqli;
    $query = 'CALL cleanPlayers()';
    $mysqli->query($query);
    displayUsers();
}

function getColorByToken($token) {
    global $mysqli;
    if ($token == null) {
        return (null);
    }
    $query = 'SELECT * FROM players WHERE token=?';
    $statement = $mysqli->prepare($query);
    $statement->bind_param('s', $token);
    $statement->execute();
    $result = $statement->get_result();
    if ($row = $result->fetch_assoc()) {
        return ($row['piece_color']);
    }
    return (null);
}

function returnLostUsers(){
    global $mysqli;

    // Clear the session variable after processing the request
    unset($_SESSION['already_requested']);

    $sql = 'CALL returnLosers();';
    $st = $mysqli -> prepare($sql);
    $st -> execute();
    if ($st->errno) {
        header('Content-type: application/json');
        print json_encode(['error' => $st->error], JSON_PRETTY_PRINT);
    } else {
        header('Content-type: application/json');
        print json_encode(['success' => true], JSON_PRETTY_PRINT);
    }
}
function curColor($token) {
	global $mysqli;
	if($token==null) {
        return(null);
    }
	$sql = 'select * from players where token=?';
	$st = $mysqli->prepare($sql);
	$st->bind_param('s',$token);
	$st->execute();
	$res = $st->get_result();
	if($row=$res->fetch_assoc()) {
		return($row['piece_color']);
	}
	return(null);
}

?>