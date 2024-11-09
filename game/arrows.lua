arrow = sprite:new {
    padX = 32,
    associatedAction = 1,
    actioned = false,
    z = 1,
}

maxZ = 11
generatorCntr = {}
generatorCntr[1] = 0
generatorCntr[2] = 0

leftArrow = arrow:new { z = 2, }
rightArrow = arrow:new { flip_x = true, associatedAction = 2, }
topArrow = arrow:new { sprite = 2, associatedAction = 4, }
bottomArrow = arrow:new { sprite = 2, flip_y = true, associatedAction = 8, }
zArrow = arrow:new { z = maxZ, sprite = 4, associatedAction = 16, }
xArrow = arrow:new { z = maxZ, sprite = 6, associatedAction = 32, }

leftHalfArrow = arrow:new {
    sprite = 0, w = 1, z = 1, padX = 8, firstElementPadX = 8,
    parent = leftArrow, parentBeforeRepeatSequence = false
}
rightHalfArrow = arrow:new {
    sprite = 0, flip_x = true, associatedAction = 2, w = 1, padX = 8, firstElementPadX = 16,
    parent = rightArrow, parentBeforeRepeatSequence = true
}
topHalfArrow = arrow:new {
    sprite = 3, associatedAction = 4, w = 1, padX = 5, firstElementPadX = 13,
    parent = topArrow, parentBeforeRepeatSequence = true
}
bottomHalfArrow = arrow:new {
    sprite = 3, flip_y = true, associatedAction = 8, w = 1, padX = 5, firstElementPadX = 13,
    parent = bottomArrow, parentBeforeRepeatSequence = true
}
zHalfArrow = arrow:new {
    sprite = 8, associatedAction = 16, w = 1, padX = 5, firstElementPadX = 10,
    parent = zArrow, parentBeforeRepeatSequence = true, changeZSequentially = true
}
xHalfArrow = arrow:new {
    sprite = 8, associatedAction = 32, w = 1, padX = 5, firstElementPadX = 10,
    parent = xArrow, parentBeforeRepeatSequence = true, changeZSequentially = true
}

halfArrowWidth = arrow.w * 4
arrowPerfectX = 64 - halfArrowWidth
arrowMinAcceptableX = arrowPerfectX - halfArrowWidth
arrowMaxAcceptableX = arrowPerfectX + halfArrowWidth

quarterArrowWidth = arrow.w * 2
halfArrowPerfectX = 64 - quarterArrowWidth
halfArrowMinAcceptableX = halfArrowPerfectX - quarterArrowWidth
halfArrowMaxAcceptableX = halfArrowPerfectX + quarterArrowWidth

currentArrow = {}
visibleArrowQueue = {}
visibleArrowQueueLen = {}
arrowQueue = {}
arrowQueueIndex = {}
currentLevelDuration = 0

levelData = "L-27,L-26,R-28"
levelData2 = "X-4,Z-28"
levelDuration = 13398

symbolMapping = {
    ['L'] = leftArrow,
    ['R'] = rightArrow,
    ['T'] = topArrow,
    ['B'] = bottomArrow,
    ['X'] = xArrow,
    ['Z'] = zArrow,
    ['l'] = leftHalfArrow,
    ['r'] = rightHalfArrow,
    ['t'] = topHalfArrow,
    ['b'] = bottomHalfArrow,
    ['x'] = xHalfArrow,
    ['z'] = zHalfArrow
}

function prepareLevelFromParsedData()
    generatorCntr[1] = 0
    generatorCntr[2] = 0
    arrowQueueLen = {}
    tmpArrowQueue = {}

    for q = 1, 2 do
        local levelSource = q == 1 and levelData or levelData2

        data = split(levelSource)
        arrowQueueLen[q] = #data
        tmpArrowQueue[q] = {}

        for instruction in all(data) do
            local parts = split(instruction, "-")
            local element = 1
            local arrowLetter = parts[element]
            element += 1

            local currentArrow = deepCopy(symbolMapping[arrowLetter])

            if ord(arrowLetter) >= 96 and ord(arrowLetter) <= 122 then
                currentArrow.r = tonum(parts[element])
                arrowQueueLen[q] += currentArrow.r
                element += 1
            end

            currentArrow.padX = tonum(parts[element])
            add(tmpArrowQueue[q], currentArrow)
        end
    end
end

function nextArrowFromParsedData(qn)
    generatorCntr[qn] += 1

    if generatorCntr[qn] <= arrowQueueLen[qn] then
        return tmpArrowQueue[qn][generatorCntr[qn]]
    end

    return nil
end

function generateLevel(generateRandom)
    prepareLevelFromParsedData()

    for q = 1, 2 do
        local i = 1
        while true do
            local currentArrow = generateRandom and nextRandomArrow(q) or nextArrowFromParsedData(q)

            if currentArrow == nil then
                break
            end

            if q == 2 then
                currentArrow.y += circlePadY
            end

            local j = 0
            arrowQueue[q][i] = deepCopy(currentArrow)

            if currentArrow.w == 1 then
                -- half arrow
                local currentZ = maxZ - 1

                for _ = 1, currentArrow.r do
                    j += 1
                    arrowQueue[q][i + j] = deepCopy(currentArrow)

                    if currentArrow.changeZSequentially then
                        arrowQueue[q][i + j].z = currentZ
                        currentZ -= 1

                        if currentZ < 1 then
                            currentZ = maxZ - 1
                        end
                    end
                end

                arrowQueue[q][i + j].nextElementPadX = currentArrow.parent.nextElementPadX

                if currentArrow.parentBeforeRepeatSequence then
                    local firstElementPadX = arrowQueue[q][i].firstElementPadX
                    arrowQueue[q][i] = deepCopy(currentArrow.parent)
                    arrowQueue[q][i].nextElementPadX = firstElementPadX

                    if q == 2 then
                        arrowQueue[q][i].y += circlePadY
                    end
                else
                    arrowQueue[q][i + j] = deepCopy(currentArrow.parent)

                    if q == 2 then
                        arrowQueue[q][i + j].y += circlePadY
                    end
                end

                i += j

            end

            i += 1
        end
    end
