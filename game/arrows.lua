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

-- 236 - second top = 64 + 8 + 164
levelData = "L-181,L-207,L-264,L-829,L-837,L-885,L-897,L-938,L-945,L-994,L-1006,L-1506,L-1513,L-1561,L-1573,L-1614,L-1621,L-1670,L-1682,L-1721,L-1728,L-1776,L-1789,L-1830,L-1837,L-1885,L-1898,L-3045,L-3053,L-3101,L-3113,L-3154,L-3161,L-3209,L-3222,L-3262,L-3269,L-3317,L-3329,L-3370,L-3378,L-3426,L-3438,L-3475,L-3482,L-3530,L-3543,L-3584,L-3591,L-3639,L-3652"
levelData2 = "X-191,X-229,X-292,X-856,X-863,X-965,X-972,X-1532,X-1539,X-1641,X-1648,X-1748,X-1755,X-1856,X-1863,X-3072,X-3079,X-3181,X-3188,X-3288,X-3295,X-3397,X-3404,X-3502,X-3509,X-3611,X-3618,X-3750"
levelData3 = "R-200,R-278,R-978,R-986,R-1546,R-1554,R-1654,R-1662,R-1761,R-1769,R-1870,R-1878,R-3085,R-3093,R-3194,R-3202,R-3302,R-3310,R-3410,R-3418,R-3515,R-3523,R-3624,R-3632"
levelDuration = 3750

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
    --print(frame, 100, 0)
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
