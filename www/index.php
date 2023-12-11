
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <script src="https://code.jquery.com/jquery-3.6.4.min.js"></script>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="css/ludo.css" rel="stylesheet" type="text/css">
    <link href="css/styles.css" rel="stylesheet" type="text/css">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://code.jquery.com/jquery-3.6.4.min.js"></script>
    <script src="js/ludo.js" ></script>
    <script src="js/ludo.js", src="https://code.jquery.com/jquery-3.6.4.min.js"></script>
</head>
<body>
<div id="h1Name"><h1 id="name">LUDO</h1></div>
    <section id='main_body'>
        <div id='ludo_board'></div>
        <div id='ui_Chat'>
            <a id='game_info'>  
        </div>
    </section>
    <div id="gameButton">
        <button id='ludo_reset' class='btn btn-primary'>Restart</button><br>
        <div id='game_initializer'>
            <input id='username'> 
            <select id='pcolor'>
            <option value='R'>Κόκκινο</option>
            <option value='B'>Μπλέ</option>
            <option value='G'>Πράσινο</option>
            <option value='Y'>Κίτρινο</option>
            </select>    
        <button id='ludo_login' class='btn btn-primary'>ΕΙΣΟΔΟΣ ΣΤΟ ΠΑΙΧΝΙΔΙ</button><br>
        </div>   
        <div id='move_div'>
            Δώσε κίνηση (x1 y1 x2 y2): <input id='the_move'> 
        <button id='do_move' class='btn btn-primary'>ΚΑΝΕ ΤΗΝ ΚΙΝΗΣΗ</button> </div>
        <br><br>
    </div>
    <div id='move_div_roll'>
    Έτυχες: <span id='the_move_roll'> </span>
    <button id='do_move_roll' class='btn btn-primary'>ΡΙΞΕ ΖΑΡΙ</button>
</div>
<div id="diceResult"></div>
    <button id='players_reset' class='btn btn-primary'>ΤΟΟΟ ΚΟΥΜΠΙ NULL(100% ΔΟΥΛΕΥΕΙ)</button><br>
</div>
<?php include_once "footer.php"; ?>