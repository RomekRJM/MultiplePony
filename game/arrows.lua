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

levelData = "L-298,L-349,L-412,L-464,L-518,L-584,L-637,L-1595,L-1625,L-1706,L-1731,L-1812,L-1842,L-1923,L-1948,L-2949,L-2979,L-3060,L-3085,L-3166,L-3196,L-3277,L-3302,L-3380,L-3410,L-3491,L-3516,L-3597,L-3627,L-3708,L-3733,L-6027,L-6057,L-6138,L-6163,L-6245,L-6274,L-6355,L-6380,L-6462,L-6491,L-6572,L-6597,L-6679,L-6709,L-6790,L-6815,L-6894,L-6924,L-7005,L-7030,L-7112,L-7141,L-7222,L-7247"
levelData2 = "x-7-216,X-1649,X-1675,X-1760,X-1774,X-1786,X-1802,X-1866,X-1892,x-28-1973,X-3003,X-3029,X-3114,X-3128,X-3140,X-3156,X-3220,X-3247,X-3327,X-3434,X-3460,X-3545,X-3559,X-3571,X-3587,X-3651,X-3678,x-28-3758,X-6081,X-6107,X-6192,X-6206,X-6218,X-6234,X-6298,X-6325,X-6408,X-6515,X-6542,X-6626,X-6641,X-6653,X-6668,X-6732,X-6759,x-11-6850,X-6948,X-6974,X-7059,X-7073,X-7086,X-7101,X-7165,X-7192,x-28-7272,X-7448"
levelData3 = "R-1609,R-1639,R-1662,R-1691,R-1715,R-1747,R-1827,R-1856,R-1880,R-1908,R-1932,R-1965,R-2963,R-2993,R-3016,R-3045,R-3069,R-3102,R-3181,R-3211,R-3234,R-3263,R-3286,R-3319,R-3394,R-3424,R-3447,R-3476,R-3500,R-3532,R-3612,R-3641,R-3665,R-3694,R-3717,R-3750,R-6041,R-6071,R-6094,R-6123,R-6147,R-6180,R-6259,R-6289,R-6312,R-6341,R-6364,R-6397,R-6476,R-6505,R-6529,R-6558,R-6581,R-6614,R-6694,R-6723,R-6746,R-6775,R-6799,R-6831,R-6908,R-6938,R-6961,R-6990,R-7014,R-7047,R-7126,R-7156,R-7179,R-7208,R-7231,R-7264"
levelDuration = 7448

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

    for q = 1, 3 do
        for i, currentArrow in ipairs(arrowQueue[q]) do
            if i <= arrowUpdateBatchLen then
                currentArrow.x = 128
            end
        end
    end

    --logtmparrows()
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

    --logvisiblearrows()
end
