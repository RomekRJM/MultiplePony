blinkInterval = 16
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
            colour = 7,
            duration = 5 + rnd(20)
        })

    end

    for p in all(playerParticles) do
        p.x -= p.speed
        p.duration -= 1

        if p.duration <= 0 then
            del(playerParticles, p)
        elseif p.duration < 3 then
            p.colour = 5
        elseif p.duration < 5 then
            p.colour = 9
        elseif p.duration < 7 then
            p.colour = 10
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
        local xCoordinate = flr(0.5 + progressLeftBoundary + (p.score / maxScore) * progressWidth)

        progress[idx] = {
            x = xCoordinate,
            name = p.name,
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
        line(pr.x, progressXTop, pr.x, progressXBottom, pr.color)
    end

    for pa in all(playerParticles) do
        pset(pa.x, pa.y, pa.colour)
    end
end
