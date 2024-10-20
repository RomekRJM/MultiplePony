COMMAND_INDEX = 1
-- player_id_addr = 0x5f81              -- index 1
-- player_score_delta_addr = 0x5f82     -- index 2
-- player_score_timestamp_addr = 0x5f83 -- index 3
-- command_addr = 0x5fff                -- index 127 0x5fff

BROWSER_GPIO_START_ADDR = 0x5f80
BROWSER_GPIO_END_ADDR = 0x5fff

JOIN_SERVER_CMD = 1
START_ROUND_CMD = 2
UPDATE_READINESS_CMD = 3
SWAP_TEAM_COMMAND = 4
UPDATE_PLAYER_SCORE_CMD = 5
CONNECTED_TO_SERVER_RESP = 255
UPDATE_TEAM_NAMES_SERVER_RESP = 254
START_ROUND_CMD_SERVER_RESP = 253
GPIO_LENGTH = 128

INITIAL_STATE = 0
SEND_JOIN_SERVER_CMD_STATE = 1
RECEIVED_CONNECTED_TO_SERVER_RESP_STATE = 2
SEND_START_ROUND_CMD_STATE = 3
COUNTING_DOWN_TO_GAME_START_STATE = 4
GAME_IN_PROGRESS_STATE = 5
GAME_FINISHED_STATE = 6

gameState = INITIAL_STATE
roundStartTime = 0
lastCountdownTime = 0
secondsCountdown = 4

MODE_SEND = 0
MODE_RECEIVE = 1
socketMode = MODE_SEND
lastSendFrame = 0

function clearGPIOPins()
    for pin = BROWSER_GPIO_START_ADDR, BROWSER_GPIO_END_ADDR do
        poke(pin)
    end
end

function createEmptyPayload()
    local payload = {}
    for i = 1, GPIO_LENGTH do

        payload[i] = 0
    end

    return payload
end

function establishConnection()
    if gameState > SEND_JOIN_SERVER_CMD_STATE then
        return
    end

    local playerName = "BAR"
    local payload = createEmptyPayload()

    payload[COMMAND_INDEX] = JOIN_SERVER_CMD;

    for i = 1, #playerName do
        payload[i + 1] = ord(playerName, i)
    end

    sendBuffer(payload)
    gameState = SEND_JOIN_SERVER_CMD_STATE
end

function updateReadiness(p)
    if gameState >= COUNTING_DOWN_TO_GAME_START_STATE then
        return
    end

    local payload = createEmptyPayload()
    payload[COMMAND_INDEX] = UPDATE_READINESS_CMD
    payload[2] = p.ready and 1 or 0

    sendBuffer(payload)

end

function swapTeam(p)
    if gameState >= COUNTING_DOWN_TO_GAME_START_STATE then
        return
    end

    local payload = createEmptyPayload()
    payload[COMMAND_INDEX] = SWAP_TEAM_COMMAND
    payload[2] = p.team

    sendBuffer(payload)

end

function sendBuffer(payload)
    if frame - lastSendFrame > 10 then
        mode = MODE_SEND
    end

    if mode == MODE_RECEIVE then
        return
    end

    for i = 1, #payload do
        poke(BROWSER_GPIO_START_ADDR - 1 + i, payload[i])
    end

    mode = MODE_RECEIVE
    lastSendFrame = frame
end

function handleConnectedToServer()
    if gameState ~= SEND_JOIN_SERVER_CMD_STATE then
        return
    end

    local room = peek(BROWSER_GPIO_START_ADDR + 1)
    local playerId = peek(BROWSER_GPIO_START_ADDR + 2)
    local admin = peek(BROWSER_GPIO_START_ADDR + 3)
    local team = peek(BROWSER_GPIO_START_ADDR + 4)

    myself = player:new { id = playerId, team = team, isAdmin = admin > 0, points = 0, ready = false }
    myselfId = playerId

    gameState = RECEIVED_CONNECTED_TO_SERVER_RESP_STATE
end

