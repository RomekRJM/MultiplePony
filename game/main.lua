frame = 0
MODE_WEB_BROWSER = 1
MODE_PICO_CLIENT = 0
gameMode = MODE_PICO_CLIENT

function _init()
    frame = 0
    restartNet()
    restartLobby()
    restartUnicorns()
    restartArrows()
    restartPlayer()
    restartCountdown()
    restartEnd()
    clearGPIOPins()
    establishConnection()
end

function clsPartial()
    rectfill(0, circleTopCentreY-circleRadius, 128, 128, 0) -- clear arrow area
    rectfill(teamScoreXLocation, teamScoreYLocation, 100, 7, 0) -- clear scores area
    rectfill(leftRainbowX, 24, rightRainbowX, 36, 0) -- clear rainbow area
    rectfill(rainbowCollisionX-4, 8, rainbowCollisionX+4, 23, 0) -- clear upper particle area
    rectfill(rainbowCollisionX-4, 37, rainbowCollisionX+4, 55, 0) -- clear lower particle area
end

function _draw()
    if gameState ~= GAME_IN_PROGRESS_STATE or frame == 3 then
        cls()
    end
    --print('game state ' .. tonum(gameState), 0, 8)

    if gameState == COUNTING_DOWN_TO_GAME_START_STATE then
        drawCountdown()
    elseif gameState == RECEIVED_CONNECTED_TO_SERVER_RESP_STATE then
        drawLobby()
    elseif gameState == GAME_IN_PROGRESS_STATE then
        clsPartial()
        drawUnicornsWithRainbow()
        drawArrows()
        drawTeamScores()
    elseif gameState == GAME_END_SCREEN_STATE then
        drawEndScreen()
    end
end

function _update60()
    if gameState == GAME_IN_PROGRESS_STATE then
        updateUnicorns()
        updateArrows()
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
