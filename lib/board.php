<?php




function show_piece($x,$y) {
	global $mysqli;
	
	$sql = 'select * from board where x=? and y=?';
	$st = $mysqli->prepare($sql);
	$st->bind_param('ii',$x,$y);
	$st->execute();
	$res = $st->get_result();
	header('Content-type: application/json');
	print json_encode($res->fetch_all(MYSQLI_ASSOC), JSON_PRETTY_PRINT);
}

function move_piece($x,$y,$x2,$y2,$token) {
	//ελεγχος αν εχει στειλει token ο χρηστης
	if($token==null || $token=='') {
		header("HTTP/1.1 400 Bad Request");
		print json_encode(['errormesg'=>"token is not set."]);
		exit;
	}
	
//current_color -> βρισκεται στo users.php
//επιστρεφει το row του χρωματος εαν υπαρχει
	$color = current_color($token);
	if($color==null ) {
		header("HTTP/1.1 400 Bad Request");
		print json_encode(['errormesg'=>"You are not a player of this game."]);
		exit;
	}

	//το στατους πρεπει να ναι started για να γινει μια κινηση
	//read_status()->βρισκεται στο game.php και επιστρεφει το status
		$status = read_status();
	if($status['status']!='started') {
		header("HTTP/1.1 400 Bad Request");
		print json_encode(['errormesg'=>"Game is not in action."]);
		exit;
	}

//εαν το p_turn δε ταιριαζει με το χρωμα του παικτη επιστρεφω μνμα λαθους
	if($status['p_turn']!=$color) {
		header("HTTP/1.1 400 Bad Request");
		//print json_encode(['errormesg'=>"It is not your turn."]);
		exit;
	}

	   	do_move($x,$y,$x2,$y2);
	
	 	 show_board();	
		exit;
	
 	header("HTTP/1.1 400 Bad Request");
 	print json_encode(['errormesg'=>"This move is illegal."]);
 	exit;
	
}

function do_move($x, $y, $x2, $y2)
{
    global $mysqli;

    $sql = 'call move_piece(?,?,?,?)';
    $st = $mysqli->prepare($sql);
    $st->bind_param('iiii', $x, $y, $x2, $y2);
    $st->execute();

    // Check if the move was successful
    $result = $st->get_result();
    $data = $result->fetch_all(MYSQLI_ASSOC);

    if (!empty($data)) {
        // Move was successful, show the updated board
        show_board();
    } else {
        // Move failed, return an error
        header("HTTP/1.1 400 Bad Request");
        print json_encode(['errormesg' => "This move is illegal."]);
        exit;
    }
}



function show_board_by_player($b) {

	global $mysqli;

	$orig_board=read_board();
	$board=convert_board($orig_board);
	$status = read_status();
	if($status['status']=='started' && $status['p_turn']==$b && $b!=null) {
		// It my turn !!!!
		$n = add_valid_moves_to_board($board,$b);
		
		// Εάν n==0, τότε έχασα !!!!!
		// Θα πρέπει να ενημερωθεί το game_status.
	}
	header('Content-type: application/json');
	print json_encode($orig_board, JSON_PRETTY_PRINT);
}
 
function roll() {
    global $mysqli;

    // Call roll_diceOUT procedure
    $sql = "CALL roll_diceOUT(@generated_dice_result)";
    $st = $mysqli->prepare($sql);
    $st->execute();

    $result = $st->get_result();
    $data = $result->fetch_all(MYSQLI_ASSOC);
$st -> close();

    // Return the data as JSON
    header('Content-type: application/json');
    echo json_encode($data, JSON_PRETTY_PRINT);

	$pieceNumbers = array(1, 2, 3, 4, 111, 222, 333, 444);

	foreach ($pieceNumbers as $piece_num) {
        $sqlRollDice = "CALL roll_dice(?, @generated_dice_result)";
        $stRollDice = $mysqli->prepare($sqlRollDice);

        // Check if the prepare statement was successful for roll_dice
        if (!$stRollDice) {
            echo "Error in prepare statement: " . $mysqli->error;
        } else {
            // Bind the parameter and execute the stored procedure
            $stRollDice->bind_param("i", $piece_num);
            $stRollDice->execute();
            $stRollDice->close();}
  
}

 
}

 function roll_dice($piece_num) {
 
	switch ($piece_num) {
		case 1: roll_dice_Y1();  break;
		case 2: roll_dice_Y2();  break;
		case 3: roll_dice_Y3();   break;
		case 4: roll_dice_Y4();  break;
		case 111: roll_dice_R1(); break;
		case 222: roll_dice_R2(); break;
		case 333: roll_dice_R3(); break;
		case 444: roll_dice_R4();   break;
		default:
			echo "Invalid piece number.";
			break;
	}
}
// }

