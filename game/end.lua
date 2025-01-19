leaderBoard = {}
leaderBoardDone = false

function restartEnd()
    leaderBoard = {}
    leaderBoardDone = false
end

function sortLeaderBoard()
	for i=1,#leaderBoard do
		local j = i
		while j > 1 and leaderBoard[j-1].score < leaderBoard[j].score do
			leaderBoard[j], leaderBoard[j-1] = leaderBoard[j-1], leaderBoard[j]
			j = j - 1
		end
	end
end

function updateEnd()
    if leaderBoardDone then
        return
    end

    leaderBoard = concatPlayers()
    sortLeaderBoard()
    leaderBoardDone = true
end

function drawEndScreen()
    pal()

    local msg = ''
    local msgCol = 10
    local isWinner = false
    local msgX = 58

    if room.team1Score == room.team2Score then
        msg = 'draw'
    elseif room.team1Score > room.team2Score then
        isWinner = myself.team == 1
        msg = 'blue won, ' .. (isWinner and 'bravo!!!' or 'sorry :(')
        msgX = 38
        msgCol = isWinner and 11 or 8
    else
        isWinner = myself.team == 2
        msg = 'red won, ' .. (isWinner and 'bravo!!!' or 'sorry :(')
        msgX = 38
        msgCol = isWinner and 11 or 8
    end

    print(msg, msgX, 8, msgCol)

    for i, p in ipairs(leaderBoard) do
        print(tostring(i) .. '. ' .. p.name .. ' ' .. p.score, 38, 16 + i * 8, p.id == myself.id and 11 or 6)
    end
end