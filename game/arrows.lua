arrow = sprite:new {
    timestamp = 32,
    associatedAction = 1,
    actioned = false,
    x = 128,
    z = 1,
    newColor = nil,
    hasBeenHit = false,
}

maxZ = 11
maxArrowBufferSize = 6
generatorCntr = {}
dataStringPosition = {}

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
    sprite = 8, associatedAction = 16, w = 1, nextElementTimestampDiff = 3, firstElementTimestampDiff = 14,
    parent = zArrow, parentBeforeRepeatSequence = true, changeZSequentially = true
}
xHalfArrow = arrow:new {
    sprite = 8, associatedAction = 32, w = 1, nextElementTimestampDiff = 3, firstElementTimestampDiff = 14,
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

levelData = "L-312,L-403,L-447,L-516,L-561,L-672,L-741,L-786,L-853,L-967,L-1077,L-1136,L-1197,L-1257,L-1317,L-1407,L-1467,L-1527,L-1587,L-1647,L-1707,L-1855,L-1946,L-2006,L-2066,L-2126,L-2217,L-2276,L-2335,L-2397,L-2632,L-2685,L-2831,L-2876,L-3023,L-3077,L-3222,L-3267,L-3506,L-3565,L-3626,L-3686,L-3746,L-3836,L-3896,L-3957,L-4017,L-4077,L-4137,L-4284,L-4376,L-4436,L-4496,L-4556,L-4646,L-4706,L-4764,L-4826,L-5065,L-5119,L-5264,L-5309,L-5456,L-5510,L-5655,L-5700,L-5841,L-5894,L-6040,L-6085,L-6232,L-6285,L-6431,L-6476,L-6731,L-6822,L-6866,L-6934,L-6979,L-7091,L-7159,L-7204,L-7272,L-7386,L-7495,L-7554,L-7615,L-7675,L-7735,L-7825,L-7885,L-7945,L-8005,L-8065,L-8125,L-8273,L-8364,L-8424,L-8484,L-8544,L-8635,L-8694,L-8753,L-8815,L-9053,L-9112,L-9173,L-9233,L-9293,L-9383,L-9443,L-9504,L-9564,L-9624,L-9684,L-9831,L-9922,L-9982,L-10042,L-10102,L-10193,L-10252,L-10311,L-10373,L-10608,L-10662,L-10807,L-10852,L-10999,L-11053,L-11199,L-11244,L-11390,L-11444,L-11589,L-11634,L-11781,L-11835,L-11980,L-12026,L-12169,L-12222,L-12368,L-12413,L-12560,L-12614,L-12759,L-12804"
levelData2 = "X-358,X-426,X-471,X-538,X-606,X-651,X-696,X-763,X-831,X-877,X-936,X-997,X-1056,X-1347,X-1767,X-1827,X-1886,X-2097,x-21-2140,X-2456,x-20-2542,X-2729,X-2776,X-2929,X-2954,X-2976,X-3004,X-3119,X-3167,x-66-3311,X-3777,X-4196,X-4257,X-4316,X-4526,x-21-4570,X-4885,x-20-4971,X-5162,X-5209,X-5362,X-5387,X-5409,X-5437,X-5552,X-5601,X-5745,X-5937,X-5985,X-6137,X-6163,X-6185,X-6212,X-6328,X-6376,x-66-6520,X-6777,X-6844,X-6889,X-6957,X-7024,X-7069,X-7114,X-7182,X-7249,X-7296,X-7355,X-7416,X-7475,X-7765,X-8185,X-8246,X-8304,X-8515,x-21-8558,X-8874,x-20-8960,X-9324,X-9743,X-9804,X-9862,X-10073,x-21-10116,X-10432,x-20-10518,X-10705,X-10752,X-10905,X-10930,X-10952,X-10980,X-11096,X-11144,X-11294,X-11487,X-11534,X-11687,X-11712,X-11734,X-11762,X-11877,X-11925,x-26-12088,X-12266,X-12313,X-12465,X-12491,X-12513,X-12540,X-12656,X-12704,x-66-12848,X-13165"
levelData3 = "R-291,R-336,R-381,R-493,R-582,R-628,R-717,R-807,R-906,R-1027,R-1106,R-1167,R-1227,R-1287,R-1377,R-1437,R-1497,R-1557,R-1617,R-1677,R-1737,R-1797,R-1916,R-1976,R-2036,R-2186,R-2246,R-2306,R-2365,R-2426,r-7-2485,R-2657,R-2710,R-2752,R-2805,R-2847,R-2906,R-3049,R-3102,R-3144,R-3196,R-3239,R-3297,R-3535,R-3596,R-3656,R-3716,R-3807,R-3866,R-3926,R-3986,R-4047,R-4107,R-4167,R-4226,R-4346,R-4406,R-4466,R-4615,R-4676,R-4735,R-4794,R-4856,r-7-4914,R-5091,R-5144,R-5186,R-5238,R-5280,R-5339,R-5482,R-5535,R-5577,R-5629,R-5672,R-5730,R-5866,R-5919,R-5961,R-6014,R-6056,R-6115,R-6258,R-6311,R-6353,R-6405,R-6447,R-6506,R-6709,R-6754,R-6799,R-6912,R-7001,R-7047,R-7136,R-7226,R-7325,R-7446,R-7524,R-7585,R-7645,R-7705,R-7795,R-7855,R-7915,R-7975,R-8035,R-8095,R-8155,R-8215,R-8334,R-8394,R-8454,R-8604,R-8664,R-8724,R-8783,R-8844,r-7-8903,R-9082,R-9143,R-9203,R-9263,R-9354,R-9413,R-9473,R-9533,R-9594,R-9654,R-9714,R-9773,R-9892,R-9952,R-10012,R-10162,R-10222,R-10282,R-10341,R-10402,r-7-10461,R-10634,R-10687,R-10729,R-10781,R-10824,R-10882,R-11025,R-11079,R-11121,R-11172,R-11215,R-11274,R-11415,R-11469,R-11511,R-11563,R-11606,R-11664,R-11807,R-11860,R-11902,R-11954,R-11997,R-12056,R-12194,R-12247,R-12289,R-12342,R-12384,R-12443,R-12586,R-12639,R-12681,R-12733,R-12776,R-12834"
levelDuration = 13165


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

function prepareLevelFromParsedData(maxChunkSize)
    for q = 1, 3 do

        if #tmpArrowQueue[q] >= maxChunkSize then
            goto continueprepareLevelLoop
        end

        local levelSource = q == 1 and levelData or ( q == 2 and levelData2 or levelData3)

        data = split_str_part(levelSource, ",", dataStringPosition[q], maxChunkSize - #tmpArrowQueue[q])

        if data.position == 0 then
            goto continueprepareLevelLoop
        end

        dataStringPosition[q] = data.position

        for instruction in all(data.tokens) do
            local parts = split(instruction, "-")
            local element = 1
            local arrowLetter = parts[element]
            element += 1

            local currentArrow = deepCopy(symbolMapping[arrowLetter])

            if ord(arrowLetter) >= 96 and ord(arrowLetter) <= 122 then
                currentArrow.r = tonum(parts[element])
                element += 1
            end

            currentArrow.timestamp = tonum(parts[element])
            add(tmpArrowQueue[q], currentArrow)
        end

        :: continueprepareLevelLoop ::

    end
end

function nextArrowFromParsedData(qn, maxChunkSize)
    local nextArrow = nil

    if #arrowQueue[qn] >= maxChunkSize then
        return nextArrow
    end

    if tmpArrowQueue[qn][1] ~= nil then
        nextArrow = tmpArrowQueue[qn][1]
        deli(tmpArrowQueue[qn], 1)
    end

    return nextArrow
end

function generateLevelPartially()
    --logtmparrows()
    --logarrows()

    prepareLevelFromParsedData(maxArrowBufferSize)

    for q = 1, 3 do
        local i = #arrowQueue[q] + 1
        while true do
            local currentArrow = nextArrowFromParsedData(q, maxArrowBufferSize)

            if currentArrow == nil then
                break
            end

            currentArrow.y += circlePadY * (q - 1)

            local j = 0
            arrowQueue[q][i] = deepCopy(currentArrow)
            currentArrow = arrowQueue[q][i]
            currentArrow.timestamp -= frame

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
                        arrowQueue[q][k].timestamp = finalTimestamp
                        finalTimestamp += arrowQueue[q][k].nextElementTimestampDiff
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

    -- logarrows()
end

function restartArrows()
    arrowUpdateBatchLen = 10
    arrowSpeed = 1
    arrowQueue[1] = {}
    arrowQueue[2] = {}
    arrowQueue[3] = {}
    tmpArrowQueue = {}
    tmpArrowQueue[1] = {}
    tmpArrowQueue[2] = {}
    tmpArrowQueue[3] = {}
    visibleArrowQueue[1] = {}
    visibleArrowQueue[2] = {}
    visibleArrowQueue[3] = {}
    dataStringPosition[1] = 1
    dataStringPosition[2] = 1
    dataStringPosition[3] = 1
    visibleArrowQueueMaxLen = 10
    currentLevelDuration = 0
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
    circ(circleCentreX, circleTopCentreY, circleRadius, 7)
    circ(circleCentreX, circleMidCentreY, circleRadius, 7)
    circ(circleCentreX, circleBottomCentreY, circleRadius, 7)

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

                :: continueInnerArrowLoop ::
            end
        end
    end
    print(stat(0), 100, 0)
    --print(frame, 100, 0)
end

function logtmparrows()
    local logFileName = 'pony.log'
    printh("tmpArrowQueue: ", logFileName)

    for q = 1, 3 do
        for i, arrow in ipairs(tmpArrowQueue[q]) do
            --if q == 1 and i == 1 then
                printh('[' .. tostring(q) .. '][' .. tostring(i) .. "]: " .. tprint(arrow), logFileName)
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
    printh("arrowQueue at frame: " .. frame, logFileName)

    for q = 1, 3 do
        printh('arrowQueueLen[' .. tostring(q) .. '] = ' .. tostring(#arrowQueue[q]), logFileName)
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

    generateLevelPartially()

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
