<?php

if(isset($_POST["submit"])){

    $username = $_POST["username"];
    $pwd = $_POST["pwd"];

    require_once 'dbconnect.php';
    require_once 'functions.php';

    if(emptyInputLogin($username, $pwd) !== false){
        header("location: ../www/login.php?error=emptyinput");
        exit();
    }

    loginUser($conn, $username, $pwd);

}
else{
    header("location: ../www/login.php");
    exit();
}

?>