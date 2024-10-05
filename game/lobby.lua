room = {
    roomId = 0,
    roundId = 0,
    adminId = 0,
    team1 = {

    },
    team2 = {

    },
}

function setPlayers(roomId, adminId, players)
    room.roomId = roomId
    room.adminId = adminId
    room.team1 = {}
    room.team2 = {}

    for p in all(players) do
        if p.team == 1 then
            add(room.team1, p)
        else
            add(room.team2, p)
        end

        if adminId == p.id then
            p.isAdmin = true
        end
    end
end

function updateLobby()
    setPlayers(0, 1, {
        player:new { id = 0, name = 'kozak1234567', team = 1, isAdmin = false, points = 0 },
        player:new { id = 1, name = 'printf', team = 1, isAdmin = true, points = 0 },
        player:new { id = 2, name = 'shin', team = 1, isAdmin = false, points = 0 },
        player:new { id = 3, name = 'dark', team = 2, isAdmin = false, points = 0 },
        player:new { id = 4, name = 'elazer', team = 2, isAdmin = false, points = 0 },
        player:new { id = 4, name = 'ggkellhazzur', team = 2, isAdmin = false, points = 0 },
    })
end

function drawLobby()
    local yStep = 16
    local y = 40

    for p in all(room.team1) do
        print(p.name, 0, y, p.isAdmin == true and 9 or 12)
        y = y + yStep
    end

    y = 40

    for p in all(room.team2) do
        print(p.name, 81, y, p.isAdmin == true and 9 or 8)
        y = y + yStep
    end

    color(7)
end