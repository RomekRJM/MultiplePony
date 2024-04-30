player = {
    points = 0
}

pointsGroup = {
    {
        maxAbsX = 0,
        points = 8,
    },
    {
        maxAbsX = 2,
        points = 6,
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
botchedPoints = -1

function restartPlayer()
    player.points = 0
end

function drawPlayerPoints()
    print(player.points, 63, 0)
end

function updatePlayer()
    local buttonPressed = btn()

    if nil == currentArrow then
        printh('nil == currentArrow')
        if player.points > 0 then
            player.points -= 1
        end
        return
    end

    if currentArrow.actioned then
        return
    end

    if buttonPressed ~= nil then
        currentArrow.actioned = true
    end

    if buttonPressed ~= currentArrow.associatedAction then
        printh(buttonPressed .. ' ~= ' .. currentArrow.associatedAction)
        if player.points > 0 then
            player.points -= 1
        end
        return
    end

    if currentArrow.x > arrowMaxAcceptableX or currentArrow.x < arrowMinAcceptableX then
        printh(currentArrow.x .. 'not in [' .. arrowMinAcceptableX .. ', ' .. arrowMaxAcceptableX .. ']')
        if player.points > 0 then
            player.points -= 1
        end
        return
    end

    local absDiff = abs(arrowPerfectX - currentArrow.x)

    for pointGroup in all(pointGroups) do
        if pointGroup.maxAbsX <= absDiff then
            printh('points: ' .. pointGroup.points)
            player.points = pointGroup.points
            break
        end
    end

end