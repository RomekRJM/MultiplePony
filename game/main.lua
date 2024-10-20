frame = 0

function _init()
    frame = 0
    restartLobby()
    restartUnicorns()
    restartArrows()
    restartPlayer()
    clearGPIOPins()
    establishConnection()
end

function _draw()
    cls()
    print('game state ' .. tonum(gameState), 0, 8)

    if gameState == COUNTING_DOWN_TO_GAME_START_STATE then
        drawCountdown()
    elseif gameState == RECEIVED_CONNECTED_TO_SERVER_RESP_STATE then
        drawLobby()
    elseif gameState == GAME_IN_PROGRESS_STATE then
        drawUnicornsWithRainbow()
        drawArrows()
        drawPlayerPoints()
    end
end

function _update60()
    if gameState == GAME_IN_PROGRESS_STATE then
        updateUnicorns()
        updateArrows()
        updatePlayer()
    elseif gameState == RECEIVED_CONNECTED_TO_SERVER_RESP_STATE then
        updateLobby()
    end

    handleUpdateFromServer()
    sendRoundStartCommand()

    if gameState == 1 then
        --poke(BROWSER_GPIO_START_ADDR, START_ROUND_CMD_SERVER_RESP)
        --gameState = COUNTING_DOWN_TO_GAME_START_STATE
        gameState = RECEIVED_CONNECTED_TO_SERVER_RESP_STATE
    end

    frame = frame + 1
end
