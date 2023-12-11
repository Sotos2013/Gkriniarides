<?php
require_once "../lib/dbconnect.php";
require_once "../lib/board.php";
require_once "../lib/game.php"; 
require_once "../lib/users.php";
 

$method = $_SERVER['REQUEST_METHOD'];
$request = explode('/', trim($_SERVER['PATH_INFO'],'/'));
$input = json_decode(file_get_contents('php://input'),true);
if($input==null) {
    $input=[];
}
if(isset($_SERVER['HTTP_X_TOKEN'])) {
    $input['token']=$_SERVER['HTTP_X_TOKEN'];
} else {
    $input['token']='';
}
 switch ($r=array_shift($request)) {
    case 'board':
		switch ($b=array_shift($request)) {
			case '': handle_board($method);break;
			case null: handle_board($method);break;
 	case 'piece': handle_piece($method, $request[0],$request[1],$input);
 				break;
	case 'player': handle_player($method, $request[0],$input);
					break;
					default: header("HTTP/1.1 404 Not Found");
                            break;
	}
		break;
	case 'status': 
		if(sizeof($request)==0) {handle_status($method);}
		else {header("HTTP/1.1 404 Not Found");}
		break;
 	case 'players': handle_player($method, $request,$input);
  			break;
	case 'delete_players': handle_delete_players($method);
	break;
	 case 'roll': handle_roll($method);  break;
			case 'rollY1':   handle_roll_Y1($method); break;
			case 'rollY2':handle_roll_Y2($method); break;
			case 'rollY3':handle_roll_Y3($method); break;
			case 'rollY4':handle_roll_Y4($method); break;
			case 'rollR1':handle_roll_R1($method); break;
			case 'rollR2':handle_roll_R2($method); break;
			case 'rollR3':handle_roll_R3($method); break;
			case 'rollR4':handle_roll_R4($method); break;
			case 'highlightY1':   handle_highlight_Y1($method); break;
			case 'highlightY2':handle_highlight_Y2($method); break;
			case 'highlightY3':handle_highlight_Y3($method); break;
			case 'highlightY4':handle_highlight_Y4($method); break;
			case 'highlightR1':handle_highlight_R1($method); break;
			case 'highlightR2':handle_highlight_R2($method); break;
			case 'highlightR3':handle_highlight_R3($method); break;
			case 'highlightR4':handle_highlight_R4($method); break;
			header("HTTP/1.1 404 Not Found");
    		print "<h1>not FOUND</h1>";
	exit;
}


function handle_delete_players($method) {
    if($method=='GET') {
		header('HTTP/1.1 405 Method Not Allowed');
    } else if ($method=='POST') {
		reset_players();
    }  else {header('HTTP/1.1 405 Method Not Allowed');}
    
}


    function handle_roll($method) {
        if($method=='GET') {
    		roll();
     
         }    else {header('HTTP/1.1 405 Method Not Allowed');}
        
     }
 function handle_roll_Y1($method) {
    if($method=='GET') {
		roll_dice(1);
 
     }    else {header('HTTP/1.1 405 Method Not Allowed');}
    
 }
 function handle_highlight_Y1($method) {
    if($method=='GET') {
 Y1_highlight();
     }    else {header('HTTP/1.1 405 Method Not Allowed');}
    
 }
 function handle_roll_Y2($method) {
    if($method=='GET') {
		roll_dice(2);
 
     }    else {header('HTTP/1.1 405 Method Not Allowed');}
    
 }

 function handle_highlight_Y2($method) {
    if($method=='GET') {
 Y2_highlight();
     }    else {header('HTTP/1.1 405 Method Not Allowed');}
    
 }


 function handle_roll_Y3($method) {
    if($method=='GET') {
		roll_dice(3);
	 
     }    else {header('HTTP/1.1 405 Method Not Allowed');}
    
 }
 function handle_highlight_Y3($method) {
    if($method=='GET') {
 Y3_highlight();
     }    else {header('HTTP/1.1 405 Method Not Allowed');}
    
 }


 function handle_roll_Y4($method) {
    if($method=='GET') {
		roll_dice(4);
		 
     }    else {header('HTTP/1.1 405 Method Not Allowed');}
    
 }
 function handle_highlight_Y4($method) {
    if($method=='GET') {
 Y4_highlight();
     }    else {header('HTTP/1.1 405 Method Not Allowed');}
    
 }


 function handle_roll_R1($method) {
    if($method=='GET') {
		roll_dice(111);
	 
     }    else {header('HTTP/1.1 405 Method Not Allowed');}
    
 }
 function handle_highlight_R1($method) {
    if($method=='GET') {
		R1_highlight();
     }    else {header('HTTP/1.1 405 Method Not Allowed');}
    
 }
 function handle_roll_R2($method) {
    if($method=='GET') {
		roll_dice(222);
	 
     }    else {header('HTTP/1.1 405 Method Not Allowed');}
    
 }
 function handle_highlight_R2($method) {
    if($method=='GET') {
		R2_highlight();
     }    else {header('HTTP/1.1 405 Method Not Allowed');}
    
 }
 function handle_roll_R3($method) {
    if($method=='GET') {
		roll_dice(333);
	 
     }    else {header('HTTP/1.1 405 Method Not Allowed');}
    
 }
 function handle_highlight_R3($method) {
    if($method=='GET') {
		R3_highlight();
     }    else {header('HTTP/1.1 405 Method Not Allowed');}
    
 }
 function handle_roll_R4($method) {
    if($method=='GET') {
		roll_dice(444);
	 
     }    else {header('HTTP/1.1 405 Method Not Allowed');}
    
 }
 function handle_highlight_R4($method) {
    if($method=='GET') {
		R4_highlight();
     }    else {header('HTTP/1.1 405 Method Not Allowed');}
    
 }
 

function handle_board($method) {
    if($method=='GET') {
            show_board();
    } else if ($method=='POST') {
		reset_board();
    } else {
        header('HTTP/1.1 405 Method Not Allowed');
    }
    
}

function handle_piece($method, $x,$y,$input) {
	if($method=='GET') {
		show_piece($x,$y);
	} else if ($method=='PUT') {
		move_piece($x,$y,$input['x'],$input['y'],  
				   $input['token']);
	}    


}
function handle_player($method, $p,$input) {
    switch ($b=array_shift($p)) {
		case '':
		case null: if($method=='GET') {displayAllUsers($method);}
	 			   else {header("HTTP/1.1 400 Bad Request"); 
 					 print json_encode(['errormesg'=>"Method $method not allowed here."]);}          
        case 'R':  handle_user($method, $b,$input);
		break;
			case 'B':  handle_user($method, $b,$input);
			break;
		case 'G':  handle_user($method, $b,$input);
		break;
			case 'Y': handle_user($method, $b,$input);
					break;
		default: header("HTTP/1.1 404 Not Found");
				 print json_encode(['errormesg'=>"Player $b not found."]);
                 break;
	}
}


function handle_status($method) {
    if($method=='GET') {
        show_status();
    } else {
        header('HTTP/1.1 405 Method Not Allowed');
    }
}
?>