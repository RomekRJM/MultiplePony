arrow = sprite:new {
    nextElementPadX = 32,
    associatedAction = 1,
    actioned = false,
    z = 1,
}

maxZ = 2

leftArrow = arrow:new { z = 2, }
rightArrow = arrow:new { flip_x = true, associatedAction = 2, }
topArrow = arrow:new { sprite = 2, associatedAction = 4, }
bottomArrow = arrow:new { sprite = 2, flip_y = true, associatedAction = 8, }
zArrow = arrow:new { z = 2, sprite = 4, associatedAction = 16, }
xArrow = arrow:new { z = 2, sprite = 6, associatedAction = 32, }

leftHalfArrow = arrow:new {
    sprite = 0, w = 1, z = 1, nextElementPadX = 8, firstElementPadX = 8,
    parent = leftArrow, parentBeforeRepeatSequence = false
}
rightHalfArrow = arrow:new {
    sprite = 0, flip_x = true, associatedAction = 2, w = 1, nextElementPadX = 8, firstElementPadX = 8,
    parent = rightArrow, parentBeforeRepeatSequence = true
}
topHalfArrow = arrow:new {
    sprite = 3, associatedAction = 4, w = 1, nextElementPadX = 5, firstElementPadX = 13,
    parent = topArrow, parentBeforeRepeatSequence = true
}
bottomHalfArrow = arrow:new {
    sprite = 3, flip_y = true, associatedAction = 8, w = 1, nextElementPadX = 5, firstElementPadX = 8,
    parent = bottomArrow, parentBeforeRepeatSequence = true
}
zHalfArrow = arrow:new {
    sprite = 8, z = 1, associatedAction = 16, w = 1, nextElementPadX = 6, firstElementPadX = 15,
    parent = zArrow, parentBeforeRepeatSequence = true
}
xHalfArrow = arrow:new {
    sprite = 8, z = 1, associatedAction = 32, w = 1, nextElementPadX = 6, firstElementPadX = 8,
    parent = xArrow, parentBeforeRepeatSequence = true
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

function restartArrows()
    arrowQueueIndex = 1
    arrowUpdateBatchLen = 10
    arrowSpeed = 1

    arrowQueue = {}
    arrowQueueLen = 32
    visibleArrowQueue = {}
    visibleArrowQueueMaxLen = 10

    sequence = {
         topHalfArrow
    }

    halfArrowRepeats = { 4, 6, 8, 10 }
    local i = 1

    while true do
        local j = 0
        local currentArrow = rnd(sequence)
        arrowQueue[i] = deepCopy(currentArrow)

        if currentArrow.w == 1 then
            -- half arrow
            local halfArrowRepeat = rnd(halfArrowRepeats)

            for _ = 1, halfArrowRepeat do
                j += 1
                arrowQueue[i + j] = deepCopy(currentArrow)

                if j == 1 then
                    arrowQueue[i].nextElementPadX = currentArrow.firstElementPadX
                end
            end

            arrowQueue[i + j].nextElementPadX = 32

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

        if i >= arrowQueueLen then
            break
        end
    end

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
