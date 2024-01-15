var me={token:null,piece_color:null};
var gameStatus={};
var board={};
var last_update=new Date().getTime();
var timer=null;
const diceButtonElement = document.querySelector('#roll_the_dice');
$(function(){
    draw_empty_board();
    fillBoard();
    $(document).ready(function() {
        $('#player_insert').click(login_play);
    });
    
    $('#reset').click(reset_board);
    $('#reset_db').click(resetDB);
    $('#execMove').click(executeMove);

});
 
function disableDice() {
    diceButtonElement.setAttribute('disabled');
}
disableDice();
function resetDB() {
    $.ajax({
        url: 'ludo_game.php/delete_players/',
        method: 'POST',
        dataType: "json",
        contentType: 'application/json',
        data: { action: 'reset_db' },
        success: function(response) {
            alert('Η βάση ανανεώθηκε');
        },
        error: function(jqXHR, textStatus, errorThrown) {
            console.log('Ajax request failed:');
            console.log('Status: ' + textStatus);
            console.log('Error: ' + errorThrown);
            console.log('Response Text: ' + jqXHR.responseText);
            alert('Πρόβλημα με τη σύνδεση');
        }
        
    });

} 
function draw_empty_board(p) {
    if(p!='Black'||p!='Red'||p!='Green') {p='Yellow';}
	var draw_init = {
		'Yellow': {i1:11,i2:0,istep:-1,j1:1,j2:12,jstep:1},
		'Red': {i1:1,i2:12,istep:1, j1:11,j2:0,jstep:-1}
	};
	var s=draw_init[p];
    var t = '<table id="ltable">';
    for(var i=s.i1;i!=s.i2;i+=s.istep) {
		t += '<tr>';
		for(var j=s.j1;j!=s.j2;j+=s.jstep) {
                    t += '<td class="lsquare" id="square_' + j + '_' + i + '">' + j + ',' + i + '</td>';
        }
        t += '</tr>';
    }
    t += '</table>';
    $('#ludo_board').html(t);
 
}

 
function fillBoard() {
	$.ajax({
		url: "ludo_game.php/board/",
		headers: {"X-Token": me.token},
		success: fillBoardData
	});
}

function reset_board() {
	$.ajax({
		url: "ludo_game.php/board/",
		headers: {"X-Token": me.token},
		method: 'POST',
		success: fillBoardData,
		error: function (xhr, status, error) {
			console.error("AJAX Error:", status, error);
		}
	});
	$('#gameButton').show(2000);
}


