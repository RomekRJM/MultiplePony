frame = 0

function _init()
    frame = 0
    restartUnicorns()
    restartArrows()
    restartPlayer()
end

function _draw()
    cls()
    drawUnicornsWithRainbow()
    drawArrows()
    drawPlayerPoints()
end

function _update60()
    updateUnicorns()
    updateArrows()
    updatePlayer()
    establishConnection()
    frame = frame + 1
end
