arrow = sprite:new {
    nextElementPadX = 32,
    associatedAction = 1,
    actioned = false,
    z = 1,
}

maxZ = 11
generatorCntr = 1

leftArrow = arrow:new { z = 2, }
rightArrow = arrow:new { flip_x = true, associatedAction = 2, }
topArrow = arrow:new { sprite = 2, associatedAction = 4, }
bottomArrow = arrow:new { sprite = 2, flip_y = true, associatedAction = 8, }
zArrow = arrow:new { z = maxZ, sprite = 4, associatedAction = 16, }
xArrow = arrow:new { z = maxZ, sprite = 6, associatedAction = 32, }

leftHalfArrow = arrow:new {
    sprite = 0, w = 1, z = 1, nextElementPadX = 8, firstElementPadX = 8,
    parent = leftArrow, parentBeforeRepeatSequence = false
}
rightHalfArrow = arrow:new {
    sprite = 0, flip_x = true, associatedAction = 2, w = 1, nextElementPadX = 8, firstElementPadX = 16,
    parent = rightArrow, parentBeforeRepeatSequence = true
}
topHalfArrow = arrow:new {
    sprite = 3, associatedAction = 4, w = 1, nextElementPadX = 5, firstElementPadX = 13,
    parent = topArrow, parentBeforeRepeatSequence = true
}
bottomHalfArrow = arrow:new {
    sprite = 3, flip_y = true, associatedAction = 8, w = 1, nextElementPadX = 5, firstElementPadX = 13,
    parent = bottomArrow, parentBeforeRepeatSequence = true
}
zHalfArrow = arrow:new {
    sprite = 8, associatedAction = 16, w = 1, nextElementPadX = 5, firstElementPadX = 10,
    parent = zArrow, parentBeforeRepeatSequence = true, changeZSequentially = true
}
xHalfArrow = arrow:new {
    sprite = 8, associatedAction = 32, w = 1, nextElementPadX = 5, firstElementPadX = 10,
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

currentArrow = nil

levelData = "L8,R32,T32,B32,X16,Z8" --l32r5

symbolMapping = {
    ['L'] = leftArrow,
    ['R'] = rightArrow,
    ['T'] = topArrow,
    ['B'] = bottomArrow,
    ['X'] = xArrow,
    ['Z'] = zArrow
}

function prepareLevelFromParsedData()
    generatorCntr = 0

    data = split(levelData)
    arrowQueueLen = #data
    tmpArrowQueue = {}

    for instruction in all(data) do
        local arrowLetter = sub(instruction, 1, 1)
        printh(arrowLetter)
        add(tmpArrowQueue, deepCopy(symbolMapping[arrowLetter]))
    end
end

function prepareRandomData()
    generatorCntr = 0

    sequence = {
        leftArrow, rightArrow, topArrow, bottomArrow, zArrow, xArrow,
        leftHalfArrow, rightHalfArrow, topHalfArrow, bottomHalfArrow, zHalfArrow, xHalfArrow
    }

    halfArrowRepeats = { 4, 6, 8, 10 }
end

function nextRandomArrow()
    generatorCntr += 1

    if generatorCntr <= arrowQueueLen then
       return rnd(sequence)
    end

    return nil
end

function nextArrowFromParsedData()
    generatorCntr += 1

    if generatorCntr <= arrowQueueLen then
       return tmpArrowQueue[generatorCntr]
    end

    return nil
end

function generateLevel(generateRandom)
    local i = 1

    if generateRandom then
        prepareRandomData()
    else
        prepareLevelFromParsedData()
    end

    while true do
        local currentArrow = generateRandom and nextRandomArrow() or nextArrowFromParsedData()

        if currentArrow == nil then
            break
        end

        local j = 0
        arrowQueue[i] = deepCopy(currentArrow)

        if currentArrow.w == 1 then
            -- half arrow
            local halfArrowRepeat = rnd(halfArrowRepeats)
            local currentZ = maxZ - 1

            for _ = 1, halfArrowRepeat do
                j += 1
                arrowQueue[i + j] = deepCopy(currentArrow)

                if currentArrow.changeZSequentially then
                    arrowQueue[i + j].z = currentZ
                    currentZ -= 1

            if currentZ < 1 then
            currentZ = maxZ - 1
                end
                end
            end

            arrowQueue[i + j].nextElementPadX = currentArrow.parent.nextElementPadX

            if currentArrow.parentBeforeRepeatSequence then
                local firstElementPadX = arrowQueue[i].firstElementPadX
                arrowQueue[i] = deepCopy(currentArrow.parent)
                arrowQueue[i].nextElementPadX = firstElementPadX
            else
                arrowQueue[i + j] = deepCopy(currentArrow.parent)
            end

            i += j

        end

        i += 1
    end
end

function restartArrows()
    arrowQueueIndex = 1
    arrowUpdateBatchLen = 10
    arrowSpeed = 1

    arrowQueue = {}
    arrowQueueLen = 32
    visibleArrowQueue = {}
    visibleArrowQueueMaxLen = 10

    generateLevel(false)

    for i, currentArrow in pairs(arrowQueue) do
        if i <= arrowUpdateBatchLen then
            currentArrow.x = 128
        end
    end

    printh(tprint(arrowQueue))

    add(visibleArrowQueue, deepCopy(arrowQueue[1]))
    visibleArrowQueueLen = 1
end

rightArrowHitBoundary = 80
leftArrowHitBoundary = 48
circleCentreX = (rightArrowHitBoundary - leftArrowHitBoundary) / 2 + leftArrowHitBoundary - 1
circleCentreY = defaultSpriteY + 8 * (defaultSpriteH - 1)
circleRadius = defaultSpriteH * 4 + 2

function drawArrows()

    circ(circleCentreX, circleCentreY, circleRadius)

    for z = 1, maxZ do
        for _, visible_arrow in pairs(visibleArrowQueue) do

            if z ~= visible_arrow.z then
                goto continueInnerArrowLoop
            end

            if visible_arrow == currentArrow then
                pal(7, 11)
            end

            spr(visible_arrow.sprite, visible_arrow.x, visible_arrow.y, visible_arrow.w, visible_arrow.h,
                    visible_arrow.flip_x, visible_arrow.flip_y)

            if visible_arrow == currentArrow then
                pal()
            end

            :: continueInnerArrowLoop ::
        end
    end

    print(stat(1), 0, 0)
end

function logarrows()
    printh("arrowQueueIndex: " .. tostring(arrowQueueIndex))
    printh("visibleArrowQueueLen: " .. tostring(visibleArrowQueueLen))

    for _, visibleArrow in pairs(visibleArrowQueue) do
        printh(tostring(i) .. ": " .. tostring(visibleArrow.x))
    end
end

function updateArrows()
    currentArrow = nil

    if visibleArrowQueueLen == 0 and arrowQueueIndex == arrowQueueLen then
        return
    end

    local scheduledForDeletion = {}
    local currentArrowMinAcceptableX = 0;
    local currentArrowMaxAcceptableX = 0;

    for _, visibleArrow in pairs(visibleArrowQueue) do
        visibleArrow.x = visibleArrow.x - arrowSpeed
        visibleArrow.nextElementPadX = visibleArrow.nextElementPadX - arrowSpeed

        if visibleArrow.nextElementPadX == 0 and arrowQueueIndex < arrowQueueLen then
            add(visibleArrowQueue, deepCopy(arrowQueue[arrowQueueIndex]))
            arrowQueueIndex = arrowQueueIndex + 1
            visibleArrowQueueLen = visibleArrowQueueLen + 1
        end

        if visibleArrow.w == 1 then
            currentArrowMinAcceptableX = halfArrowMinAcceptableX
            currentArrowMaxAcceptableX = halfArrowMaxAcceptableX
        else
            currentArrowMinAcceptableX = arrowMinAcceptableX
            currentArrowMaxAcceptableX = arrowMaxAcceptableX
        end

        if visibleArrow.x > currentArrowMinAcceptableX and visibleArrow.x < currentArrowMaxAcceptableX then
            if currentArrow == nil then
                currentArrow = visibleArrow
            end
        end

        if visibleArrow.x < visibleArrow.w * -8 then
            add(scheduledForDeletion, visibleArrow)
        end
    end

    for deletedArrow in all(scheduledForDeletion) do
        del(visibleArrowQueue, deletedArrow)
        visibleArrowQueueLen = visibleArrowQueueLen - 1
    end
end
