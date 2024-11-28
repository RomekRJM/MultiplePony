arrow = sprite:new {
    timestamp = 32,
    associatedAction = 1,
    actioned = false,
    z = 1,
    newColor = nil,
    hasBeenHit = false,
}

maxZ = 11
generatorCntr = {}
generatorCntr[1] = 0
generatorCntr[2] = 0
generatorCntr[3] = 0

leftArrow = arrow:new { z = 2, }
rightArrow = arrow:new { flip_x = true, associatedAction = 2, }
topArrow = arrow:new { sprite = 2, associatedAction = 4, }
midArrow = arrow:new { sprite = 2, flip_y = true, associatedAction = 8, }
zArrow = arrow:new { z = maxZ, sprite = 4, associatedAction = 16, }
xArrow = arrow:new { z = maxZ, sprite = 6, associatedAction = 32, }

leftHalfArrow = arrow:new {
    sprite = 0, w = 1, z = 1, nextElementTimestampDiff = 8, firstElementTimestampDiff = 8,
    parent = leftArrow, parentBeforeRepeatSequence = false
}
rightHalfArrow = arrow:new {
    sprite = 0, flip_x = true, associatedAction = 2, w = 1, nextElementTimestampDiff = 8, firstElementTimestampDiff = 16,
    parent = rightArrow, parentBeforeRepeatSequence = true
}
topHalfArrow = arrow:new {
    sprite = 3, associatedAction = 4, w = 1, nextElementTimestampDiff = 5, firstElementTimestampDiff = 13,
    parent = topArrow, parentBeforeRepeatSequence = true
}
midHalfArrow = arrow:new {
    sprite = 3, flip_y = true, associatedAction = 8, w = 1, nextElementTimestampDiff = 5, firstElementTimestampDiff = 13,
    parent = midArrow, parentBeforeRepeatSequence = true
}
zHalfArrow = arrow:new {
    sprite = 8, associatedAction = 16, w = 1, nextElementTimestampDiff = 5, firstElementTimestampDiff = 10,
    parent = zArrow, parentBeforeRepeatSequence = true, changeZSequentially = true
}
xHalfArrow = arrow:new {
    sprite = 8, associatedAction = 32, w = 1, nextElementTimestampDiff = 5, firstElementTimestampDiff = 10,
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
arrowQueue = {}
currentLevelDuration = 0

levelData = "l-4-80"
levelData2 = "x-4-80"
levelData3 = "r-4-80"
levelDuration = 6000

symbolMapping = {
    ['L'] = leftArrow,
    ['R'] = rightArrow,
    ['T'] = topArrow,
    ['B'] = midArrow,
    ['X'] = xArrow,
    ['Z'] = zArrow,
    ['l'] = leftHalfArrow,
    ['r'] = rightHalfArrow,
    ['t'] = topHalfArrow,
    ['b'] = midHalfArrow,
    ['x'] = xHalfArrow,
    ['z'] = zHalfArrow
}

function prepareLevelFromParsedData()
    generatorCntr[1] = 0
    generatorCntr[2] = 0
    generatorCntr[3] = 0
    arrowQueueLen = {}
    tmpArrowQueue = {}

    for q = 1, 3 do
        local levelSource = q == 1 and levelData or ( q == 2 and levelData2 or levelData3)

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

            currentArrow.timestamp = tonum(parts[element])
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

function generateLevel()
    prepareLevelFromParsedData()

    for q = 1, 3 do
        local i = 1
        while true do
            local currentArrow = nextArrowFromParsedData(q)

            if currentArrow == nil then
                break
            end

            currentArrow.y += circlePadY * (q - 1)

            local j = 0
            arrowQueue[q][i] = deepCopy(currentArrow)

            if currentArrow.w == 1 then
                -- half arrow
                local currentZ = maxZ - 1
                local repeats = currentArrow.parentBeforeRepeatSequence and currentArrow.r or currentArrow.r - 1

                for _ = 1, repeats do
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

                arrowQueue[q][i + j].nextElementTimestampDiff = currentArrow.parent.nextElementTimestampDiff

                if currentArrow.parentBeforeRepeatSequence then
                    local firstElementTimestampDiff = arrowQueue[q][i].firstElementTimestampDiff
                    arrowQueue[q][i] = deepCopy(currentArrow.parent)
                    arrowQueue[q][i].y += circlePadY * (q - 1)
                    arrowQueue[q][i].nextElementTimestampDiff = firstElementTimestampDiff
                else
                    arrowQueue[q][i + j] = deepCopy(currentArrow.parent)
                    arrowQueue[q][i + j].y += circlePadY * (q - 1)
                end

                local finalTimestamp = currentArrow.timestamp
                for k = i, i + j do
                    if arrowQueue[q][k].nextElementTimestampDiff ~= nil then
                        finalTimestamp += arrowQueue[q][k].nextElementTimestampDiff
                        arrowQueue[q][k].timestamp = finalTimestamp
                    end
                end

                if currentArrow.parentBeforeRepeatSequence then
                    arrowQueue[q][i+j].timestamp = arrowQueue[q][i+j-1].timestamp + arrowQueue[q][i+j-1].nextElementTimestampDiff
                else
                    arrowQueue[q][i+j].timestamp = arrowQueue[q][i+j-1].timestamp + arrowQueue[q][i+j-1].firstElementTimestampDiff
                end

                i += j

            end

            i += 1
        end
    end

    logarrows()
end

function restartArrows()
    arrowUpdateBatchLen = 10
    arrowSpeed = 1

    arrowQueue[1] = {}
    arrowQueue[2] = {}
    arrowQueue[3] = {}
    arrowQueueLen = 32
    visibleArrowQueue[1] = {}
    visibleArrowQueue[2] = {}
    visibleArrowQueue[3] = {}
    visibleArrowQueueMaxLen = 10
    currentLevelDuration = 0

    generateLevel()

    for q = 1, 3 do
        for i, currentArrow in ipairs(arrowQueue[q]) do
            if i <= arrowUpdateBatchLen then
                currentArrow.x = 128
            end
        end
    end
end

rightArrowHitBoundary = 80
leftArrowHitBoundary = 48
circleCentreX = (rightArrowHitBoundary - leftArrowHitBoundary) / 2 + leftArrowHitBoundary - 1
circleTopCentreY = defaultSpriteY + 8 * (defaultSpriteH - 1)
circlePadY = 25
circleMidCentreY = circleTopCentreY + circlePadY
circleBottomCentreY = circleMidCentreY + circlePadY
circleRadius = defaultSpriteH * 4 + 2

function drawArrows()

    circ(circleCentreX, circleTopCentreY, circleRadius)
    circ(circleCentreX, circleMidCentreY, circleRadius)
    circ(circleCentreX, circleBottomCentreY, circleRadius)

    for q = 1, 3 do
        for z = 1, maxZ do
            for visible_arrow in all(visibleArrowQueue[q]) do

                if z ~= visible_arrow.z then
                    goto continueInnerArrowLoop
                end

                pal()

                if visible_arrow.newColor ~= nil then
                    pal(6, visible_arrow.newColor)
                end

                spr(visible_arrow.sprite, visible_arrow.x, visible_arrow.y, visible_arrow.w, visible_arrow.h,
                        visible_arrow.flip_x, visible_arrow.flip_y)

                pal()

                :: continueInnerArrowLoop ::
            end
        end
    end

    --print(stat(1), 0, 0)
    print(frame, 100, 0)
end

function logtmparrows()
    local logFileName = 'pony.log'
    printh("tmpArrowQueue: ", logFileName)

    for q = 1, 3 do
        for i, arrow in ipairs(tmpArrowQueue[q]) do
            --if q == 1 and i == 1 then
                printh(tostring(i) .. ": " .. tprint(arrow, 2), logFileName)
            --end
        end
    end
end

function logvisiblearrows()
    local logFileName = 'pony.log'
    printh("visibleArrowQueue: ", logFileName)

    for q = 1, 3 do
        for i, visibleArrow in ipairs(visibleArrowQueue[q]) do
            --if q == 1 and i == 1 then
                printh('[' .. tostring(q) .. '][' .. tostring(i) .. "]: " .. tprint(visibleArrow) .. ' '
                        .. tostring(visibleArrow.newColor), logFileName)
            --end
        end
    end
end

function logarrows()
    local logFileName = 'pony.log'
    printh("arrowQueue: ", logFileName)

    for q = 1, 3 do
        for i, arrow in ipairs(arrowQueue[q]) do
            --if q == 2 and i == 1 then
                printh('[' .. tostring(q) .. '][' .. tostring(i) .. "]: " .. tprint(arrow), logFileName)
            --end
        end
    end
end

function updateArrows()
    local visibleScheduledForDeletion = {}
    visibleScheduledForDeletion[1] = {}
    visibleScheduledForDeletion[2] = {}
    visibleScheduledForDeletion[3] = {}

    local inQueueScheduledForDeletion = {}
    inQueueScheduledForDeletion[1] = {}
    inQueueScheduledForDeletion[2] = {}
    inQueueScheduledForDeletion[3] = {}

    local currentArrowMinAcceptableX = 0;
    local currentArrowMaxAcceptableX = 0;

    if currentLevelDuration >= levelDuration then
        gameState = GAME_END_SCREEN_STATE
    end

    currentLevelDuration += 1

    for q = 1, 3 do
        currentArrow[q] = nil

        for arrow in all(arrowQueue[q]) do
            arrow.timestamp = arrow.timestamp - 1

            if arrow.timestamp <= 0 then
                add(visibleArrowQueue[q], deepCopy(arrow))
                add(inQueueScheduledForDeletion[q], arrow)
            end
        end

        for deletedArrow in all(inQueueScheduledForDeletion[q]) do
            del(arrowQueue[q], deletedArrow)
        end
        inQueueScheduledForDeletion[q] = {}

        for visibleArrow in all(visibleArrowQueue[q]) do
            visibleArrow.x = visibleArrow.x - arrowSpeed

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

                    if not currentArrow[q].hasBeenHit then
                        currentArrow[q].newColor = 7
                    end
                end
            end

            if visibleArrow.x <= currentArrowMinAcceptableX and visibleArrow.hasBeenHit == false then
                visibleArrow.newColor = 8
            end

            if visibleArrow.x < visibleArrow.w * -8 then
                add(visibleScheduledForDeletion[q], visibleArrow)
            end
        end
    end

    for q = 1, 3 do
        for deletedArrow in all(visibleScheduledForDeletion[q]) do
            del(visibleArrowQueue[q], deletedArrow)
        end
    end

    --logvisiblearrows()
end
