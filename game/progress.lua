progress = {}
progressLeftBoundary = 4
progressRightBoundary = 128 - progressLeftBoundary
progressWidth = progressRightBoundary - progressLeftBoundary

function getMaxScore()
    for p in ipairs(leaderBoard) do

    end
end

function restartProgress()
end

function updateProgress()
    local allPlayers = concatPlayers()
    local minScore = 32000
    local maxScore = 0

    for p in all(allPlayers) do
        if p.score > maxScore then
            maxScore = p.score
        end

        if p.score < minScore then
            minScore = p.score
        end
    end

    local scoreGap = maxScore - minScore
    progress = {}

    for p in all(allPlayers) do
        add(progress, {
            x = flr(0.5 + progressLeftBoundary + (p.score / scoreGap) * progressWidth),
            name = p.name,
            color = p.id == myselfId and 11 or 1
        })
    end

    logprogress()
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
        line(pr.x, 20, pr.x, 30, pr.color)
    end
end
