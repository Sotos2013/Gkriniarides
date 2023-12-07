
<?php include_once "header.php"; ?>
<div id="h1Name"><h1 id="name">γκρινιαρης</h1></div>
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