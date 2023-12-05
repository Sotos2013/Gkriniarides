<?php
    session_start();
?>

<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    
    <!-- Other meta tags and stylesheets -->

    <!-- Include jQuery from CDN -->
    <script src="https://code.jquery.com/jquery-3.6.4.min.js"></script>

    <!-- Include Popper.js from CDN -->
 
    <!-- Bootstrap core CSS and JavaScript -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="css/myludo.css" rel="stylesheet" type="text/css">
    <link href="css/styles.css" rel="stylesheet" type="text/css">

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://code.jquery.com/jquery-3.6.4.min.js"></script>
    <!-- Your custom JavaScript -->
    <script src="js/myludo.js" ></script>
    <script src="js/myludo.js", src="https://code.jquery.com/jquery-3.6.4.min.js"></script>
</head>

<body>

    <nav> 
    <!--navybox-->
        <div class="navybox">
         <ul>
             <ul id="playerName"><a>UserName:</a> &nbsp;
              <?php
                if(isset($_SESSION["username"])){
                    echo "<li id='UserName'><a>".$_SESSION["username"]."</a></li>";
                }
                else{
                    echo "<li id='UserName'><a>Guest</a></li>";
                }
                ?>
              </a></li>
             </ul>
            <li><a href="#">Αρχικη</a></li>
            <li><a href="">Προφιλ</a></li>
            <li><a href="./">Παιχνιδι</a></li>
            <?php
                if(isset($_SESSION["username"])){
                    echo "<li><a href='../lib/logout.inc.php'>Log out</a></li>";
                }
                else{
                    echo "<li><a href='./singup.php'>Sing Up</a></li>";
                    echo "<li><a href='./login.php'>Log in</a></li>";
                }
            ?>
             <ul id="playerData"><a>Score:</a>&nbsp;
              <li id="Score"><a>0098</a></li>
             </ul>
         </ul>
        </div>
    </nav>
         <!--finish navybox-->
