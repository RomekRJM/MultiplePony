nameChangeInterval = 180
idsToShow = {}
maxNamesToShow = 4
progress = {}
progressLeftBoundary = 4
progressRightBoundary = 128 - progressLeftBoundary
progressWidth = progressRightBoundary - progressLeftBoundary
playerParticles = {}
progressXTop = 20
progressXBottom = 30
progressHeight = progressXBottom - progressXTop + 1

function restartProgress()
    playerParticles = {}
    idsToShow = { }
end

function updateIdsToShow(allPlayers, maxPid)
    if #idsToShow == 0 then
        local addedIds = 1
        add(idsToShow, myselfId)

        for p in all(allPlayers) do
            if p.id ~= myselfId then
                add(idsToShow, p.id)
                addedIds += 1
            end

            if addedIds > maxNamesToShow then
                break
            end
        end
    end

    local skippedMyselfId = false

    for i = 1, #idsToShow do
        if skippedMyselfId then
           idsToShow[i] += 1
        end

        if idsToShow[i] ~= myselfId then
            idsToShow[i] = (idsToShow[i] + 1) % maxPid
        end

        if idsToShow[i] == myselfId then
            skippedMyselfId = true
            idsToShow[i] += (idsToShow[i] + 1) % maxPid
        end
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
    local maxPid = -32768

    for p in all(allPlayers) do
        if p.score > maxScore then
            maxScore = p.score
        end

        if p.score < minScore then
            minScore = p.score
        end

        if p.id > maxPid then
            maxPid = p.id
        end
    end

    if frame % nameChangeInterval == 0 then
        updateIdsToShow(allPlayers, maxPid)
    end

    local idx = #allPlayers
    local sourceX = -1
    progress = {}

    for p in all(allPlayers) do
        local xCoordinate = flr(0.5 + progressLeftBoundary + (p.score / maxScore) * progressWidth)

        progress[idx] = {
            x = xCoordinate,
            nameX = xCoordinate - 1,
            nameY = progressXTop - 4,
            name = p.id == myselfId and p.name or sub(p.name, 1, 3),
            showName = count(idsToShow, p.id) > 0,
            color = p.id == myselfId and (frame & 8 > 3 and 9 or 10) or (p.team == myself.team and 3 or 8)
        }

        if p.id == myself.id then
            sourceX = xCoordinate
        end

        idx -= 1
    end

    updatePlayerParticles(sourceX)
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
end
