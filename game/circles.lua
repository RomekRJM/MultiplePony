circleCentreX = (rightArrowHitBoundary - leftArrowHitBoundary) / 2 + leftArrowHitBoundary - 1
circleTopCentreY = defaultSpriteY + 8 * (defaultSpriteH - 1)
circlePadY = 28
circleMidCentreY = circleTopCentreY + circlePadY
circleBottomCentreY = circleMidCentreY + circlePadY
circleRadius = defaultSpriteH * 4 + 2

fireflyLeftLookupTable = {}
fireflyRightLookupTable = {}
fireflyLookupTableLength = 90
minFireflies = 8
maxFireflies = 50
noFireflies = 2
animateCircles = { false, false, false }
circlesAnimationFrame = { 1, 1, 1 }
fireflyColorIndex = 1
fireflyColors = { 13, 9, 10, 12, 11 }

circleParticles = {}
circleParticlesLookupTable = {}
flameDuration = {}
defaultFlameDuration = 60
plusPath = {}
plusPathLen = 30
pluses = {}

function restartCircles()
    circleParticles = { {}, {}, {} }
    pluses = {{}, {}, {}}
    flameDuration = { 0, 0, 0 }
    circleParticlesLookupTable = {}
    animateCircles = { false, false, false }
    circlesAnimationFrame = { 1, 1, 1 }
    noFireflies = minFireflies
    fireflyColorIndex = 1

    local step = 1.0 / (fireflyLookupTableLength * 2)
    for a = 0, 0.5, step do
        add(fireflyLeftLookupTable, {
            x = flr(0.5 + circleCentreX + sin(a) * circleRadius),
            y = flr(0.5 + circleTopCentreY + cos(a) * circleRadius),
        })
    end
    for a = 1.0, 0.5, -step do
        add(fireflyRightLookupTable, {
            x = flr(0.5 + circleCentreX + sin(a) * circleRadius),
            y = flr(0.5 + circleTopCentreY + cos(a) * circleRadius),
        })
    end

    for a = 0.5, 1.0, step do
        add(circleParticlesLookupTable, {
            x = flr(0.5 + circleCentreX + cos(a) * circleRadius),
            y = flr(0.5 - sin(a) * circleRadius),
        })
    end

    for q = 1, 3 do
        plusPath[q] = lerp(
                {
                    x = circleCentreX - 6,
                    y = circleTopCentreY + (q - 1) * circlePadY + 1,
                },
                {
                    x = player.team == 1 and 124 or 1,
                    y = teamScoreYLocation,
                },
                plusPathLen
        )
    end
end

function updateCircles()
    for q = 1, 3 do
        if flameDuration[q] <= 0 then
            goto addMorecircleParticles
        end

        flameDuration[q] -= 1

        for i = 1, 1 + rnd(3) do

            if #circleParticles[q] >= 32 then
                break
            end

            local circleParticle = rnd(circleParticlesLookupTable)

            add(circleParticles[q], {
                x = circleParticle.x,
                y = circleParticle.y,
                speed = 0.3 * rnd(4),
                colour = 7,
                radius = 1 + rnd(2),
                duration = 5 + rnd(16)
            })

        end

        ::addMorecircleParticles::
    end

    for q = 1, 3 do
        for p in all(circleParticles[q]) do
            p.y -= p.speed
            p.duration -= 1

            if p.duration <= 0 then
                del(circleParticles[q], p)
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

    for q = 1, 3 do
        for pl in all(pluses[q]) do
            if pl.i < #plusPath[q] then
                pl.i += 1
                pl.x = plusPath[q][pl.i].x
                pl.y = plusPath[q][pl.i].y
            else
                myself.score += pl.points
                del(pluses[q], pl)
            end
        end
    end
end

function drawCircles()
    for q = 1, 3 do
        local yOffset = circleTopCentreY + (q - 1) * circlePadY
        for pa in all(circleParticles[q]) do
            circfill(pa.x, pa.y + yOffset, pa.radius, pa.colour)
        end
    end

    circ(circleCentreX, circleTopCentreY, circleRadius, 7)
    circ(circleCentreX, circleMidCentreY, circleRadius, 7)
    circ(circleCentreX, circleBottomCentreY, circleRadius, 7)

    for q = 1, 3 do
        for i = 1, noFireflies do
            if animateCircles[q] then
                local fireflyLookupTable = (i % 2 == 0) and fireflyLeftLookupTable or fireflyRightLookupTable
                local fireflyCoordinates = fireflyLookupTable[((circlesAnimationFrame[q] + i) % fireflyLookupTableLength) + 1]
                pset(fireflyCoordinates.x, fireflyCoordinates.y + (q - 1) * circlePadY, fireflyColors[fireflyColorIndex])
            end
        end

        circlesAnimationFrame[q] += 1

        if circlesAnimationFrame[q] > fireflyLookupTableLength then
            circlesAnimationFrame[q] = 1
            animateCircles[q] = false
        end
    end

    for q = 1, 3 do
        for pl in all(pluses[q]) do
            print(pl.text, pl.x, pl.y)
        end
    end
end

function launchCircleAnimation(q, points)
    flameDuration[q] = defaultFlameDuration

    if animateCircles[q] == false then
        animateCircles[q] = true
    end

    add(pluses[q],
            {
                i = 0,
                points = points,
                text = "+" .. points,
                x = 0,
                y = 0,
            }
    )

    circlesAnimationFrame[q] = 1
    noFireflies += 1

    if noFireflies > maxFireflies then
        if fireflyColorIndex < #fireflyColors then
            fireflyColorIndex += 1
            noFireflies = minFireflies
        else
            noFireflies = maxFireflies
        end
    end
end