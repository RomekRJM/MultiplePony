frame = 0
MODE_WEB_BROWSER = 1
MODE_PICO_CLIENT = 0
gameMode = MODE_WEB_BROWSER

function _init()
    frame = 0
    restartNet()
    restartLobby()
    restartProgress()
    restartCircles()
    restartArrows()
    restartPlayer()
    restartCountdown()
    restartEnd()
    clearServerGPIOPins()
    establishConnection()

    if gameMode == MODE_PICO_CLIENT then
        myselfId = 1
        myself.id = myselfId
        myself.team = 1
        myself.name = 'myself'
        myself.isAdmin = true
        myself.score = 591

        setPlayers(0, 5, {
            myself,
            player:new { id = 2, name = 'printf', team = 1, isAdmin = false, ready = true, score = 1 },
            player:new { id = 3, name = 'shin', team = 1, isAdmin = false, ready = false, score = 592 },
            player:new { id = 4, name = 'da', team = 1, isAdmin = false, ready = false, score = 592 },
            player:new { id = 5, name = 'elazer', team = 1, isAdmin = false, ready = true, score = 593 },
            player:new { id = 6, name = 'reynor', team = 2, isAdmin = false, ready = true, score = 594 },
            player:new { id = 7, name = 'gumiho', team = 2, isAdmin = false, ready = false, score = 595 },
            player:new { id = 8, name = 'has', team = 2, isAdmin = false, ready = true, score = 1596 },
            player:new { id = 9, name = 'zest', team = 2, isAdmin = false, ready = false, score = 2597 },
        })

        preCirclesShow()
    end
end

function _draw()
    cls()

    if gameState == COUNTING_DOWN_TO_GAME_START_STATE then
        drawCountdown()
    elseif gameState == RECEIVED_CONNECTED_TO_SERVER_RESP_STATE then
        drawLobby()
    elseif gameState == GAME_IN_PROGRESS_STATE then
        drawProgress()
        drawCircles()
        drawArrows()
        drawTeamScores()
    elseif gameState == GAME_END_SCREEN_STATE then
        drawEndScreen()
    end
end

function _update60()
    if gameState == GAME_IN_PROGRESS_STATE then
        updateProgress()
        updateArrows()
        updateCircles()
        updatePlayer()
    elseif gameState == RECEIVED_CONNECTED_TO_SERVER_RESP_STATE then
        updateLobby()
    elseif gameState == COUNTING_DOWN_TO_GAME_START_STATE then
        updateCountdown()
        preCirclesShow()
        frame = -1
    elseif gameState == GAME_END_SCREEN_STATE then
        updateEnd()
    end

    handleUpdateFromServer()
    sendRoundStartCommand()

    if gameMode == MODE_PICO_CLIENT then
        if gameState == 1 then
            poke(BROWSER_GPIO_START_ADDR, START_ROUND_CMD_SERVER_RESP)
            gameState = GAME_IN_PROGRESS_STATE
        end
    end

    frame = frame + 1
end
