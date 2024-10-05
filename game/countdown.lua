secondToSprite = {
    [4] = {
        sprite:new { x = 45, y = 44, sprite = 96, w = 4, h = 4 },
        sprite:new { x = 77, y = 44, sprite = 100, w = 1, h = 4 },
    },
    [3] = {
        sprite:new { x = 45, y = 44, sprite = 101, w = 4, h = 4 },
        sprite:new { x = 77, y = 44, sprite = 105, w = 1, h = 4 },
    },
    [2] = {
        sprite:new { x = 45, y = 46, sprite = 11, w = 4, h = 4 }
    },
    [1] = {
        sprite:new { x = 45, y = 44, sprite = 38, w = 4, h = 4 },
        sprite:new { x = 77, y = 44, sprite = 42, w = 1, h = 4 },
    },
}

function drawCountdown()

    local currentCountdownSprite = secondToSprite[secondsCountdown]

    for sp in all(currentCountdownSprite) do
        spr(sp.sprite, sp.x, sp.y, sp.w, sp.h)
    end
end