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

levelData = "L-81,L-349,L-442,L-554,L-648,L-746,L-865,L-959,L-2684,L-2737,L-2883,L-2928,L-3075,L-3129,L-3274,L-3319,L-5121,L-5175,L-5320,L-5366,L-5512,L-5566,L-5712,L-5757,L-5897,L-5950,L-6096,L-6141,L-6288,L-6342,L-6487,L-6532,L-10662,L-10716,L-10861,L-10906,L-11053,L-11107,L-11252,L-11297,L-11444,L-11497,L-11643,L-11688,L-11835,L-11889,L-12034,L-12079,L-12222,L-12276,L-12422,L-12467,L-12614,L-12667,L-12813,L-12858"
levelData2 = "x-4-202,X-290,X-380,X-2781,X-2828,X-2980,X-3006,X-3028,X-3056,X-3171,X-3219,x-14-3364,X-5218,X-5265,X-5418,X-5444,X-5466,X-5493,X-5609,X-5657,X-5801,X-5994,X-6041,X-6194,X-6219,X-6241,X-6269,X-6384,X-6432,x-14-6577,X-10759,X-10806,X-10959,X-10984,X-11006,X-11034,X-11149,X-11197,X-11347,X-11541,X-11588,X-11740,X-11766,X-11788,X-11816,X-11931,X-11979,x-6-12142,X-12319,X-12367,X-12519,X-12545,X-12567,X-12594,X-12710,X-12758,x-14-12902,X-13219"
levelData3 = "R-150,R-340,R-2709,R-2762,R-2804,R-2857,R-2899,R-2958,R-3101,R-3154,R-3196,R-3248,R-3291,R-3349,R-5147,R-5200,R-5242,R-5294,R-5337,R-5396,R-5539,R-5592,R-5634,R-5685,R-5728,R-5787,R-5922,R-5976,R-6017,R-6070,R-6112,R-6171,R-6314,R-6367,R-6409,R-6461,R-6504,R-6562,R-10687,R-10740,R-10782,R-10835,R-10877,R-10936,R-11079,R-11132,R-11174,R-11226,R-11269,R-11327,R-11469,R-11522,R-11564,R-11617,R-11659,R-11718,R-11861,R-11914,R-11956,R-12008,R-12051,R-12109,R-12248,R-12301,R-12343,R-12396,R-12438,R-12497,R-12640,R-12693,R-12735,R-12787,R-12829,R-12888"
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
