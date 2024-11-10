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

leftArrow = arrow:new { z = 2, }
rightArrow = arrow:new { flip_x = true, associatedAction = 2, }
topArrow = arrow:new { sprite = 2, associatedAction = 4, }
bottomArrow = arrow:new { sprite = 2, flip_y = true, associatedAction = 8, }
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
bottomHalfArrow = arrow:new {
    sprite = 3, flip_y = true, associatedAction = 8, w = 1, timestamp = 5, firstElementPadX = 13,
    parent = bottomArrow, parentBeforeRepeatSequence = true
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
visibleArrowQueueLen = {}
arrowQueue = {}
arrowQueueIndex = {}
currentLevelDuration = 0

levelData = "L-2884,L-2910,R-2938,R-2963,B-2980,B-3005,T-3028,T-3057,L-3083,L-3128,L-3275,L-3301,R-3329,R-3354,B-3371,B-3397,T-3419,T-3448,L-3474,L-3519,L-5317,L-5344,R-5372,R-5397,B-5414,B-5439,T-5462,T-5490,L-5517,L-5562,L-5709,L-5735,R-5763,R-5788,B-5805,B-5831,T-5853,T-5882,L-5908,L-5953,L-6093,L-6119,R-6147,R-6172,B-6189,B-6215,T-6237,T-6266,L-6292,L-6337,L-6484,L-6510,R-6539,R-6564,B-6581,B-6606,T-6629,T-6657,L-6684,L-6729,L-10860,L-10887,R-10915,R-10940,B-10957,B-10982,T-11005,T-11034,L-11060,L-11105,L-11252,L-11278,R-11306,R-11331,B-11348,B-11374,T-11396,T-11425,L-11451,L-11496,L-11639,L-11666,R-11694,R-11719,B-11735,B-11761,T-11784,T-11812,L-11839,L-11884,L-12030,L-12057,R-12085,R-12110,B-12127,B-12152,T-12175,T-12204,L-12230,L-12275,L-12408,L-12434,R-12462,R-12487,B-12504,B-12530,T-12552,T-12581,L-12607,L-12652,L-12799,L-12826,R-12854,R-12879,B-12896,B-12921,T-12944,T-12972,L-12999,L-13044,B-13398"
levelData2 = "X-3099,X-3158,Z-3180,Z-3206,Z-3228,Z-3256,X-3491,X-3549,z-3564-50,X-5533,X-5592,Z-5614,Z-5640,Z-5662,Z-5689,X-5924,X-5983,Z-5997,X-6309,X-6367,Z-6390,Z-6416,Z-6437,Z-6465,X-6700,X-6759,z-6773-48,X-11076,X-11135,Z-11157,Z-11183,Z-11205,Z-11232,X-11467,X-11526,Z-11547,X-11855,X-11914,Z-11936,Z-11962,Z-11984,Z-12011,X-12246,X-12305,z-12323-23,X-12624,X-12682,Z-12705,Z-12731,Z-12752,Z-12780,X-13015,X-13074,z-13106-65"
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

    for q = 1, 2 do
        local i = 1
        while true do
            local currentArrow = nextArrowFromParsedData(q)

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

    --logtmparrows()
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

function logtmparrows()
    local logFileName = 'pony.log'
    printh("tmpArrowQueue: ", logFileName)

    for q = 1, 2 do
        for i, arrow in pairs(tmpArrowQueue[q]) do
            printh(tostring(i) .. ": " .. tprint(arrow, 2), logFileName)
        end
    end
end

function logvisiblearrows()
    local logFileName = 'pony.log'
    printh("visibleArrowQueue: ", logFileName)

    for q = 1, 2 do
        for i, visibleArrow in pairs(visibleArrowQueue[q]) do
            printh("arrowQueueIndex: " .. tostring(arrowQueueIndex[q]), logFileName)
            printh("visibleArrowQueueLen: " .. tostring(visibleArrowQueueLen[q]), logFileName)
            printh('[' .. tostring(q) .. '][' .. tostring(i) .. "]: " .. tprint(visibleArrow), logFileName)
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

        for i, arrow in pairs(arrowQueue[q]) do
            arrow.timestamp = arrow.timestamp - arrowSpeed

            if arrow.timestamp == 0 and arrowQueueIndex[q] < arrowQueueLen[q] then
                add(visibleArrowQueue[q], deepCopy(arrowQueue[q][arrowQueueIndex[q]]))
                deli(arrowQueue[q], i)
                arrowQueueIndex[q] += 1
                visibleArrowQueueLen[q] += 1
            end
        end

        for _, visibleArrow in pairs(visibleArrowQueue[q]) do
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
