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

    for p in all(room.team1) do
        add(leaderBoard, p)
    end

    for p in all(room.team2) do
        add(leaderBoard, p)
    end

    sortLeaderBoard()
    leaderBoardDone = true
end

function drawEndScreen()
    pal()

    if room.team1Score == room.team2Score then
        print('draw', 58, 8)
    elseif room.team1Score > room.team2Score then
        print('blue won', 46, 8)
    else
        print('red won', 50, 8)
    end

    for i, p in ipairs(leaderBoard) do
        print(tostring(i) .. '. ' .. p.name .. ' ' .. p.score, 38, 16 + i * 8, p.id == myself.id and 11 or 6)
    end
end