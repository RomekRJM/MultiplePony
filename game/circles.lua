circleCentreX = (rightArrowHitBoundary - leftArrowHitBoundary) / 2 + leftArrowHitBoundary - 1
circleTopCentreY = defaultSpriteY + 8 * (defaultSpriteH - 1)
circlePadY = 25
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

function restartCircles()
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
end

function updateCircles()

end

function drawCircles()
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
end

function launchCircleAnimation(q)
    if animateCircles[q] == false then
        animateCircles[q] = true
    end

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