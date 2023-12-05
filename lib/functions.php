<?php

function emptyInputSingup($username,$email,$pwd,$pwdrepeat){
    $result;
    if(empty($username) || empty($email) || empty($pwd) || empty($pwdrepeat)){
        $result = true;
    }
    else{
        $result = false;
    }
    return $result;
}

function invalidName($username){
    $result;
    if(!preg_match("/^[a-zA-Z0-9]*$/",$username)){
        $result = true;
    }
    else{
        $result = false;
    }
    return $result;
}

function invalidEmail($email){
    $result;
    if(!filter_var($email,FILTER_VALIDATE_EMAIL)){
        $result = true;
    }
    else{
        $result = false;
    }
    return $result;
}

function pwdMatch($pwd,$pwdrepeat){
    $result;
    if($pwd !== $pwdrepeat){
        $result = true;
    }
    else{
        $result = false;
    }
    return $result;
}

//Ελεγχος αν υπαρχει ο χρηστης η το email στην βαση δεδομενων
function nameExists($conn,$username,$email){
    $sql = "SELECT * FROM users WHERE usersName = ? OR usersEmail = ?;";
    $stmt = mysqli_stmt_init($conn);
    if(!mysqli_stmt_prepare($stmt,$sql)){
        header("location: ../www/singup.php?error=stmtfailed");
        exit();
    }

    mysqli_stmt_bind_param($stmt,"ss",$username,$email);
    mysqli_stmt_execute($stmt);

    $resultData = mysqli_stmt_get_result($stmt);

    if($row = mysqli_fetch_assoc($resultData)){
        return $row;
    }
    else{
        $result = false;
        return $result;
    }

    mysqli_stmt_close($stmt);
}

//Εισαγωγη δεδομενων στην βαση δεδομενων
function createUser($conn,$username,$email,$pwd){
    $sql = "INSERT INTO users (usersName,usersEmail,usersPwd) VALUES (?,?,?);";
    $stmt = mysqli_stmt_init($conn);
    if(!mysqli_stmt_prepare($stmt,$sql)){//ελεγχος αν ειναι σωστο το query
        header("location: ../www/singup.php?error=stmtfailed");
        exit();
    }

    $hashedPwd = password_hash($pwd,PASSWORD_DEFAULT);//Κρυπτογραφηση του κωδικου

    mysqli_stmt_bind_param($stmt,"sss",$username,$email,$hashedPwd);
    mysqli_stmt_execute($stmt);
    mysqli_stmt_close($stmt);
    header("location: ../www/singup.php?error=none");
    exit();
}

//Ελεγχος αν ειναι κενα τα πεδια στο login
function emptyInputLogin($username,$pwd){
    $result;
    if(empty($username) || empty($pwd)){
        $result = true;
    }
    else{
        $result = false;
    }
    return $result;
}

//Ελεγχος αν υπαρχει ο χρηστης στην βαση δεδομενων
function loginUser($conn,$username,$pwd){
    $nameExists = nameExists($conn,$username,$username);

    //Ελεγχος αν υπαρχει ο χρηστης
    if($nameExists === false){
        header("location: ../www/login.php?error=wronglogin");
        exit();
    }
    
    //Ελεγχος αν ο κωδικος ειναι σωστος
    $pwdHashed = $nameExists["usersPwd"];
    $checkPwd = password_verify($pwd,$pwdHashed);

    if($checkPwd === false){
        header("location: ../www/login.php?error=wronglogin");
        exit();
    }
    else if($checkPwd === true){
        session_start();
        $_SESSION["userid"] = $nameExists["usersId"];
        $_SESSION["username"] = $nameExists["usersName"];
        header("location: ../www/index.php");
        exit();
    }
}