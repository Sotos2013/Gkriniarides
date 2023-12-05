<?php
$host='localhost';
$db ='adise23_ludo_game';
require_once 'db_upass.php';

//username kai password tou xristi root
//tha mpei sto git ignore(db_upass)
$user=$DB_USER;
$pass=$DB_PASS;
    $mysqli = new mysqli($host,$user,$pass,$db);
    $conn=$mysqli;

if($mysqli->connect_errno){
    echo "Failed to connect to MySQL: (" . 
    $mysqli->connect_errno . ") " . $mysqli->connect_error;
}




?>