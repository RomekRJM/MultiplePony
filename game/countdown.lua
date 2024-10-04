secondToSprite = {
    [3] = {
        sprite:new { x = 32, y = 32, sprite = 10, w = 4, h = 4 }
    },
    [2] = {
        sprite:new { x = 32, y = 32, sprite = 12, w = 4, h = 4 }
    },
    [1] = {
        sprite:new { x = 32, y = 32, sprite = 11, w = 4, h = 4 }
    },
    [0] = {
        sprite:new { x = 32, y = 32, sprite = 28, w = 4, h = 4 },
        sprite:new { x = 64, y = 32, sprite = 28, w = 1, h = 4 },
    },
}

function drawCountdown()

    --local currentCountdownSprite = secondToSprite[secondsCountdown]
    --
    --for sp in all(currentCountdownSprite) do
    --    spr(sp.sprite, sp.x, sp.y, sp.w, sp.h)
    --end
end