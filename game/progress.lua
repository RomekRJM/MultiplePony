nameChangeInterval = 180
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
    leaderBoard = sortLeaderBoard(concatPlayers(room))

    local maxScore = leaderBoard[1].score
    local sourceX = -1
    local xCoordinate = 0
    progress = {}

    for idx, p in ipairs(leaderBoard) do
        xCoordinate = flr(0.5 + nameLeftBoundary + (p.score / maxScore) * nameWidth)

        progress[idx] = {
            x = xCoordinate - 1,
            y = progressXTop - 4,
            name = p.id == myselfId and p.name or sub(p.name, 1, 3),
            color = p.id == myselfId and (frame & 8 > 3 and 9 or 10) or (p.team == 1 and 12 or 8),
            id = p.id,
        }

        if p.id == myself.id then
            sourceX = xCoordinate
        end
    end

    local diffToLastX = 0
    for i = 1, #progress - 1 do
        if progress[i].id == myselfId then
            goto continueOuterNameMoveLoop
        end

        for j = i + 1, #progress do
            if progress[j].id == myselfId then
                goto continueInnerNameMoveLoop
            end

            diffToLastX = progress[i].x - progress[j].x
            printh("diffToLastX: " .. diffToLastX, 'progress.log')

            if diffToLastX <= 5 then
                progress[j].x -= diffToLastX
            end

            :: continueInnerNameMoveLoop ::
        end

        :: continueOuterNameMoveLoop ::
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
        if pr.id ~= myselfId then
            for i = 1, 3 do
                if pr.name[i] then
                    print(pr.name[i], pr.x, pr.y + (i - 1) * 6, pr.color)
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
