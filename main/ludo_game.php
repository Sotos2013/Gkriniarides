<?php
error_reporting(E_ALL);
ini_set('display_errors', 'On');

require_once "../php/dbconnect.php";
require_once "../php/table.php";
require_once "../php/init.php"; 


$RequestMethod = $_SERVER['REQUEST_METHOD'];
$RequestPath = explode('/', trim($_SERVER['PATH_INFO'],'/'));
$InputData = json_decode(file_get_contents('php://input'), true);
if($InputData == null) {
    $InputData = [];
}
if(isset($_SERVER['HTTP_X_TOKEN'])) {
    $InputData['token'] = $_SERVER['HTTP_X_TOKEN'];
} else {
    $InputData['token'] = '';
}

switch ($Route = array_shift($RequestPath)) {
    case 'board' :
        switch ($BoardRoute = array_shift($RequestPath)) {
            case '':
            case null: handleBoard($RequestMethod); break;
            case 'piece': handlePiece($RequestMethod, $RequestPath[0], $RequestPath[1], $InputData); break;
            default: header("HTTP/1.1 404 Not Found");
                     break;
        }
        break;
    case 'status':
        if(count($RequestPath) == 0) {
            handleStatus($RequestMethod);
        } else {
            header("HTTP/1.1 404 Not Found");
        }
        break;
    case 'players': handlePlayer($RequestMethod, $RequestPath, $InputData);
                    break;
    case 'delete_players': handleDeletePlayers($RequestMethod);
                          break;
    case 'roll': handleRoll($RequestMethod);
                  break;
    case 'rollY1': handleRollR('Y1',$RequestMethod);
                   break;
    case 'rollY2': handleRollR('Y2',$RequestMethod);
                   break;
    case 'rollY3': handleRollR('Y3',$RequestMethod);
                   break;
    case 'rollY4': handleRollR('Y4',$RequestMethod);
                   break;
    case 'highlightY1': handleHighlight('Y1',$RequestMethod);
                        break;
    case 'highlightY2': handleHighlight('Y2',$RequestMethod);
                        break;
    case 'highlightY3': handleHighlight('Y3',$RequestMethod);
                        break;
    case 'highlightY4': handleHighlight('Y4',$RequestMethod);
                        break;
    case 'rollR1':
        handleRollR('R1', $RequestMethod);
        break;
    case 'rollR2':
        handleRollR('R2', $RequestMethod);
        break;
    case 'rollR3':
        handleRollR('R3', $RequestMethod);
        break;
    case 'rollR4':
        handleRollR('R4', $RequestMethod);
        break;
    case 'highlightR1':
        handleHighlight('R1', $RequestMethod);
        break;
    case 'highlightR2':
        handleHighlight('R2', $RequestMethod);
        break;
    case 'highlightR3':
        handleHighlight('R3', $RequestMethod);
        break;
    case 'highlightR4':
        handleHighlight('R4', $RequestMethod);
        break;
        case 'rollB1':
            handleRollR('B1', $RequestMethod);
            break;
        case 'rollB2':
            handleRollR('B2', $RequestMethod);
            break;
        case 'rollB3':
            handleRollR('B3', $RequestMethod);
            break;
        case 'rollB4':
            handleRollR('B4', $RequestMethod);
            break;
        case 'highlightB1':
            handleHighlight('B1', $RequestMethod);
            break;
        case 'highlightB2':
            handleHighlight('B2', $RequestMethod);
            break;
        case 'highlightB3':
            handleHighlight('B3', $RequestMethod);
            break;
        case 'highlightB4':
            handleHighlight('B4', $RequestMethod);
            break;
            case 'rollG1':
                handleRollR('G1', $RequestMethod);
                break;
            case 'rollG2':
                handleRollR('G2', $RequestMethod);
                break;
            case 'rollG3':
                handleRollR('G3', $RequestMethod);
                break;
            case 'rollG4':
                handleRollR('G4', $RequestMethod);
                break;
            case 'highlightG1':
                handleHighlight('G1', $RequestMethod);
                break;
            case 'highlightG2':
                handleHighlight('G2', $RequestMethod);
                break;
            case 'highlightG3':
                handleHighlight('G3', $RequestMethod);
                break;
            case 'highlightG4':
                handleHighlight('G4', $RequestMethod);
                break;
    case 'return_losers': handleLosers($RequestMethod);
                        break;
    case 'redWin': handleRedWin($RequestMethod);
                    break;
    case 'blackWin': handleBlackWin($RequestMethod);
                    break;
    case 'yellowWin': handleYellowWin($RequestMethod);
                    break;
    case 'greenWin': handleGreenWin($RequestMethod);
                    break;
    default: header("HTTP/1.1 404 Not Found");
             print "<h1>not FOUND</h1>";
             exit;
}

function handleDeletePlayers($Method) {
    if($Method == 'GET') {
        header('HTTP/1.1 405 Method Not Allowed');
    } else if ($Method == 'POST') {
        resetPlayers();
    } else {
        header('HTTP/1.1 405 Method Not Allowed');
    }
}

