leftUnicorn = sprite:new {
    x = 0,
    y = 10,
    sprite = 33,
    w = 5,
    h = 4,
}

rightUnicorn = sprite:new {
    x = 128 - 5 * 8, -- screen_width - w * default_sprite_width
    y = 10,
    sprite = 33,
    w = 5,
    h = 4,
    flip_x = true
}

rainbowPart = sprite:new {
    x = 16,
    y = 27,
    sprite = 32,
    w = 1,
    h = 1,
    visible = false,
}

rainbowAngleMultiplier = 16 / 360
rainbowCollisionX = 0
leftRainbowX = 24
rightRainbowX = 102

function restartUnicorns()
    rainbow = {}
    rainbowLength = 0

    for x = leftRainbowX, rightRainbowX, 1 do
        add(rainbow, deepCopy(rainbowPart:new({ x = x })))
    end
end

function drawUnicorns()
    spr(leftUnicorn.sprite, leftUnicorn.x, leftUnicorn.y, leftUnicorn.w, leftUnicorn.h,
            leftUnicorn.flip_x, leftUnicorn.flip_y)
    pal(7, 6)
    pal(13, 5)
    pal(8, 2)
    pal(14, 8)
    pal(12, 1)
    spr(rightUnicorn.sprite, rightUnicorn.x, rightUnicorn.y, rightUnicorn.w, rightUnicorn.h,
            rightUnicorn.flip_x, rightUnicorn.flip_y)
    pal()
end

function drawRainbow()
    for i, rainbowSprite in ipairs(rainbow) do
        if rainbowSprite.visible then
            spr(rainbowSprite.sprite, arrowSinoid[i].x, arrowSinoid[i].y, rainbowSprite.w, rainbowSprite.h)
        end
    end
end

particles = {}

function updateParticles(sourceX, sourceY)
    for i = 1, 1 + rnd(3) do

        if count(particles) >= 33 then
            break
        end

        add(particles, {
            x = sourceX,
            y = sourceY + rnd(3),
            speed = 0.3 * rnd(4),
            colour = 7,
            radius = rnd(4),
            duration = 5 + rnd(16)
        })

    end

    for p in all(particles) do
        p.y -= p.speed

    p.duration -= 1

    if p.duration <= 0 then
        del(particles, p)
    elseif p.duration < 3 then
        p.radius = 1
        p.colour = 5
    elseif p.duration < 5 then
        if p.radius == 3 then
            p.radius = -0.3
        end
        p.colour = 9
    elseif p.duration < 7 then
        p.colour = 10
    end
    end
end

function drawUnicornsWithRainbow()
    drawRainbow()
    drawParticles()
    drawUnicorns()
end

function drawParticles()
    for p in all(particles) do
        circfill(p.x, p.y, p.radius, p.colour)
        circfill(p.x, 60 - p.y, p.radius, p.colour)
    end
end

rcShift = 0
arrowSinoid = {}
rainbowLength = 0

function lograinbow()
    for i, rainbowSprite in ipairs(rainbow) do
        printh(tostring(i) .. ": " .. tostring(rainbowSprite.visible))
    end
end

function updateUnicorns()
    rainbowCollisionX = leftRainbowX + (rightRainbowX - leftRainbowX) / 2

    --if btn(⬅️) then
    --    rcShift -= 1
    --end
    --
    --if btn(➡️) then
    --    rcShift += 1
    --end
    --
    --rainbowCollisionX += rcShift

    local angle = 0
    local shiftY = 0
    local x = 0

    for i, rainbowSprite in ipairs(rainbow) do

        if rainbowSprite.x <= rainbowCollisionX then
            angle = (frame + i * 2) % 360
            shiftY = sin(angle * rainbowAngleMultiplier)
            x = rainbowCollisionX - rainbowSprite.x + leftRainbowX
            arrowSinoid[i] = {
                x = x,
                y = rainbowSprite.y - shiftY
            }

            if x - leftRainbowX < rainbowLength then
                rainbowSprite.visible = true
            end
        else
            angle = (frame - i * 2) % 360
            shiftY = sin(angle * rainbowAngleMultiplier)
            x = rainbowCollisionX - rainbowSprite.x + rightRainbowX
            arrowSinoid[i] = {
                x = x,
                y = rainbowSprite.y + shiftY
            }

            if rightRainbowX - x < rainbowLength then
                rainbowSprite.visible = true
            end
        end
    end

    if rainbowLength >= (rightRainbowX - leftRainbowX) / 2 then
        updateParticles(rainbowCollisionX, 28)
    else
        rainbowLength += 1
    end
end