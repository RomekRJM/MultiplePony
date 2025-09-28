leaderBoard = {}
leaderBoardDone = false

function restartEnd()
    leaderBoard = {}
    leaderBoardDone = false
end

function updateEnd()
    if leaderBoardDone then
        return
    end

    leaderBoard = sortLeaderBoard(concatPlayers(room))
    leaderBoardDone = true
end

function drawEndScreen()
    pal()

    local msg = ''
    local msgCol = 10
    local isWinner = false
    local msgX = 58
    local winningTeam = 0

    if room.team1Score == room.team2Score then
        msg = 'draw'
    elseif room.team1Score > room.team2Score then
        isWinner = myself.team == 1
        msg = 'blue won, ' .. (isWinner and 'bravo!!!' or 'sorry :(')
        msgX = 38
        msgCol = isWinner and 11 or 8
        winningTeam = 1
    else
        isWinner = myself.team == 2
        msg = 'red won, ' .. (isWinner and 'bravo!!!' or 'sorry :(')
        msgX = 38
        msgCol = isWinner and 11 or 8
        winningTeam = 2
    end

    print(msg, msgX, 8, msgCol)

    for i, p in ipairs(leaderBoard) do
        local pText = tostring(i) .. '. '

        if p.id == myself.id then
            pText = pText .. '★'
        end

        pText = pText .. p.name .. ' ' .. p.score

        if p.team == winningTeam then
            pText = "\^o7ff\f" .. (winningTeam == 1 and "c" or "8") .. pText
        else
            pText = "\^o0ff\f" .. (p.team == 1 and "c" or "8") .. pText
        end

            print(pText, 38, 16 + i * 8)
        end
end