leftRainbowX = 24
rightRainbowX = 102
rainbowLength = 0
rcShift = 0
rainbowCollisionX = 0

function restartUnicorns()
    rainbowLength = 0
    rcShift = 0
    rainbowCollisionX = 0
end

function drawUnicorns()
end

function drawRainbow()
    --if leftRainbowX + frame < rainbowCollisionX then
    --    sspr(0, 80, frame, 19, leftRainbowX, 22, frame, 19, true)
    --    sspr(0, 80, frame, 19, rightRainbowX, 22, -frame, 19, true)
    --else
    --    local leftRainbowLength = rainbowCollisionX-leftRainbowX
    --    local rightRainbowLength = rightRainbowX-rainbowCollisionX
    --    sspr(frame % (87 - rainbowLength), 80, leftRainbowLength, 19, leftRainbowX, 22, leftRainbowLength, 19,  true)
    --    sspr(frame % (87 - rainbowLength), 80, rightRainbowLength, 19, rightRainbowX, 22, -rightRainbowLength, 19, true)
    --end
end

--particles = {}

--function updateParticles(sourceX, sourceY)
--    for i = 1, 1 + rnd(3) do
--
--        if count(particles) >= 10 then
--            break
--        end
--
--        add(particles, {
--            x = sourceX,
--            y = sourceY + rnd(3),
--            speed = 0.3 * rnd(4),
--            colour = 7,
--            radius = 1 + rnd(4),
--            duration = 5 + rnd(16)
--        })
--
--    end
--
--    for p in all(particles) do
--        p.y -= p.speed
--        p.duration -= 1
--
--        if p.duration <= 0 then
--            del(particles, p)
--        elseif p.duration < 3 then
--            p.radius = 1
--            p.colour = 5
--        elseif p.duration < 5 then
--            if p.radius == 3 then
--                p.radius = -0.3
--            end
--            p.colour = 9
--        elseif p.duration < 7 then
--            p.colour = 10
--        end
--    end
--end

function drawUnicornsWithRainbow()
    --drawRainbow()
    --drawParticles()
    --drawUnicorns()
end

function drawParticles()
    --for p in all(particles) do
    --    circfill(p.x, p.y, p.radius, p.colour)
    --    circfill(p.x, 60 - p.y, p.radius, p.colour)
    --end
end

function updateUnicorns()
    rainbowCollisionX = (leftRainbowX + (rightRainbowX - leftRainbowX) / 2) + rcShift
    if rainbowLength >= (rightRainbowX - leftRainbowX) / 2 then
        --updateParticles(rainbowCollisionX, 28)
    else
        rainbowLength += 1
    end
end
