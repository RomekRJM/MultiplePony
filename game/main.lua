frame = 0
MODE_WEB_BROWSER = 1
MODE_PICO_CLIENT = 0
gameMode = MODE_PICO_CLIENT

function _init()
    frame = 0
    restartNet()
    restartLobby()
    restartUnicorns()
    restartProgress()
    restartCircles()
    restartArrows()
    restartPlayer()
    restartCountdown()
    restartEnd()
    clearServerGPIOPins()
    establishConnection()

    if gameMode == MODE_PICO_CLIENT then
        myself.name = 'myself'
        myself.isAdmin = true
        setPlayers(0, 5, {
            myself,
            player:new { id = 1, name = 'printf', team = 1, isAdmin = false, ready = true, score = 1000 },
            player:new { id = 2, name = 'shin', team = 1, isAdmin = false, ready = false, score = 500 },
            player:new { id = 3, name = 'dark', team = 1, isAdmin = false, ready = false, score = 512 },
            player:new { id = 4, name = 'elazer', team = 1, isAdmin = false, ready = true, score = 777 },
            player:new { id = 5, name = 'reynor', team = 2, isAdmin = false, ready = true, score = 900 },
            player:new { id = 6, name = 'gumiho', team = 2, isAdmin = false, ready = false, score = 800 },
            player:new { id = 7, name = 'has', team = 2, isAdmin = false, ready = true, score = 830 },
            player:new { id = 8, name = 'zest', team = 2, isAdmin = false, ready = false, score = 871 },
        })
    end
end

function _draw()
    cls()

    if gameState == COUNTING_DOWN_TO_GAME_START_STATE then
        drawCountdown()
    elseif gameState == RECEIVED_CONNECTED_TO_SERVER_RESP_STATE then
        drawLobby()
    elseif gameState == GAME_IN_PROGRESS_STATE then
        drawUnicornsWithRainbow()
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
        updateUnicorns()
        updateProgress()
        updateArrows()
        updateCircles()
        updatePlayer()
    elseif gameState == RECEIVED_CONNECTED_TO_SERVER_RESP_STATE then
        updateLobby()
    elseif gameState == COUNTING_DOWN_TO_GAME_START_STATE then
        updateCountdown()
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
