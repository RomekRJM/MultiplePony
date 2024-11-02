function drawEndScreen()

    if room.team1Score == room.team2Score then
        print('DRAW', 58, 60)
    elseif room.team1Score > room.team2Score then
        print('1 WON', 58, 60)
    else
        print('2 WON', 58, 60)
    end

end