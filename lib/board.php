<?php
 // $sql = 'call clean_board()';



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
//	$orig_board=read_board();
///	$board=convert_board($orig_board);

//ελεγχος κινησεων του συγκεκριμενου πιονιου(για n=0->πιονι δε μπορει να κινηθει)
//add_valid_moves_to_piece->θα προσθεσω στο πινακα τις νομιμες κινησεις του καθε πιονιου και ελεγχω
//εαν ναι τοτε do move
//	$n = add_valid_moves_to_piece($board,$color,$x,$y);

	//if($n==0) {
//		header("HTTP/1.1 400 Bad Request");
//		print json_encode(['errormesg'=>"This piece cannot move."]);
//		exit;
//	}
//	foreach($board[$x][$y]['moves'] as $i=>$move) {
	//	if($x2==$move['x'] && $y2==$move['y']) {
	   	do_move($x,$y,$x2,$y2);
	//  do_move_yellow();
//	 roll_dice();
	 	 show_board();	
		exit;
	//	}
//	}
 	header("HTTP/1.1 400 Bad Request");
 	print json_encode(['errormesg'=>"This move is illegal."]);
 	exit;
	// do_move($x,$y,$x2,$y2);
	// show_board();
}

function do_move($x,$y,$x2,$y2) {
	global $mysqli;

	$sql = 'call move_piece(?,?,?,?)';
	$st = $mysqli->prepare($sql);
	$st->bind_param('iiii',$x,$y,$x2,$y2 );
	$st->execute();
//header("HTTP/1.1 200 OK.");
	//print json_encode(['errormesg'=>"INSIDE DO MOVE."]);
	//header('Content-type: application/json');
	//print json_encode(read_board(), JSON_PRETTY_PRINT);
	// show_board();
}

//function do_move_yellow() {
//	global $mysqli;
//	// Assuming you have a database connection in $conn
//$sql = "CALL move_y_piece()";
//$st = $mysqli -> prepare($sql);
//
//$st -> execute();
//$res = $st -> get_result();
//
//header('Content-type: application/json');
//print json_encode($res->fetch_all(MYSQLI_ASSOC), JSON_PRETTY_PRINT);
//	 
//}
//
//function roll_dice($b){
//	global $mysqli;
//
//	//orig_board->ολος ο πινακας απο την βαση(read_board: select * from board)
//	$orig_board=read_board();
//	$board=convert_board($orig_board);
//	$status = read_status();
//	//p_turn=$b -> ειναι η σειρα του παικτη που εκανε την αιτηση να παιξει
//	if($status['status']=='started' && $status['p_turn']==$b && $b!=null) {
//		// It my turn !!!!
//		$n = add_valid_moves_to_board($board,$b);
//		
//		// Εάν n==0, τότε έχασα !!!!!
//		// Θα πρέπει να ενημερωθεί το game_status.
//	}
//	header('Content-type: application/json');
//	print json_encode($orig_board, JSON_PRETTY_PRINT);
//
//function add_valid_moves_to_piece(&$board,$b,$x,$y) {
//	$number_of_moves=0;
//	//ελεγχος εαν το χρωμα του πιονιου ανηκει στον παικτη που κανει την κινηση
//	if($board[$x][$y]['piece_color']==$b) {
//		switch($board[$x][$y]['piece']){
//			case 'Y1': roll_dice_Y() ;break;
//			case 'Y2': ;break;
//			case 'Y3':  ;break;
//			case 'Y4':  ;break;
//			case 'R1':roll_dice_R();break;
//			case 'R2':  ;break;
//			case 'R3':  ;break;
//			case 'R4': $number_of_moves+=bishop_moves($board,$b,$x,$y);break;
//		}
//	} 
//	 
//
//
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



//ελεγχος ποιος χρηστης μας ζηταει το Board & ποιος εχει σειρα να παιξει
//  function show_board_by_player($b) {
//
//	global $mysqli;
//
//	//orig_board->ολος ο πινακας απο την βαση(read_board: select * from board)
//	$orig_board=read_board();
//	$board=convert_board($orig_board);
//	$status = read_status();
//	//p_turn=$b -> ειναι η σειρα του παικτη που εκανε την αιτηση να παιξει
//	if($status['status']=='started' && $status['p_turn']==$b && $b!=null) {
//		// It my turn !!!!
//		$n = add_valid_moves_to_board($board,$b);
//		
//		// Εάν n==0, τότε έχασα !!!!!
//		// Θα πρέπει να ενημερωθεί το game_status.
//	}
//	header('Content-type: application/json');
//	print json_encode($orig_board, JSON_PRETTY_PRINT);
//  }

//call by reference: τα στοιχεια του νεου πινακα δεν υπαρχουν στην πραγματικοτητα σαν obj
//δειχνουν στην αντιστοιχη θεση του αρχικου πινακα
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

// function add_valid_moves_to_board(&$board,$b) {
//	$number_of_moves=0;
//	
//	for($x=1;$x<12;$x++) {
//		for($y=1;$y<12;$y++) {
//			$number_of_moves+=add_valid_moves_to_piece($board,$b,$x,$y);
//		}
//	}
//	return($number_of_moves);
//  }
//
//  function add_valid_moves_to_piece(&$board,$b,$x,$y) {
//	$number_of_moves=0;
//	if($board[$x][$y]['piece_color']==$b) {
//		switch($board[$x][$y]['piece']){
//			case 'Y': $number_of_moves+=y_moves($board,$b,$x,$y);break;
//			case 'R': $number_of_moves+=r_moves($board,$b,$x,$y);break;
//			 
//		}
//	} 
//	return($number_of_moves);
// }
//
// function y_moves(&$board,$b,$x,$y) {
//	$m = [
//		[2,1],
//		[1,2],
//		[2,-1],
//		[1,-2],
//		[-2,1],
//		[-1,2],
//		[-2,-1],
//		[-1,-2],
//	];
//	$moves=[];
//	foreach($m as $k=>$t) {
//		$x2=$x+$t[0];
//		$y2=$y+$t[1];
//		if( $x2>=1 && $x2<=11 && $y2>=1 && $y2<=11 &&
//			$board[$x2][$y2]['piece_color'] !=$b ) {
//			// Αν ο προορισμός είναι εντός σκακιέρας και δεν υπάρχει δικό μου πιόνι
//			$move=['x'=>$x2, 'y'=>$y2];
//			$moves[]=$move;
//		}
//	}
//	$board[$x][$y]['moves'] = $moves;
//	return(sizeof($moves));
// }
//

function reset_board(){
  global $mysqli;
  $sql = 'call clean_board()';
  $mysqli->query($sql);
  show_board();
}  
?>