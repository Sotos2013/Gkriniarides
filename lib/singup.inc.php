<?php

if(isset($_POST["submit"])){ //Αν ο χρηστης πατησει το κουμπι submit

    $username = $_POST["username"];
    $email = $_POST["email"];
    $pwd = $_POST["pwd"];
    $pwdrepeat = $_POST["pwdrepeat"];

    require_once 'dbconnect.php';
    require_once 'functions.php';

    //Ελεγχος αν ειναι κενα τα πεδια
    if(emptyInputSingup($username,$email,$pwd,$pwdrepeat) !== false){
        header("location: ../www/singup.php?error=emptyinput");
        exit();
    }
    
    //Ελεγχος αν το username ειναι σωστο
    else
    if(invalidName($username) !== false){
        header("location: ../www/singup.php?error=invalidname");
        exit();
    }

    //Ελεγχος αν το email ειναι σωστο
    else
    if(invalidEmail($email) !== false){
        header("location: ../www/singup.php?error=invalidemail");
        exit();
    }

    //Ελεγχος αν οι κωδικοι ειναι ιδιοι
    else
    if(pwdMatch($pwd,$pwdrepeat) !== false){
        header("location: ../www/singup.php?error=passwordsdontmatch");
        exit();
    }

    //Ελεγχος αν υπαρχει ο χρηστης η το email στην βαση δεδομενων
    else
    if(nameExists($conn,$username,$email) !== false){
        header("location: ../www/singup.php?error=usernametaken");
        exit();
    }

    //Δημιουργια χρηστη
    createUser($conn,$username,$email,$pwd);

}

//Αν ο χρηστης προσπαθησει να μπει στην σελιδα μεσω url
else{
    header("location: ../www/singup.php");
    exit();
}

?>