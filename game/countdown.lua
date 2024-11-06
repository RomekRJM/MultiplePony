secondToSprite = {
    [4] = {
        sprite:new { x = 45, y = 46, sprite = 96, w = 4, h = 4 },
        sprite:new { x = 77, y = 46, sprite = 100, w = 1, h = 4 },
    },
    [3] = {
        sprite:new { x = 45, y = 46, sprite = 101, w = 4, h = 4 },
        sprite:new { x = 77, y = 46, sprite = 105, w = 1, h = 4 },
    },
    [2] = {
        sprite:new { x = 45, y = 46, sprite = 11, w = 4, h = 4 }
    },
    [1] = {
        sprite:new { x = 45, y = 44, sprite = 38, w = 4, h = 4 },
        sprite:new { x = 77, y = 44, sprite = 42, w = 1, h = 4 },
    },
}

roundStartTime = 0
lastCountdownTime = 0
secondsCountdown = 4

function restartCountdown()
    roundStartTime = 0
end

function drawCountdown()

    local currentCountdownSprite = secondToSprite[secondsCountdown]

    for sp in all(currentCountdownSprite) do
        spr(sp.sprite, sp.x, sp.y, sp.w, sp.h)
    end
end

function updateCountdown()
    if roundStartTime == 0 then
        roundStartTime = time()
        secondsCountdown = 4
        lastCountdownTime = time()
    end

    if time() - lastCountdownTime >= 1 then
        secondsCountdown = secondsCountdown - 1
        lastCountdownTime = time()
    else
        return
    end

    if secondsCountdown <= 0 then
        gameState = GAME_IN_PROGRESS_STATE
        sendStartSongCommand()
    end
end