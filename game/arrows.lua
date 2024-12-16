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

levelData = "L-18,L-78,L-258,L-378,L-438,L-498,L-618,L-798,L-918,L-1218,L-1398,L-1458,L-1518,L-1818,L-1998,L-2058,L-2118,L-2238,L-2418,L-2478,L-2658,L-2718,L-2838,L-2898,L-3078,L-3138,L-3318,L-3378,L-3438,L-3798,L-3978,L-4098,L-4398,L-4578,L-4638,L-4758,L-4818,L-4938,L-5178,L-5238,L-5298,L-5478,L-5658,L-5778,L-6018,L-6078,L-6138,L-6558,L-6798,L-6978,L-7158,L-7278,L-7338,L-7398,L-7518,L-7698,L-7758,L-7878,L-7998,L-8058,L-8238,L-8478,L-8658,L-8778,L-8898,L-9258,L-9318,L-9438,L-9618,L-9798,L-9858,L-9918,L-10098,L-10278,L-10338,L-10458,L-10518,L-10758,L-10938,L-10998,L-11058,L-11178,L-11298,L-11418,L-11538,L-11598,L-12018,L-12078,L-12318,L-12438,L-12618,L-12678,L-12738,L-12978,L-13038,L-13158,L-13398,L-13458,L-13638"
levelData2 = "X-48,X-198,X-318,X-468,X-588,X-678,X-768,X-858,X-978,X-1098,X-1188,X-1278,X-1368,X-1488,X-1578,X-1638,X-1728,X-1908,X-1968,X-2208,X-2358,X-2448,X-2538,X-2688,X-2778,X-2928,X-3018,X-3108,X-3198,X-3258,X-3468,X-3528,X-3618,X-3678,X-3768,X-3858,X-3918,X-4008,X-4068,X-4158,X-4218,X-4338,X-4428,X-4518,X-4608,X-4698,X-4908,X-4968,X-5028,X-5118,X-5328,X-5418,X-5538,X-5628,X-5688,X-5748,X-5838,X-5928,X-5988,X-6048,X-6168,X-6258,X-6408,X-6498,X-6588,X-6678,X-6768,X-6858,X-6948,X-7038,X-7128,X-7218,X-7308,X-7368,X-7458,X-7548,X-7608,X-7908,X-8028,X-8178,X-8298,X-8358,X-8448,X-8598,X-8748,X-8838,X-8928,X-9018,X-9168,X-9378,X-9498,X-9588,X-9678,X-9768,X-9888,X-9978,X-10128,X-10218,X-10368,X-10488,X-10578,X-10638,X-10788,X-10848,X-10968,X-11088,X-11148,X-11268,X-11358,X-11478,X-11568,X-11688,X-11778,X-11838,X-11928,X-11988,X-12138,X-12198,X-12288,X-12498,X-12558,X-12648,X-12768,X-12888,X-12948,X-13098,X-13218,X-13278,X-13368,X-13578"
levelData3 = "R-108,R-138,R-168,R-228,R-288,R-348,R-408,R-528,R-558,R-648,R-708,R-738,R-828,R-888,R-948,R-1008,R-1038,R-1068,R-1128,R-1158,R-1248,R-1308,R-1338,R-1428,R-1548,R-1608,R-1668,R-1698,R-1758,R-1788,R-1848,R-1878,R-1938,R-2028,R-2088,R-2148,R-2178,R-2268,R-2298,R-2328,R-2388,R-2508,R-2568,R-2598,R-2628,R-2748,R-2808,R-2868,R-2958,R-2988,R-3048,R-3168,R-3228,R-3288,R-3348,R-3408,R-3498,R-3558,R-3588,R-3648,R-3708,R-3738,R-3828,R-3888,R-3948,R-4038,R-4128,R-4188,R-4248,R-4278,R-4308,R-4368,R-4458,R-4488,R-4548,R-4668,R-4728,R-4788,R-4848,R-4878,R-4998,R-5058,R-5088,R-5148,R-5208,R-5268,R-5358,R-5388,R-5448,R-5508,R-5568,R-5598,R-5718,R-5808,R-5868,R-5898,R-5958,R-6108,R-6198,R-6228,R-6288,R-6318,R-6348,R-6378,R-6438,R-6468,R-6528,R-6618,R-6648,R-6708,R-6738,R-6828,R-6888,R-6918,R-7008,R-7068,R-7098,R-7188,R-7248,R-7428,R-7488,R-7578,R-7638,R-7668,R-7728,R-7788,R-7818,R-7848,R-7938,R-7968,R-8088,R-8118,R-8148,R-8208,R-8268,R-8328,R-8388,R-8418,R-8508,R-8538,R-8568,R-8628,R-8688,R-8718,R-8808,R-8868,R-8958,R-8988,R-9048,R-9078,R-9108,R-9138,R-9198,R-9228,R-9288,R-9348,R-9408,R-9468,R-9528,R-9558,R-9648,R-9708,R-9738,R-9828,R-9948,R-10008,R-10038,R-10068,R-10158,R-10188,R-10248,R-10308,R-10398,R-10428,R-10548,R-10608,R-10668,R-10698,R-10728,R-10818,R-10878,R-10908,R-11028,R-11118,R-11208,R-11238,R-11328,R-11388,R-11448,R-11508,R-11628,R-11658,R-11718,R-11748,R-11808,R-11868,R-11898,R-11958,R-12048,R-12108,R-12168,R-12228,R-12258,R-12348,R-12378,R-12408,R-12468,R-12528,R-12588,R-12708,R-12798,R-12828,R-12858,R-12918,R-13008,R-13068,R-13128,R-13188,R-13248,R-13308,R-13338,R-13428,R-13488,R-13518,R-13548,R-13608,R-13668,R-13698"
levelDuration = 13698


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

        data = split_str_part(levelSource, ",", dataStringPosition[q], maxChunkSize)

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
            currentArrow.timestamp -= frame

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
    logtmparrows()
    logarrows()
    prepareLevelFromParsedData(maxArrowBufferSize)
    --stop()

    for q = 1, 3 do
        local i = #arrowQueue[q]
        while true do
            local currentArrow = nextArrowFromParsedData(q, maxArrowBufferSize)

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

    --print(stat(1), 0, 0)
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
    printh("arrowQueue: ", logFileName)

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
