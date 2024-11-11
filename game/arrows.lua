arrow = sprite:new {
    timestamp = 32,
    associatedAction = 1,
    actioned = false,
    z = 1,
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
    sprite = 0, w = 1, z = 1, timestamp = 8, firstElementPadX = 8,
    parent = leftArrow, parentBeforeRepeatSequence = false
}
rightHalfArrow = arrow:new {
    sprite = 0, flip_x = true, associatedAction = 2, w = 1, timestamp = 8, firstElementPadX = 16,
    parent = rightArrow, parentBeforeRepeatSequence = true
}
topHalfArrow = arrow:new {
    sprite = 3, associatedAction = 4, w = 1, timestamp = 5, firstElementPadX = 13,
    parent = topArrow, parentBeforeRepeatSequence = true
}
midHalfArrow = arrow:new {
    sprite = 3, flip_y = true, associatedAction = 8, w = 1, timestamp = 5, firstElementPadX = 13,
    parent = midArrow, parentBeforeRepeatSequence = true
}
zHalfArrow = arrow:new {
    sprite = 8, associatedAction = 16, w = 1, timestamp = 5, firstElementPadX = 10,
    parent = zArrow, parentBeforeRepeatSequence = true, changeZSequentially = true
}
xHalfArrow = arrow:new {
    sprite = 8, associatedAction = 32, w = 1, timestamp = 5, firstElementPadX = 10,
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

levelData = "L-170,L-200,L-228,L-245,L-262,L-893,L-901,L-949,L-961,L-1002,L-1009,L-1058,L-1070,L-1570,L-1577,L-1625,L-1637,L-1678,L-1685,L-1734,L-1746,L-1785,L-1792,L-1840,L-1853,L-1894,L-1901,L-1949,L-1962,L-3109,L-3117,L-3165,L-3177,L-3218,L-3225,L-3273,L-3286,L-3326,L-3333,L-3381,L-3393,L-3434,L-3442,L-3490,L-3502,L-3539,L-3546,L-3594,L-3607,L-3648,L-3655,L-3703,L-3716"
levelData2 = "X-185,X-211,X-237,X-920,X-927,X-1029,X-1036,X-1596,X-1603,X-1705,X-1712,X-1812,X-1819,X-1920,X-1927,X-3136,X-3143,X-3245,X-3252,X-3352,X-3359,X-3461,X-3468,X-3566,X-3573,X-3675,X-3682,X-3814"
levelData3 = "R-203,R-253,R-269,R-934,R-942,R-1042,R-1050,R-1610,R-1618,R-1718,R-1726,R-1825,R-1833,R-1934,R-1942,R-3149,R-3157,R-3258,R-3266,R-3366,R-3374,R-3474,R-3482,R-3579,R-3587,R-3688,R-3696"
levelDuration = 3814

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

    for q = 1, 2 do
        for i, currentArrow in ipairs(arrowQueue[q]) do
            if i <= arrowUpdateBatchLen then
                currentArrow.x = 128
            end
        end
    end

    logtmparrows()
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
                printh('[' .. tostring(q) .. '][' .. tostring(i) .. "]: " .. tprint(visibleArrow), logFileName)
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
                end
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

    logvisiblearrows()
end