function roll_dice_Y1() {
	global $mysqli;

    $sql = 'CALL  Y1_dice() ; ';
    $st = $mysqli->prepare($sql);
    $st->execute();

    $result = $st->get_result();
    $data = $result->fetch_all(MYSQLI_ASSOC);

    // Return the data as JSON
    header('Content-type: application/json');
    echo json_encode($data, JSON_PRETTY_PRINT);
}
  function Y1_highlight() {
	global $mysqli;

    $sql = 'CALL  Y1_highlight() ; ';
    $st = $mysqli->prepare($sql);
    $st->execute();

    $result = $st->get_result();
    $data = $result->fetch_all(MYSQLI_ASSOC);

    // Return the data as JSON
    header('Content-type: application/json');
    echo json_encode($data, JSON_PRETTY_PRINT);
  }
 
function roll_dice_Y2(){
	global $mysqli;
 
    $sql = 'CALL  Y2_dice() ;';
    $st = $mysqli->prepare($sql);
	$st->execute();

    // Fetch the results
    $result = $st->get_result();
    $data = $result->fetch_all(MYSQLI_ASSOC);

    // Return the data as JSON
    header('Content-type: application/json');
    echo json_encode($data, JSON_PRETTY_PRINT);
}
function Y2_highlight() {
	global $mysqli;

    $sql = 'CALL  Y2_highlight() ; ';
    $st = $mysqli->prepare($sql);
    $st->execute();

    $result = $st->get_result();
    $data = $result->fetch_all(MYSQLI_ASSOC);

    // Return the data as JSON
    header('Content-type: application/json');
    echo json_encode($data, JSON_PRETTY_PRINT);
}

function roll_dice_Y3(){
	global $mysqli;
	
    $sql = 'CALL  Y3_dice() ;';
    $st = $mysqli->prepare($sql);
	$st->execute();

    // Fetch the results
    $result = $st->get_result();
    $data = $result->fetch_all(MYSQLI_ASSOC);

    // Return the data as JSON
    header('Content-type: application/json');
    echo json_encode($data, JSON_PRETTY_PRINT);
}
function Y3_highlight() {
	global $mysqli;

    $sql = 'CALL  Y3_highlight() ; ';
    $st = $mysqli->prepare($sql);
    $st->execute();

    $result = $st->get_result();
    $data = $result->fetch_all(MYSQLI_ASSOC);

    // Return the data as JSON
    header('Content-type: application/json');
    echo json_encode($data, JSON_PRETTY_PRINT);
}