function fillBoardData(data) {
    board = data;
    for(var i=0;i<data.length;i++) {
		var o = data[i];
		var id = '#square_'+ o.x +'_' + o.y;
		var c = (o.piece!=null)?o.piece_color + o.piece:'';
		var pc= (o.piece!=null)?'piece'+o.piece_color:'';
		var im = (o.piece!=null)?'<img class="piece '+pc+'" src="pawns/'+c+'.png">':'';
		$(id).addClass(o.b_color+'_square').html(im);
    }
}
    function handleLoginResult(data) {
        if (!data || !data[0]) {
            // Καμία ή κακομορφη απάντηση, επιστροφή
            return;
        }
        currentPlayer = data[0];
        updatePlayerInfo();
        updateGameStatus();
    }
    
    function handleLoginError() {
        alert("errorMessage");
    }
    
    function updateGameStatus() {
        if (!me || !me.token) {
            // Ο παίκτης δεν έχει συνδεθεί, επιστροφή
            return;
        }
    
        $.ajax({
            url: "ludo_game.php/status/",
            success: updateStatus,
            headers: { "X-Token": me.token }
        });
    }
    
    
    function updatePlayerInfo() {
        //returnLosers();
    
        if (gameStatus.status !== 'ended') {
            $('#gameInfo').html("I am Player: " + me.piece_color + ", my name is " + me.username +
                '<br>Token=' + me.token + '<br>Game state: ' + gameStatus.status + ', ' + gameStatus.p_turn + ' must play now.');
        } else {
            $('#gameInfo').html("I am Player: " + me.piece_color + ", my name is " + me.username +
                '<br>Token=' + me.token + '<br>Game state: ' + gameStatus.status + ', ');
    
            if (gameStatus.result === 'Y') {
                $('#gameInfo').html("I am Player: " + me.piece_color + ", my name is " + me.username +
                    '<br>Token=' + me.token + '<br>Game state: ' + gameStatus.status + ', ' + gameStatus.result + 'YELLOW PLAYER WINS.');
            }
            if (gameStatus.result === 'R') {
                $('#gameInfo').html("I am Player: " + me.piece_color + ", my name is " + me.username +
                    '<br>Token=' + me.token + '<br>Game state: ' + gameStatus.status + ', ' + gameStatus.result + 'RED PLAYER WINS.');
            }
            if (gameStatus.result === 'G') {
                $('#gameInfo').html("I am Player: " + me.piece_color + ", my name is " + me.username +
                    '<br>Token=' + me.token + '<br>Game state: ' + gameStatus.status + ', ' + gameStatus.result + 'GREEN PLAYER WINS.');
            }
            if (gameStatus.result === 'B') {
                $('#gameInfo').html("I am Player: " + me.piece_color + ", my name is " + me.username +
                    '<br>Token=' + me.token + '<br>Game state: ' + gameStatus.status + ', ' + gameStatus.result + 'BLACK PLAYER WINS.');
            }
        }
    }
    function executeMove() {
        console.log("aaaaaaaa");
        var moveString = $('#Movement').val();
    
        var moveArray = moveString.trim().split(/[ ]+/);
        if (moveArray.length !== 4) {
            return;
        }
    
        var resultForYellow = checkYellowImagesBeforeMove();
        var resultForRed = checkRedImagesBeforeMove();
        var hasYellowImage = resultForYellow.hasYYImage;
        var hasRedImage = resultForRed.hasRRImage;
        var resultForBlack = checkBlackImagesBeforeMove();
        var resultForGreen = checkGreenImagesBeforeMove();
        var hasBlackImage = resultForBlack.hasYYImage;
        var hasGreenImage = resultForGreen.hasRRImage;
        if (hasYellowImage === false || hasRedImage === false || hasBlackImage === false || hasGreenImage === false){
            console.log("hasYellowImage:", hasYellowImage);
            console.log("hasRedImage:", hasRedImage);
            console.log("hasBlackImage:", hasBlackImage);
            console.log("hasGreenImage:", hasGreenImage);
            console.log("gameStatus.p_turn:", gameStatus.p_turn);

            $.ajax({
                url: "ludo_game.php/board/piece/" + moveArray[0] + '/' + moveArray[1],
                method: 'PUT',
                dataType: "json",
                contentType: 'application/json',
                data: JSON.stringify({ x: moveArray[2], y: moveArray[3] }),
                headers: { "X-Token": me.token },
                success: function(data) {
                    console.log("Server Response:", data); // Εκτύπωση της απάντησης
                    moveResult(data);
                },
                error: function(xhr, status, error) {
                    console.log(xhr.responseText);
                    console.log("Status: " + status);
                    console.error("Error: " + error);
                }
            });
            
        } else {
            console.log("hasYellowImage:", hasYellowImage);
            console.log("hasRedImage:", hasRedImage);
            console.log("hasBlackImage:", hasBlackImage);
            console.log("hasGreenImage:", hasGreenImage);
            console.log("gameStatus.p_turn:", gameStatus.p_turn);
            alert('λαθος κινηση!');
        }
            //kokkino-kitrino
            if (hasYellowImage === true && gameStatus.p_turn === 'R') {
                alert('Ο ΚΟΚΚΙΝΟΣ ΠΑΙΚΤΗΣ ΕΦΑΓΕ ΚΙΤΡΙΝΟ ΠΙΟΝΙ! ΕΠΙΣΤΡΟΦΗ ΣΤΗΝ ΑΡΧΙΚΗ ΘΕΣΗ');
                returnLosers();
                fillBoard();
            }
            //kitrino-kokkino
            if (hasRedImage === true && gameStatus.p_turn === 'Y') {
                alert('Ο ΚΙΤΡΙΝΟΣ ΠΑΙΚΤΗΣ ΕΦΑΓΕ ΚΟΚΚΙΝΟ ΠΙΟΝΙ! ΕΠΙΣΤΡΟΦΗ ΣΤΗΝ ΑΡΧΙΚΗ ΘΕΣΗ');
                returnLosers();
                fillBoard();
            }

            //mavro-kitrino
            if (hasBlackImage === true && gameStatus.p_turn === 'Y') {
                alert('Ο ΚΙΤΡΙΝΟΣ ΠΑΙΚΤΗΣ ΕΦΑΓΕ ΜΑΥΡΟ ΠΙΟΝΙ! ΕΠΙΣΤΡΟΦΗ ΣΤΗΝ ΑΡΧΙΚΗ ΘΕΣΗ');
                returnLosers();
                fillBoard();
            }
            //kitrino-mavro
            if (hasYellowImage === true && gameStatus.p_turn === 'B') {
                alert('Ο ΜΑΥΡΟΣ ΠΑΙΚΤΗΣ ΕΦΑΓΕ ΚΙΤΡΙΝΟ ΠΙΟΝΙ! ΕΠΙΣΤΡΟΦΗ ΣΤΗΝ ΑΡΧΙΚΗ ΘΕΣΗ');
                returnLosers();
                fillBoard();
            }      
            
            //prasino-kitrino
            if (hasGreenImage === true && gameStatus.p_turn === 'Y') {
                alert('Ο ΚΙΤΡΙΝΟΣ ΠΑΙΚΤΗΣ ΕΦΑΓΕ ΠΡΑΣΙΝΟ ΠΙΟΝΙ! ΕΠΙΣΤΡΟΦΗ ΣΤΗΝ ΑΡΧΙΚΗ ΘΕΣΗ');
                returnLosers();
                fillBoard();
            }
            //kitrino-prasino
            if (hasYellowImage === true && gameStatus.p_turn === 'G') {
                alert('Ο ΠΡΑΣΙΝΟΣ ΠΑΙΚΤΗΣ ΕΦΑΓΕ ΚΙΤΡΙΝΟ ΠΙΟΝΙ! ΕΠΙΣΤΡΟΦΗ ΣΤΗΝ ΑΡΧΙΚΗ ΘΕΣΗ');
                returnLosers();
                fillBoard();
            }            
            //κοκκινο-μαυρο  
            if (hasBlackImage === true && gameStatus.p_turn === 'R') {
                alert('Ο ΚΟΚΚΙΝΟΣ ΠΑΙΚΤΗΣ ΕΦΑΓΕ ΜΑΥΡΟ ΠΙΟΝΙ! ΕΠΙΣΤΡΟΦΗ ΣΤΗΝ ΑΡΧΙΚΗ ΘΕΣΗ');
                returnLosers();
                fillBoard();
            }
             //μαυρο-κοκκινο  
             if (hasRedImage === true && gameStatus.p_turn === 'B') {
                alert('Ο ΜΑΥΡΟΣ ΠΑΙΚΤΗΣ ΕΦΑΓΕ ΚΟΚΚΙΝΟ ΠΙΟΝΙ! ΕΠΙΣΤΡΟΦΗ ΣΤΗΝ ΑΡΧΙΚΗ ΘΕΣΗ');
                returnLosers();
                fillBoard();
            }           
            //prasino-mavro
            if (hasBlackImage === true && gameStatus.p_turn === 'G') {
                alert('Ο ΠΡΑΣΙΝΟΣ ΠΑΙΚΤΗΣ ΕΦΑΓΕ ΜΑΥΡΟ ΠΙΟΝΙ! ΕΠΙΣΤΡΟΦΗ ΣΤΗΝ ΑΡΧΙΚΗ ΘΕΣΗ');
                returnLosers();
                fillBoard();
            }
            //mavro-prasino
            if (hasGreenImage === true && gameStatus.p_turn === 'B') {
                alert('Ο ΜΑΥΡΟΣ ΠΑΙΚΤΗΣ ΕΦΑΓΕ ΠΡΑΣΙΝΟ ΠΙΟΝΙ! ΕΠΙΣΤΡΟΦΗ ΣΤΗΝ ΑΡΧΙΚΗ ΘΕΣΗ');
                returnLosers();
                fillBoard();
            }
            //kokkino-prasino
            if (hasGreenImage === true && gameStatus.p_turn === 'R') {
                alert('Ο KOKKINOΣ ΠΑΙΚΤΗΣ ΕΦΑΓΕ ΠΡΑΣΙΝΟ ΠΙΟΝΙ! ΕΠΙΣΤΡΟΦΗ ΣΤΗΝ ΑΡΧΙΚΗ ΘΕΣΗ');
                returnLosers();
                fillBoard();
            }        
            //prasino-kokkino
            if (hasRedImage === true && gameStatus.p_turn === 'G') {
                alert('Ο ΠΡΑΣΙΝΟΣ ΠΑΙΚΤΗΣ ΕΦΑΓΕ ΚΟΚΚΙΝΟ ΠΙΟΝΙ! ΕΠΙΣΤΡΟΦΗ ΣΤΗΝ ΑΡΧΙΚΗ ΘΕΣΗ');
                returnLosers();
                fillBoard();
            }    


    }
    
    
