nameChangeInterval = 180
idsToShow = {}
progress = {}
progressLeftBoundary = 0
progressRightBoundary = 128 - progressLeftBoundary
progressWidth = progressRightBoundary - progressLeftBoundary
nameLeftBoundary = 1
nameRightBoundary = 128 - 2
nameWidth = nameRightBoundary - nameLeftBoundary
playerParticles = {}
progressXTop = 20
progressXBottom = 30
rcShift = 0
progressHeight = progressXBottom - progressXTop + 1
teamCollisionX = 0

function restartProgress()
    playerParticles = {}
    rcShift = 0
end

function updateTeamCollision()
    teamCollisionX = (progressLeftBoundary + (progressRightBoundary - progressLeftBoundary) / 2) + rcShift
end

function updateIdsToShow()
    idsToShow = {}

    for i = 1, #progress - 1 do
        local pr1 = progress[i]

        if pr1.id == myselfId then
            goto continue_ids_to_show
        end

        local canBeShown = true

        for j = i + 1, #progress do
            local pr2 = progress[j]

            if abs(pr2.x - pr1.x) < 5 then
                canBeShown = false
                break
            end
        end

        if canBeShown then
            add(idsToShow, pr1.id)
        end

        :: continue_ids_to_show ::
    end
end

function updatePlayerParticles(sourceX)
    for i = 1, 1 + rnd(3) do

        if count(playerParticles) >= 20 then
            break
        end

        add(playerParticles, {
            x = sourceX,
            y = progressXTop + rnd(progressHeight),
            speed = 0.3,
            color = 7,
            duration = 5 + rnd(20)
        })

    end

    for p in all(playerParticles) do
        p.x -= p.speed
        p.duration -= 1

        if p.duration <= 0 then
            del(playerParticles, p)
        elseif p.duration < 3 then
            p.color = 5
        elseif p.duration < 5 then
            p.color = 9
        elseif p.duration < 7 then
            p.color = 10
        end
    end
end

function updateProgress()
    local allPlayers = concatPlayers()
    local minScore = 32767
    local maxScore = -32768

    for p in all(allPlayers) do
        if p.score > maxScore then
            maxScore = p.score
        end

        if p.score < minScore then
            minScore = p.score
        end
    end

    local idx = #allPlayers
    local sourceX = -1
    progress = {}

    for p in all(allPlayers) do
        local xCoordinate = flr(0.5 + nameLeftBoundary + (p.score / maxScore) * nameWidth)

        progress[idx] = {
            x = xCoordinate,
            nameX = xCoordinate - 1,
            nameY = progressXTop - 4,
            name = p.id == myselfId and p.name or sub(p.name, 1, 3),
            showName = count(idsToShow, p.id) > 0,
            color = p.id == myselfId and (frame & 8 > 3 and 9 or 10) or (p.team == 1 and 12 or 8),
            id = p.id,
        }

        if p.id == myself.id then
            sourceX = xCoordinate
        end

        idx -= 1
    end

    if frame % nameChangeInterval == 0 then
        updateIdsToShow(progress)
    end

    updatePlayerParticles(sourceX)
    updateTeamCollision()
    --logprogress()
end

function logprogress()
    local logFileName = 'progress.log'
    printh("progress at frame: " .. frame, logFileName)

    for pr in all(progress) do
        printh(tprint(pr, 2), logFileName)
    end
end

function drawProgress()
    for pr in all(progress) do
        if pr.showName then
            for i = 1, 3 do
                if pr.name[i] then
                    print(pr.name[i], pr.nameX, pr.nameY + (i - 1) * 6, pr.color)
                end
            end
        else
            line(pr.x, progressXTop, pr.x, progressXBottom, pr.color)
        end
    end

    for pa in all(playerParticles) do
        pset(pa.x, pa.y, pa.color)
    end

    local collisionX = teamCollisionX - progressLeftBoundary

    rectfill(progressLeftBoundary, 0, collisionX, 6, 12)
    rectfill(collisionX, 0, progressRightBoundary, 6, 8)
    line(collisionX, 0, collisionX, 6, frame % 16)
end
