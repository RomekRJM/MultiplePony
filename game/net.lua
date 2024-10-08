COMMAND_INDEX = 1
-- player_id_addr = 0x5f81              -- index 1
-- player_score_delta_addr = 0x5f82     -- index 2
-- player_score_timestamp_addr = 0x5f83 -- index 3
-- command_addr = 0x5fff                -- index 127 0x5fff

BROWSER_GPIO_START_ADDR = 0x5f80
BROWSER_GPIO_END_ADDR = 0x5fff

JOIN_SERVER_CMD = 1
START_ROUND_CMD = 2
CONNECTED_TO_SERVER_RESP = 255
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

function sendBuffer(payload)
    for i = 1, #payload do
        poke(BROWSER_GPIO_START_ADDR - 1 + i, payload[i])
    end
end

function handleConnectedToServer()
    if gameState ~= SEND_JOIN_SERVER_CMD_STATE then
        return
    end

    local room = peek(BROWSER_GPIO_START_ADDR + 1)
    local playerId = peek(BROWSER_GPIO_START_ADDR + 2)
    local admin = peek(BROWSER_GPIO_START_ADDR + 3)
    local team = peek(BROWSER_GPIO_START_ADDR + 4)

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

    return COMMAND_LOOKUP[command]()

end

function sendRoundStartCommand()
    if gameState ~= RECEIVED_CONNECTED_TO_SERVER_RESP_STATE then
        return
    end

    --local payload = createEmptyPayload()
    --
    --payload[COMMAND_INDEX] = START_ROUND_CMD;
    --
    --sendBuffer(payload)
    --gameState = SEND_START_ROUND_CMD_STATE
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
