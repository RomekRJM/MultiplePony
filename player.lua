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
        return
    end

    if currentArrow.actioned then
        return
    end

    if buttonPressed > 0 then
        currentArrow.actioned = true
    end

    if buttonPressed ~= currentArrow.associatedAction then
        return
    end

    local absDiff = abs(arrowPerfectX - currentArrow.x)

    for pointGroup in all(pointGroups) do
        if absDiff <= pointGroup.maxAbsX then
            player.points += pointGroup.points
            break
        end
    end

end