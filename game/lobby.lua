room = {
    roomId = 0,
    roundId = 0,
    adminId = 0,
    team1 = {

    },
    team2 = {

    },
}

MAX_TEAM_SIZE = 5
countdownLauncher = 0

function restartLobby()
    countdownLauncher = 0
end

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

        if myself.id == p.id then
            myself = p
        end
    end
end

function updateLobby()
    if btn(⬅️) and #room.team1 < MAX_TEAM_SIZE then
        myself.team = 1
        swapTeam(myself)
    end

    if btn(➡️) and #room.team2 < MAX_TEAM_SIZE then
        myself.team = 2
        swapTeam(myself)
    end

    if btn(❎) and myself.ready then
        myself.ready = false
        updateReadiness(myself)
    end

    if myself.ready == true and myself.isAdmin then
        if btn(🅾️) then
            countdownLauncher += 3
        else
            countdownLauncher = 0
        end
    end

    if btnp(🅾️) and not myself.ready then
        myself.ready = true
        updateReadiness(myself)
    end

    --myself.name = 'myself'
    --myself.isAdmin = true
    --setPlayers(0, 5, {
    --myself,
    --player:new { id = 1, name = 'printf', team = 1, isAdmin = false, ready = true },
    --player:new { id = 2, name = 'shin', team = 1, isAdmin = false, ready = false },
    --player:new { id = 3, name = 'dark', team = 1, isAdmin = false, ready = false },
    --player:new { id = 4, name = 'elazer', team = 1, isAdmin = false, ready = true },
    --player:new { id = 5, name = 'reynor', team = 2, isAdmin = false, ready = true },
    --player:new { id = 6, name = 'gumiho', team = 2, isAdmin = false, ready = false },
    --player:new { id = 7, name = 'has', team = 2, isAdmin = false, ready = true },
    --player:new { id = 8, name = 'zest', team = 2, isAdmin = false, ready = false },
    --})

    --local playersFromJS = {254, 0, 0, 1, 1, 0, 0, 0, 103, 111, 108, 100, 53, 0, 1, 97, 122, 117, 114, 101, 51, 0, 0}
    --
    --local index = 0;
    --
    --for b in all(playersFromJS) do
    --    poke(BROWSER_GPIO_START_ADDR + index, b)
    --    index = index + 1
    --end
end

function drawLobby()
    local yStep = 8
    local y = 40

    print('blue team       red team', 12, 12)

    if #room.team1 < MAX_TEAM_SIZE then
        print('⬅️', 38, 24, 7)
    end

    for p in all(room.team1) do
        local pString = buildPlayerString(p)
        print(pString, 48 - #pString * 4, y, p.id == myself.id and 11 or 12)
        y = y + yStep
    end

    if #room.team2 < MAX_TEAM_SIZE then
        print('➡️', 78, 24, 7)
    end

    y = 40

    for p in all(room.team2) do
        print(buildPlayerString(p), 76, y, p.id == myself.id and 11 or 8)
        y = y + yStep
    end

    color(7)

    print('z - ready      x - not ready', 12, 108)

    if countdownLauncher > 0 then
        rectfill(0, 115, 5 + countdownLauncher, 126, 3)
    end

    color(7)

    if myself.isAdmin and myself.ready then
        print('hold z - start round', 27, 120)
    end
end

function buildPlayerString(p)
    local s = ''

    if p.ready then
        s = s .. '♥'
    end

    if p.isAdmin then
        s = s .. '(a)'
    end

    return s .. p.name
end