function handleRoundStart()
    if gameState < SEND_START_ROUND_CMD_STATE or gameState > COUNTING_DOWN_TO_GAME_START_STATE then
        return
    end

    local room = peek(BROWSER_GPIO_START_ADDR + 1)
    local roundId = peek(BROWSER_GPIO_START_ADDR + 2)
    gameState = COUNTING_DOWN_TO_GAME_START_STATE

    if roundStartTime == 0 then
        roundStartTime = time()
        secondsCountdown = 4
        lastCountdownTime = time()
    end

    if time() - lastCountdownTime >= 1 then
        secondsCountdown = secondsCountdown - 1
        lastCountdownTime = time()
    else
        return
    end

    if secondsCountdown <= 0 then
        gameState = GAME_IN_PROGRESS_STATE
    end

end

function handleUpdateTeamNames()
    local room = peek(BROWSER_GPIO_START_ADDR + 1)
    local adminId = peek(BROWSER_GPIO_START_ADDR + 2)
    local team1Length = peek(BROWSER_GPIO_START_ADDR + 3)
    local team2Length = peek(BROWSER_GPIO_START_ADDR + 4)
    local team1Readiness = peek(BROWSER_GPIO_START_ADDR + 5)
    local team2Readiness = peek(BROWSER_GPIO_START_ADDR + 6)
    local parsedPlayers = 0
    local pid = 0
    local b = 0
    local pName = ''
    local players = {}
    local index = 7

    repeat
        local playerTeam = parsedPlayers < team1Length and 1 or 2
        local readinessSource = playerTeam == 1 and team1Readiness or team2Readiness
        pid = peek(BROWSER_GPIO_START_ADDR + index)
        pName = ''

        for _ = 1, 9 do
            index = index + 1
            b = peek(BROWSER_GPIO_START_ADDR + index)

            if b == 0 then
                break
            end

            pName = pName .. chr(b)
        end

        local playerReadyByte = playerTeam == 1 and parsedPlayers or (parsedPlayers - team1Length)
        local currentPlayer = {
            id = pid, name = pName, team = playerTeam, isAdmin = pid == adminId,
            ready = (readinessSource & (1 << playerReadyByte)) > 0
        }
        parsedPlayers = parsedPlayers + 1
        add(players, currentPlayer)

        if currentPlayer.id == myselfId then
            myself.id = myselfId
            myself.name = currentPlayer.name
            myself.team = currentPlayer.team
            myself.isAdmin = currentPlayer.isAdmin
            myself.ready = currentPlayer.ready
        end

        index = index + 1

    until (parsedPlayers >= team1Length + team2Length) or ( index > 117 )

    setPlayers(room, adminId, players)

end

COMMAND_LOOKUP = {
    [CONNECTED_TO_SERVER_RESP] = handleConnectedToServer,
    [START_ROUND_CMD_SERVER_RESP] = handleRoundStart,
    [UPDATE_TEAM_NAMES_SERVER_RESP] = handleUpdateTeamNames,
}

function handleUpdateFromServer()
    local command = peek(BROWSER_GPIO_START_ADDR)

    if command < 128 then
        return
    end

    socketMode = MODE_SEND
    return COMMAND_LOOKUP[command]()
end

function sendRoundStartCommand()
    if gameState ~= RECEIVED_CONNECTED_TO_SERVER_RESP_STATE then
        return
    end

    if countdownLauncher < 255 then
        return
    end

    local payload = createEmptyPayload()

    payload[COMMAND_INDEX] = START_ROUND_CMD;

    sendBuffer(payload)
    gameState = SEND_START_ROUND_CMD_STATE
end

function dbgbuff()
    print(tostring(peek(BROWSER_GPIO_START_ADDR + 0)))
    print(tostring(peek(BROWSER_GPIO_START_ADDR + 1)))
    print(tostring(peek(BROWSER_GPIO_START_ADDR + 2)))
    print(tostring(peek(BROWSER_GPIO_START_ADDR + 3)))
    print(tostring(peek(BROWSER_GPIO_START_ADDR + 4)))
    print(tostring(peek(BROWSER_GPIO_START_ADDR + 5)))
    print(tostring(peek(BROWSER_GPIO_START_ADDR + 6)))
    print(tostring(peek(BROWSER_GPIO_START_ADDR + 127)))
    print(tostring(peek(BROWSER_GPIO_START_ADDR + 128)))
end