function returnLosers() {
    $.ajax({
        url: "ludo_game.php/return_losers",
        method: 'GET',
        dataType: "json",
        contentType: 'application/json',
        data: { action: 'returnLostUsers' },
        headers: { "X-Token": me.token },
        success: function (response) {
            fillBoardData();
            fillBoard();
        },
        error: function (xhr, status, error) {
            console.error(xhr.responseText);
        }
    });
}


    
    function RedWin() {
        $.ajax({
            url: "ludo_game.php/redWin",
            method: 'GET',
            dataType: "json",
            contentType: 'application/json',
            data: { action: 'redWin' },
            headers: { "X-Token": me.token },
            success: function (response) {
                var container = $('#RedWin');
                container.empty();
                if (response.pieceValues && Array.isArray(response.pieceValues)) {
                    console.log("okk");
                } else {
                    console.error("Pieces not found");
                }
            },
            error: function (xhr, status, error) {
                console.error("Error Response:", xhr.responseText);
            }
        });
    }
    
    function YellowWin() {
        $.ajax({
            url: "ludo_game.php/yellowWin",
            method: 'GET',
            dataType: "json",
            contentType: 'application/json',
            data: { action: 'yellowWin' },
            headers: { "X-Token": me.token },
            success: function (response) {
                var container = $('#YellowWin');
                container.empty();
                if (response.pieceValues && Array.isArray(response.pieceValues)) {
                    console.log("okk");
                } else {
                    console.error("Pieces not found");
                }
            },
            error: function (xhr, status, error) {
                console.error("Error Response:", xhr.responseText);
            }
        });
    }
    function BlackWin() {
        $.ajax({
            url: "ludo_game.php/blackWin",
            method: 'GET',
            dataType: "json",
            contentType: 'application/json',
            data: { action: 'blackWin' },
            headers: { "X-Token": me.token },
            success: function (response) {
                var container = $('#BlackWin');
                container.empty();
                if (response.pieceValues && Array.isArray(response.pieceValues)) {
                    console.log("okk");
                } else {
                    console.error("Pieces not found");
                }
            },
            error: function (xhr, status, error) {
                console.error("Error Response:", xhr.responseText);
            }
        });
    }
    function GreenWin() {
        $.ajax({
            url: "ludo_game.php/greenWin",
            method: 'GET',
            dataType: "json",
            contentType: 'application/json',
            data: { action: 'greenWin' },
            headers: { "X-Token": me.token },
            success: function (response) {
                if (response.pieceValues && Array.isArray(response.pieceValues)) {
                    console.log("okk");
                } else {
                    console.error("Pieces not found");
                }
            },
            error: function (xhr, status, error) {
                console.error("Error Response:", xhr.responseText);
            }
        });
    }
    function rollDiceForPlayer(playerNum, pieceNum) {
        $.ajax({ 
            url: "ludo_game.php/roll" + playerNum + pieceNum,
            method: 'GET',
            dataType: "json",
            contentType: 'application/json',
            data: { action: 'rollDice', piece_num: pieceNum },
            headers: { "X-Token": me.token },
            success: function (data) {
                console.log("Success Response:", data);
                if (Array.isArray(data) && 'dice' in data[data.length - 1]) {
                    $("#diceResult").text(data[data.length - 1].dice);
                    if ('dice' in data && data[data.length - 1].dice === 6) {
                        makeImagesClickable(playerNum);
                        makeImagesUnclickable(getOpponentPlayerNum(playerNum));
                    } else {
                        makeImagesClickable(playerNum);
                        makeImagesUnclickable(getOpponentPlayerNum(playerNum));
                    }
    
                    $("#Movement").val(
                        " " + data[data.length - 1].oldX +
                        " " + data[data.length - 1].oldY +
                        " " + data[data.length - 1].newX +
                        " " + data[data.length - 1].newY
                    );
    
                } else {
                    console.log("Invalid dice result:", data);
                    console.log(data);
                }
            },
            error: function (xhr, status, error) {
                console.error("Error Response:", xhr.responseText);
            }
        });
    
        $.ajax({
            url: "ludo_game.php/highlight" + playerNum + pieceNum,
            method: 'GET',
            dataType: "json",
            contentType: 'application/json',
            data: { action: playerNum + pieceNum + "Highlight" },
            headers: { "X-Token": me.token },
            success: function (data) {
                console.log("highlight coordinates : ", data);
                data.forEach(function (item) {
                    var squareId = 'square_' + item.x + '_' + item.y;
                    $('#' + squareId).addClass('highlight');
    
                    setTimeout(function () {
                        $('#' + squareId).removeClass('highlight');
                    }, 1000);
                });
            },
            error: function (xhr, status, error) {
                console.error("Error Response:", xhr.responseText);
            }
        });
    }
    
    function getOpponentPlayerNum(playerNum) {
        return playerNum === 'Y' ? 'R' : 'Y';
    }
    function makeImagesClickable(playerType) {
        $('.piece').filter('[src^="pawns/' + playerType + '"]').parent('td').addClass('clickable' + playerType).click(function (e) {
            onImageClick(playerType, e);
        });
    }
    
    function makeImagesUnclickable(playerType) {
        $('.piece').parent('td').removeClass('clickable' + playerType).off('click', function (e) {
            onImageClick(playerType, e);
        });
    }
    
    var isOnImageClickCalled = false;
    function onImageClick(playerType, e) {
        isOnImageClickCalled = true;
        var clickedTd = e.currentTarget;
        var imageName = $(clickedTd).find('img').attr('src');
        console.log('Image Name:', imageName);
    
        // Check if the image name starts with the specified player type (e.g., "YY" for Y player)
        if (imageName && imageName.startsWith('pawns/' + playerType)) {
            var imageFileName = imageName.replace('pawns/' +playerType, '').split('/').pop(); // Πάρε το όνομα του αρχείου μετά το τελευταίο '/'
            var imageNumber = imageFileName.replace('.png', '').trim();
    
            // Log only the imageNumber
            console.log('Clicked on:', imageNumber);
    
            // Use a switch statement to distinguish different actions based on the image number
            switch (imageNumber) {
                case 'R1':
                case 'R2':
                case 'R3':
                case 'R4':
                case 'Y1':
                case 'Y2':
                case 'Y3':
                case 'Y4':
                case 'B1':
                case 'B2':
                case 'B3':
                case 'B4':
                case 'G1':
                case 'G2':
                case 'G3':
                case 'G4':
                    var rollNumber = parseInt(imageNumber.charAt(1)); // Extract the numeric part
                    rollDiceForPlayer(playerType, rollNumber);
                    break;
                default:
                    // Add default logic
            }
            
        } else {
            console.log('Clicked on non-' + playerType + ' image:', imageName);
            // Add logic for other images if needed
        }
    }

    function enableDice() {
        $('#roll_the_dice').click(rollDice);
        diceButtonElement.removeAttribute('disabled');
    }
    
    function login_play() {
        console.log("login_play() is called");
        if($('#username').val()=='') {
            alert('Δεν βρέθηκε Username');
            return;
        }
        var p_color = $('#pcolor').val();
        draw_empty_board(p_color);
        fillBoard();
        gameStatus.p_turn=p_color;
        $.ajax({url: "ludo_game.php/players/"+p_color, 
                method: 'PUT',
                dataType: "json",
                headers: {"X-Token": me.token},
                contentType: 'application/json',
                data: JSON.stringify( {username: $('#username').val(), piece_color: p_color}),
                success: gameResult,
                error: loginError});
    } 
    function gameUpdate() {
        $.ajax({
            url: "ludo_game.php/status/",
            method: "GET",
            success: updateStatus,
            headers: {"X-Token": me.token}
        });
    }
    

    function updateStatus(data) {
        updatePlayerInfo();
        if (!data || !data[0]) {
            // Καμία ή κακομορφη απάντηση, επιστροφή
            return;
        }
        last_update=new Date().getTime();
        var game_stat_old = gameStatus;
        gameStatus=data[0];
         if(gameStatus.p_turn==me.piece_color &&  me.piece_color!=null) {
           x=0;
         if(game_stat_old.p_turn!=gameStatus.p_turn) {
            returnLosers();    
            fillBoard();
          }
          //returnLosers();    
          //fillBoard();
          $('#start_play').prop('disabled', false);
          $('#moveDivRoll').show(1000);
           $('#move_div').show(1000);
        } else {
         var theMoveInput = document.getElementById("Movement");
          returnLosers();
          fillBoard();
          theMoveInput.value = "";
        }
    }
    function gameResult(data) {
        //console.log(data); // Εκτυπώνει τα δεδομένα στον προγραμματιστικό πίνακα
        me = data[0];
        $('#start_play').show();
        enableDice();
        gameUpdate();
    }
    function loginError(data, y, z, c) {
        //console.log(data); // Εκτυπώνει τα δεδομένα στον προγραμματιστικό πίνακα
        var x = data.responseJSON;
        if (x && x.errormesg) {
            alert(x.errormesg);
        } else {
            alert('Σφάλμα κατά την επικοινωνία με τον διακομιστή.');
        }
    }
    
    
    function clickImages(data){
        console.log('Success Response:', data);
                var diceResultTextbox = document.getElementById('diceResultTextbox');
                $('#diceResult').text(data[0].generated_dice_result);
                diceResultTextbox.value = data[0].generated_dice_result;
                if (gameStatus.p_turn === 'Y') {
                    makeImagesClickable("Y");}
                else if(gameStatus.p_turn === 'B'){
                    makeImagesClickable("B");}
                else if(gameStatus.p_turn === 'G'){
                    makeImagesClickable("G");}
                else {
                    makeImagesClickable("R");
                }
    }
    function rollDice() {
        $.ajax({
            url: 'ludo_game.php/roll/',
            method: 'GET',
            dataType: 'json',
            headers: { 'X-Token': me.token },
            contentType: 'application/json',
            data: { action: 'rollDice' },
            success: clickImages,
            error: function () {
                alert('Error occurred while rolling dice.');
            }
        });
    }
    
    function checkYellowImagesBeforeMove() {
        var moveInputValue = $('#Movement').val();
        var moveValues = moveInputValue.split(/\s+/);
        var x = moveValues[2];
        var y = moveValues[3];
        var squareId = 'square_' + x + '_' + y;
        var tdElement = $('#' + squareId);
        var imageName = $(tdElement).find('img').attr('src');
        if (imageName && imageName.startsWith('pawns/YY')) {
            console.log('Image with src starting with "YY" exists! YOU CANT MOVE');
            return { hasYYImage: true, imageName: imageName };
        } else {
            console.log('No image with src starting with "YY" found.');
            return { hasYYImage: false, imageName: null };
        }
    }
    
    function checkRedImagesBeforeMove() {
        var moveInputValue = $('#Movement').val().trim();
        var moveValues = moveInputValue.split(/\s+/);
        var x = moveValues[2];
        var y = moveValues[3];
        var squareId = 'square_' + x + '_' + y;
        var tdElement = $('#' + squareId);
        var imageName = $(tdElement).find('img').attr('src');
        if (imageName && imageName.startsWith('pawns/RR')) {
            console.log('Image with src starting with "RR" exists! YOU CANT MOVE');
            return { hasRRImage: true, imageName: imageName };
        } else {
            console.log('No image with src starting with "RR" found.');
            return { hasRRImage: false, imageName: null };
        }
    }
    function checkBlackImagesBeforeMove() {
        var moveInputValue = $('#Movement').val().trim();
        var moveValues = moveInputValue.split(/\s+/);
        var x = moveValues[2];
        var y = moveValues[3];
        var squareId = 'square_' + x + '_' + y;
        var tdElement = $('#' + squareId);
        var imageName = $(tdElement).find('img').attr('src');
        if (imageName && imageName.startsWith('pawns/BB')) {
            console.log('Image with src starting with "BB" exists! YOU CANT MOVE');
            return { hasBBImage: true, imageName: imageName };
        } else {
            console.log('No image with src starting with "BB" found.');
            return { hasBBImage: false, imageName: null };
        }
    }
    function checkGreenImagesBeforeMove() {
        var moveInputValue = $('#Movement').val().trim();
        var moveValues = moveInputValue.split(/\s+/);
        var x = moveValues[2];
        var y = moveValues[3];
        var squareId = 'square_' + x + '_' + y;
        var tdElement = $('#' + squareId);
        var imageName = $(tdElement).find('img').attr('src');
        if (imageName && imageName.startsWith('pawns/GG')) {
            console.log('Image with src starting with "GG" exists! YOU CANT MOVE');
            return { hasGGImage: true, imageName: imageName };
        } else {
            console.log('No image with src starting with "GG" found.');
            return { hasGGImage: false, imageName: null };
        }
    }
    function resetPlayers() {
        $.ajax({
            url: 'ludo_game.php/delete_players/',
            method: 'POST',
            dataType: 'json',
            contentType: 'application/json',
            data: { action: 'reset_players' },
            success: function (response) {
                alert('Database updated successfully!');
            },
            error: function () {
                alert('Error updating the database.');
            }
        });
    }
    
    
    function isYellowImageClicked() {
        return isYellowImageClicked;
    }
    
    function resetYellowImageClickStatus() {
        isYellowImageClicked = false;
    }
    
    function isRedImageClicked() {
        return isRedImageClicked;
    }
    
    function resetRedImageClickStatus() {
        isRedImageClicked = false;
    }
    
    function moveResult(data) {
        RedWin();
        YellowWin();
        GreenWin();
        BlackWin();
        fillBoardData(data);
        gameUpdate();
    }
    
        

 
         
        
