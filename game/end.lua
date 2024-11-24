function drawEndScreen()

    if room.team1Score == room.team2Score then
        print('draw', 58, 60)
    elseif room.team1Score > room.team2Score then
        print('blue won', 46, 60)
    else
        print('red won', 50, 60)
    end

end