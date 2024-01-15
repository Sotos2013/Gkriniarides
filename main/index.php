<!DOCTYPE html>
<html lang="el">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="css/ludo.css" rel="stylesheet" type="text/css">
    <link href="css/style.css" rel="stylesheet" type="text/css">
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script src="javascript/ludo.js" ></script>
</head>
<body>
<div id="Ludo"><h1 id="name">LUDO</h1></div>

    <div id='RedWin'></div>
    <div id='BlackWin'></div>
    <div id='YellowWin'></div>
    <div id='GreenWin'></div>
    <div id="pictures"></div>
    <div id="gameButton">
        <button id='reset' class='btn btn-primary'>Επανεκκίνηση</button><br>
        <div id='start_play'>
            <input id='username' > 
                <select id='pcolor'>
                    <option value='R'>Κόκκινο</option>
                    <option value='B'>Μαύρο</option>
                    <option value='G'>Πράσινο</option>
                    <option value='Y'>Κίτρινο</option>
                </select>    
        <button id='player_insert' class='btn btn-primary'>Ξεκίνημα παιχνιδιού</button><br>
        </div>   
        <div id='moveDiv'>Kinisi<input id='Movement'> 
            <button id='execMove' class='btn btn-primary'>Παίξε</button> </div><br><br></div>
    <div id='moveDivRoll'>
        <span id='moveDiv'> </span>
    </div>
    <div id="ludo_board"></div>
    <button id='roll_the_dice' class='btn btn-primary'>Ρίξε Ζαριά</button>
    <input type="text" id="diceResultTextbox" readonly>
    <button id='reset_db' class='btn btn-primary'>Reset Database</button><br>
    <div id='chat'>
        <a id='gameInfo'>
    </div>
</div>
</body>
 </html> 
