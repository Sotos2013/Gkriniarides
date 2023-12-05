
<?php

    include_once "header.php";

?>


        <div id="h1Name"><h1 id="name">Sing Up</h1></div>

    <section id='main_body'>
        <div id='form'>
        <form action="../lib/singup.inc.php" method="post">
                
            <?php
                if(isset($_GET["error"])){
                    if($_GET["error"] == "emptyinput"){
                        echo "<p>Fill in all fields!</p>";
                    }
                    else if($_GET["error"] == "invalidname"){
                        echo "<p>Choose a proper username!</p>";
                    }
                    else if($_GET["error"] == "invalidemail"){
                        echo "<p>Choose a proper email!</p>";
                    }
                    else if($_GET["error"] == "passwordsdontmatch"){
                        echo "<p>Password doesn't match!</p>";
                    }
                    else if($_GET["error"] == "stmtfailed"){
                        echo "<p>Something went wrong, try again!</p>";
                    }
                    else if($_GET["error"] == "usernametaken"){
                        echo "<p>Username already taken!</p>";
                    }
                    else if($_GET["error"] == "none"){
                        echo "<p>You have signed up!</p>";
                    }
                }
            ?>
            <input type="text" name="username" placeholder="Username"><br>
            <input type="text" name="email" placeholder="Email"><br>
            <input type="password" name="pwd" placeholder="Passworld"><br>
            <input type="password" name="pwdrepeat" placeholder="Repeat Passworld"><br>
            <button id='submit' type="submit" name="submit">Sing Up</button>
            
        </form>
        </div>
    </section>

  


    <div id=''></div>

    <div id="gameButton">
       
    </div>

<?php

    include_once "footer.php";

?>