function handleRoll($Method) {
    if($Method == 'GET') {
        rollDice();
    } else {
        header('HTTP/1.1 405 Method Not Allowed');
    }
}

function handleRollR($piece, $Method) {
    if ($Method == 'GET') {
        rollDiceForPiece($piece);
    } else {
        header('HTTP/1.1 405 Method Not Allowed');
    }
}

function handleHighlight($piece, $Method) {
    if ($Method == 'GET') {
        global $mysqli;
        $sql = "CALL highlight{$piece}();";
        $st = $mysqli->prepare($sql);
        $st->execute();

        $result = $st->get_result();
        $data = $result->fetch_all(MYSQLI_ASSOC);

        // Return the data as JSON
        header('Content-type: application/json');
        echo json_encode($data, JSON_PRETTY_PRINT);
    } else {
        header('HTTP/1.1 405 Method Not Allowed');
    }
}
function handleLosers($Method) {
    if ($Method == 'GET') {
        // Add a condition to avoid infinite loop
        if (!isset($_SESSION['already_requested'])) {
            $_SESSION['already_requested'] = true;
            returnLostUsers();
        } else {
            header('HTTP/1.1 429 Too Many Requests');
        }
    } else {
        header('HTTP/1.1 405 Method Not Allowed');
    }
}
function handleRedWin($method) {
    if($method=='GET') {
		redWin(); 
    }  else {header('HTTP/1.1 405 Method Not Allowed');}
}
function handleBlackWin($method) {
    if($method=='GET') {
		blackWin(); 
    }  else {header('HTTP/1.1 405 Method Not Allowed');}
}
function handleYellowWin($method) {
    if($method=='GET') {
		yellowWin(); 
    }  else {header('HTTP/1.1 405 Method Not Allowed');}
}
function handleGreenWin($method) {
    if($method=='GET') {
		greenWin(); 
    }  else {header('HTTP/1.1 405 Method Not Allowed');}
}
function handleBoard($Method) {
    if($Method == 'GET') {
        displayBoard();
    } else if ($Method == 'POST') {
        resetBoard();
    } else {
        header('HTTP/1.1 405 Method Not Allowed');
    }
}

function handlePiece($Method, $X, $Y, $Input) {
    if($Method == 'GET') {
        showPiece($X, $Y);
    } else if ($Method == 'PUT') {
        movePiece($X, $Y, $Input['x'], $Input['y'], $Input['token']);
    }    
}

function displayUser($b) {
	global $mysqli;
	$sql = 'select username,piece_color from players where piece_color=?';
	$st = $mysqli->prepare($sql);
	$st->bind_param('s',$b);
	$st->execute();
	$res = $st->get_result();
	header('Content-type: application/json');
	print json_encode($res->fetch_all(MYSQLI_ASSOC), JSON_PRETTY_PRINT);
}

function setUser($b, $input) {
	if (!isset($input['username']) || $input['username'] == '') {
		header("HTTP/1.1 400 Bad Request");
		print json_encode(['errormesg' => "No username given."]);
		exit;
	}
    global $mysqli;
    $query = 'CALL resetStatus()';
    $mysqli->query($query);
    $username = $input['username'];
	global $mysqli;
 
  
	$sql = 'select count(*) as c from players where piece_color=? and username is not null';
	$st = $mysqli->prepare($sql);
	$st->bind_param('s', $b);
	$st->execute();
    if ($st->error) {
        echo "SQL error: " . $st->error;
    }
	$res = $st->get_result();
	$r = $res->fetch_all(MYSQLI_ASSOC);
	
	if($r[0]['c']>0) {
		header("HTTP/1.1 400 Bad Request");
		print json_encode(['errormesg'=>"Player $b is already set. Please select another color."]);
		exit;
	}
	$sql = 'update players set username=?, token=md5(CONCAT( ?, NOW()))  where piece_color=?';
	$st2 = $mysqli->prepare($sql);
	$st2->bind_param('sss', $username, $username, $b);
	$st2->execute();
    if ($st->error) {
        echo "SQL error: " . $st->error;
    }
	$sql = 'select * from players where piece_color=?';
	$st = $mysqli->prepare($sql);
	$st->bind_param('s',$b);
	$st->execute();
	$res = $st->get_result();
	header('Content-type: application/json');
	print json_encode($res->fetch_all(MYSQLI_ASSOC), JSON_PRETTY_PRINT);
	
	
}

function handlePlayer($Method, $P, $Input) {
    switch ($PlayerType = array_shift($P)) {      
        case 'R':  handleUser($Method, $PlayerType, $Input);
                  break;
        case 'B':  handleUser($Method, $PlayerType, $Input);
                  break;
        case 'G':  handleUser($Method, $PlayerType, $Input);
                  break;
        case 'Y':  handleUser($Method, $PlayerType, $Input);
                  break;
        default: header("HTTP/1.1 404 Not Found");
                 print json_encode(['errormesg' => "Player $PlayerType not found."]);
                 break;
    }
}

function handleStatus($Method) {
    if($Method == 'GET') {
        showPlayStatus();
    } else {
        header('HTTP/1.1 405 Method Not Allowed');
    }
}



?>
