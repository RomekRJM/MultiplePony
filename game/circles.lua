circleCentreX = (rightArrowHitBoundary - leftArrowHitBoundary) / 2 + leftArrowHitBoundary - 1
circleTopCentreY = defaultSpriteY + 8 * (defaultSpriteH - 1)
circlePadY = 25
circleMidCentreY = circleTopCentreY + circlePadY
circleBottomCentreY = circleMidCentreY + circlePadY
circleRadius = defaultSpriteH * 4 + 2

fireflyLeftLookupTable = {}
fireflyRightLookupTable = {}
fireflyLookupTableLength = 120
noFireflies = 30

function restartCircles()
    local step = 1.0 / (fireflyLookupTableLength * 2)
    for a = 0, 0.5, step do
        add(fireflyLeftLookupTable, {
            x = circleCentreX + sin(a) * circleRadius,
            y = circleTopCentreY + cos(a) * circleRadius,
        })
    end
    for a = 1.0, 0.5, -step do
        add(fireflyRightLookupTable, {
            x = circleCentreX + sin(a) * circleRadius,
            y = circleTopCentreY + cos(a) * circleRadius,
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
    end
end