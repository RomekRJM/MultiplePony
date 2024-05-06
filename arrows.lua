arrow = sprite:new {
    next_element_pad_x = 32,
    associatedAction = 1,
    actioned = false,
    z = 1,
}

maxZ = 2

leftArrow = arrow:new { z = 2, }
rightArrow = arrow:new { flip_x = true, associatedAction = 2, }
topArrow = arrow:new { sprite = 2, associatedAction = 4, }
bottomArrow = arrow:new { sprite = 2, flip_y = true, associatedAction = 8, }
zArrow = arrow:new { sprite = 4, associatedAction = 16, }
xArrow = arrow:new { sprite = 6, associatedAction = 32, }

leftHalfArrow = arrow:new { w = 1, z = 1, next_element_pad_x = 8, parent = leftArrow, }
rightHalfArrow = arrow:new { sprite = 1, flip_x = true, associatedAction = 2, w = 1, next_element_pad_x = 8, parent = rightArrow, }
topHalfArrow = arrow:new { sprite = 2, associatedAction = 4, w = 1, next_element_pad_x = 8, parent = topArrow,  }
bottomHalfArrow = arrow:new { sprite = 2, flip_y = true, associatedAction = 8, w = 1, next_element_pad_x = 8, parent = bottomArrow,  }
zHalfArrow = arrow:new { sprite = 8, associatedAction = 16, w = 1, next_element_pad_x = 8, parent = zArrow,  }
xHalfArrow = arrow:new { sprite = 8, associatedAction = 32, w = 1, next_element_pad_x = 8, parent = xArrow,  }

halfArrowWidth = arrow.w * 4
arrowPerfectX = 64 - halfArrowWidth
arrowMinAcceptableX = arrowPerfectX - halfArrowWidth
arrowMaxAcceptableX = arrowPerfectX + halfArrowWidth
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
        leftArrow, rightArrow, topArrow, bottomArrow, zArrow, xArrow,
        leftHalfArrow, rightHalfArrow, topHalfArrow, bottomHalfArrow, zHalfArrow, xHalfArrow
    }

    halfArrowRepeats = { 4, 6, 8, 10 }

    for i = 1, arrowQueueLen do
        local currentArrow = rnd(sequence)
        arrowQueue[i] = deepCopy(currentArrow)

        if currentArrow.w == 1 then
            -- half arrow
            local halfArrowRepeat = rnd(halfArrowRepeats)
            local j = 0

            for _ = 1, halfArrowRepeat do
                j += 1
                local h = deepCopy(currentArrow)

                if j == halfArrowRepeat then
                    h.next_element_pad_x = 32
                end

                arrowQueue[i + j] = h
            end

            arrowQueue[i + j + 1] = deepCopy(currentArrow.parent)
            i += j + 1
        end
    end

    for i, currentArrow in pairs(arrowQueue) do
        if i <= arrowUpdateBatchLen then
            currentArrow.x = 128
        end
    end

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

            if z ~= arrow.z then
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

    for _, visibleArrow in pairs(visibleArrowQueue) do
        visibleArrow.x = visibleArrow.x - arrowSpeed
        visibleArrow.next_element_pad_x = visibleArrow.next_element_pad_x - arrowSpeed

        if visibleArrow.next_element_pad_x == 0 and arrowQueueIndex < arrowQueueLen then
            add(visibleArrowQueue, deepCopy(arrowQueue[arrowQueueIndex]))
            arrowQueueIndex = arrowQueueIndex + 1
            visibleArrowQueueLen = visibleArrowQueueLen + 1
        end

        if visibleArrow.x > arrowMinAcceptableX and visibleArrow.x < arrowMaxAcceptableX then
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
