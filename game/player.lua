player = {
    points = 0
}

pointGroups = {
    {
        maxAbsX = 0,
        points = 8,
    },
    {
        maxAbsX = 1,
        points = 6,
    },
    {
        maxAbsX = 3,
        points = 5,
    },
    {
        maxAbsX = 5,
        points = 4,
    },
    {
        maxAbsX = 16,
        points = 3,
    },
}

arrowMaxPoints = 8

function restartPlayer()
    player.points = 0
end

function drawPlayerPoints()
    print(player.points, 63, 0)
end

function dbgpoints()
    print(tprint(buttonPressed))
    for c in all(currentArrow) do
        print(tprint(c))
    end
end

function updatePlayer()
    local buttonPressed = btn()

    for q = 1, 2 do
        if nil == currentArrow[q] then
            return
        end

        if currentArrow[q].actioned then
            goto continueInnerPlayerLoop
        end

        if buttonPressed > 0 then
            currentArrow[q].actioned = true
        end

        --printh(tostring(currentArrow[q].associatedAction))
        --printh(tostring(currentArrow[q].actioned))
        --printh(tostring(buttonPressed) .. ' & ' .. tostring(currentArrow[q].associatedAction) .. ' = ' .. tostring(buttonPressed & currentArrow[q].associatedAction))

        if (buttonPressed & currentArrow[q].associatedAction) == 0 then
            goto continueInnerPlayerLoop
        end

        local absDiff = abs(arrowPerfectX - currentArrow[q].x)

        for pointGroup in all(pointGroups) do
            if absDiff <= pointGroup.maxAbsX then
                --printh(tostring(q) .. ': ' .. tostring(pointGroup.points))
                sendScore(pointGroup.points, frame)
                player.points += pointGroup.points
                break
            end
        end

        :: continueInnerPlayerLoop ::
    end
end