function roll_dice_Y4(){
	global $mysqli;
	
    $sql = 'CALL  Y4_dice()   ;';
    $st = $mysqli->prepare($sql);
    $st->execute();

    // Fetch the results
    $result = $st->get_result();
    $data = $result->fetch_all(MYSQLI_ASSOC);

    // Return the data as JSON
    header('Content-type: application/json');
    echo json_encode($data, JSON_PRETTY_PRINT);
}
function Y4_highlight() {
	global $mysqli;

    $sql = 'CALL  Y4_highlight() ; ';
    $st = $mysqli->prepare($sql);
    $st->execute();

    $result = $st->get_result();
    $data = $result->fetch_all(MYSQLI_ASSOC);

    // Return the data as JSON
    header('Content-type: application/json');
    echo json_encode($data, JSON_PRETTY_PRINT);
}
function roll_dice_R1(){
	global $mysqli;
	
    $sql = 'CALL  R1_dice() ;';
    $st = $mysqli->prepare($sql);
    $st->execute();

    // Fetch the results
    $result = $st->get_result();
    $data = $result->fetch_all(MYSQLI_ASSOC);

    // Return the data as JSON
    header('Content-type: application/json');
    echo json_encode($data, JSON_PRETTY_PRINT);
}
function R1_highlight() {
	global $mysqli;

    $sql = 'CALL  R1_highlight() ; ';
    $st = $mysqli->prepare($sql);
    $st->execute();

    $result = $st->get_result();
    $data = $result->fetch_all(MYSQLI_ASSOC);

    // Return the data as JSON
    header('Content-type: application/json');
    echo json_encode($data, JSON_PRETTY_PRINT);
}
function roll_dice_R2(){
	global $mysqli;
	
    $sql = 'CALL  R2_dice() ;';
    $st = $mysqli->prepare($sql);
	$st->execute();

    // Fetch the results
    $result = $st->get_result();
    $data = $result->fetch_all(MYSQLI_ASSOC);

    // Return the data as JSON
    header('Content-type: application/json');
    echo json_encode($data, JSON_PRETTY_PRINT);
}
function R2_highlight() {
	global $mysqli;

    $sql = 'CALL  R2_highlight() ; ';
    $st = $mysqli->prepare($sql);
    $st->execute();

    $result = $st->get_result();
    $data = $result->fetch_all(MYSQLI_ASSOC);

    // Return the data as JSON
    header('Content-type: application/json');
    echo json_encode($data, JSON_PRETTY_PRINT);
}
function roll_dice_R3(){
	global $mysqli;
	
    $sql = 'CALL  R3_dice() ;';
    $st = $mysqli->prepare($sql);
	$st->execute();

    // Fetch the results
    $result = $st->get_result();
    $data = $result->fetch_all(MYSQLI_ASSOC);

    // Return the data as JSON
    header('Content-type: application/json');
    echo json_encode($data, JSON_PRETTY_PRINT);
}
function R3_highlight() {
	global $mysqli;

    $sql = 'CALL  R3_highlight() ; ';
    $st = $mysqli->prepare($sql);
    $st->execute();

    $result = $st->get_result();
    $data = $result->fetch_all(MYSQLI_ASSOC);

    // Return the data as JSON
    header('Content-type: application/json');
    echo json_encode($data, JSON_PRETTY_PRINT);
}
function roll_dice_R4(){
	global $mysqli;
	
    $sql = 'CALL  R4_dice() ;';
    $st = $mysqli->prepare($sql);
    $st->execute();

    // Fetch the results
    $result = $st->get_result();
    $data = $result->fetch_all(MYSQLI_ASSOC);

    // Return the data as JSON
    header('Content-type: application/json');
    echo json_encode($data, JSON_PRETTY_PRINT);
}
function R4_highlight() {
	global $mysqli;

    $sql = 'CALL  R4_highlight() ; ';
    $st = $mysqli->prepare($sql);
    $st->execute();

    $result = $st->get_result();
    $data = $result->fetch_all(MYSQLI_ASSOC);

    // Return the data as JSON
    header('Content-type: application/json');
    echo json_encode($data, JSON_PRETTY_PRINT);
}

function show_board(){
    global $mysqli;
    $sql = 'select * from board';
    $st = $mysqli -> prepare($sql);
    $st -> execute();
    $res = $st -> get_result();
    header('Content-type: application/json');
    print json_encode($res->fetch_all(MYSQLI_ASSOC), JSON_PRETTY_PRINT);
}



function convert_board(&$orig_board) {
	$board=[];
	foreach($orig_board as $i=>&$row) {
		$board[$row['x']][$row['y']] = &$row;
	} 
	return($board);
}


function read_board() {
	global $mysqli;
	$sql = 'select * from board';
	$st = $mysqli->prepare($sql);
	$st->execute();
	$res = $st->get_result();  
	return($res->fetch_all(MYSQLI_ASSOC));
}


function reset_board(){
  global $mysqli;
  $sql = 'call clean_board()';
  $mysqli->query($sql);
  show_board();
}  
?>