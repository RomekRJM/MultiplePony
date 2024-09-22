frame = 0

function _init()
    frame = 0
    restartUnicorns()
    restartArrows()
    restartPlayer()
    clearGPIOPins()
    establishConnection()
end

function _draw()
    cls()
    drawUnicornsWithRainbow()
    drawArrows()
    drawPlayerPoints()
    print('game state ' .. tonum(gameState), 0, 8)
end

function _update60()
    updateUnicorns()
    updateArrows()
    updatePlayer()
    handleUpdateFromServer()
    sendRoundStartCommand()
    frame = frame + 1
end
