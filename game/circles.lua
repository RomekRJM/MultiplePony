circleCentreX = (rightArrowHitBoundary - leftArrowHitBoundary) / 2 + leftArrowHitBoundary - 1
circleTopCentreY = defaultSpriteY + 8 * (defaultSpriteH - 1)
circlePadY = 25
circleMidCentreY = circleTopCentreY + circlePadY
circleBottomCentreY = circleMidCentreY + circlePadY
circleRadius = defaultSpriteH * 4 + 2

fireflyLeftLookupTable = {}
fireflyRightLookupTable = {}
fireflyLookupTableLength = 90
noFireflies = 2

function restartCircles()
    noFireflies = 2
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

    for i = 1, noFireflies do
        local fireflyLookupTable = (i % 2 == 0) and fireflyLeftLookupTable or fireflyRightLookupTable
        local fireflyCoordinates = fireflyLookupTable[((frame + i) % fireflyLookupTableLength) + 1]

        pset(fireflyCoordinates.x, fireflyCoordinates.y, 12)
        pset(fireflyCoordinates.x, fireflyCoordinates.y + circlePadY, 12)
        pset(fireflyCoordinates.x, fireflyCoordinates.y + 2 * circlePadY, 12)
    end
end