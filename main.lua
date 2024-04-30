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
    frame = frame + 1
end
