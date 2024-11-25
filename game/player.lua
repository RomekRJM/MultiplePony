player = {
    id = 0,
    name = '',
    team = 0,
    isAdmin = false,
    score = 0,
    ready = false,
}

function player:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

pointGroups = {
    {
        maxAbsX = 0,
        points = 8,
        arrowColorChange = 11,
    },
    {
        maxAbsX = 1,
        points = 6,
        arrowColorChange = 12,
    },
    {
        maxAbsX = 3,
        points = 5,
        arrowColorChange = 10,
    },
    {
        maxAbsX = 5,
        points = 4,
        arrowColorChange = 9,
    },
    {
        maxAbsX = 16,
        points = 3,
        arrowColorChange = 13,
    },
}

myself = {}
myselfId = -1

arrowMaxPoints = 8

function restartPlayer()
    myself = { score = 0 }
end

function drawTeamScores()
    print(room.team1Score .. '      ' .. room.team2Score, 48, 0)
end

function dbgScore()
    print(tprint(buttonPressed))
    for c in all(currentArrow) do
        print(tprint(c))
    end
end

function updatePlayer()
    local buttonPressed = btn()

    for q = 1, 3 do
        if nil == currentArrow[q] then
            goto continueInnerPlayerLoop
        end

        if currentArrow[q].actioned then
            goto continueInnerPlayerLoop
        end

        local buttonAndArrow = buttonPressed & currentArrow[q].associatedAction

        if buttonAndArrow > 0 then
            currentArrow[q].actioned = true
        elseif buttonAndArrow == 0 then
            goto continueInnerPlayerLoop
        end

        local absDiff = abs(arrowPerfectX - currentArrow[q].x)

        for pointGroup in all(pointGroups) do
            if absDiff <= pointGroup.maxAbsX then
                --printh(tostring(q) .. ': ' .. tostring(pointGroup.points))
                currentArrow[q].newColor = pointGroup.arrowColorChange
                currentArrow[q].hasBeenHit = true
                myself.score += pointGroup.points

                if gameMode == MODE_WEB_BROWSER then
                    sendScore(myself)
                else
                    room.team1Score = myself.score
                end

                break
            end
        end

        :: continueInnerPlayerLoop ::
    end
end