end

function restartArrows()
    arrowQueueIndex[1] = 1
    arrowQueueIndex[2] = 1
    arrowUpdateBatchLen = 10
    arrowSpeed = 1

    arrowQueue[1] = {}
    arrowQueue[2] = {}
    arrowQueueLen = 32
    visibleArrowQueue[1] = {}
    visibleArrowQueue[2] = {}
    visibleArrowQueueMaxLen = 10
    currentLevelDuration = 0

    generateLevel()

    for q = 1, 2 do
        for i, currentArrow in pairs(arrowQueue[q]) do
            if i <= arrowUpdateBatchLen then
                currentArrow.x = 128
            end
        end
    end

    for q = 1, 2 do
        add(visibleArrowQueue[q], deepCopy(arrowQueue[q][1]))
        visibleArrowQueueLen[q] = 1
    end
end

rightArrowHitBoundary = 80
leftArrowHitBoundary = 48
circleCentreX = (rightArrowHitBoundary - leftArrowHitBoundary) / 2 + leftArrowHitBoundary - 1
circleTopCentreY = defaultSpriteY + 8 * (defaultSpriteH - 1)
circlePadY = 25
circleBottomCentreY = circleTopCentreY + circlePadY
circleRadius = defaultSpriteH * 4 + 2

function drawArrows()

    circ(circleCentreX, circleTopCentreY, circleRadius)
    circ(circleCentreX, circleBottomCentreY, circleRadius)

    for q = 1, 2 do
        for z = 1, maxZ do
            for _, visible_arrow in pairs(visibleArrowQueue[q]) do

                if z ~= visible_arrow.z then
                    goto continueInnerArrowLoop
                end

                if visible_arrow == currentArrow[q] then
                    pal(7, 11)
                end

                spr(visible_arrow.sprite, visible_arrow.x, visible_arrow.y, visible_arrow.w, visible_arrow.h,
                        visible_arrow.flip_x, visible_arrow.flip_y)

                if visible_arrow == currentArrow[q] then
                    pal()
                end

                :: continueInnerArrowLoop ::
            end
        end
    end

    print(stat(1), 0, 0)
end

function logarrows()
    for q = 1, 2 do
        for _, visibleArrow in pairs(visibleArrowQueue[q]) do
            printh("arrowQueueIndex: " .. tostring(arrowQueueIndex[q]))
            printh("visibleArrowQueueLen: " .. tostring(visibleArrowQueueLen[q]))
            printh(tostring(i) .. ": " .. tostring(visibleArrow.x))
        end
    end
end

function updateArrows()
    local scheduledForDeletion = {}
    scheduledForDeletion[1] = {}
    scheduledForDeletion[2] = {}

    local currentArrowMinAcceptableX = 0;
    local currentArrowMaxAcceptableX = 0;

    if currentLevelDuration >= levelDuration then
        gameState = GAME_END_SCREEN_STATE
    end

    currentLevelDuration += 1

    for q = 1, 2 do
        currentArrow[q] = nil

        if visibleArrowQueueLen[q] == 0 and arrowQueueIndex[q] == arrowQueueLen[q] then
            return
        end

        for _, visibleArrow in pairs(visibleArrowQueue[q]) do
            visibleArrow.x = visibleArrow.x - arrowSpeed
            visibleArrow.padX = visibleArrow.padX - arrowSpeed

            if visibleArrow.padX == 0 and arrowQueueIndex[q] < arrowQueueLen[q] then
                add(visibleArrowQueue[q], deepCopy(arrowQueue[q][arrowQueueIndex[q]]))
                arrowQueueIndex[q] += 1
                visibleArrowQueueLen[q] += 1
            end

            if visibleArrow.w == 1 then
                currentArrowMinAcceptableX = halfArrowMinAcceptableX
                currentArrowMaxAcceptableX = halfArrowMaxAcceptableX
            else
                currentArrowMinAcceptableX = arrowMinAcceptableX
                currentArrowMaxAcceptableX = arrowMaxAcceptableX
            end

            if visibleArrow.x > currentArrowMinAcceptableX and visibleArrow.x < currentArrowMaxAcceptableX then
                if currentArrow[q] == nil then
                    currentArrow[q] = visibleArrow
                end
            end

            if visibleArrow.x < visibleArrow.w * -8 then
                add(scheduledForDeletion[q], visibleArrow)
            end
        end
    end

    for q = 1, 2 do
        for deletedArrow in all(scheduledForDeletion[q]) do
            del(visibleArrowQueue[q], deletedArrow)
            visibleArrowQueueLen[q] -= 1
        end
    end
end
