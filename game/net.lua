room_id_addr = 0x5f80 -- index 0
player_id_addr = 0x5f81 -- index 1
player_score_delta_addr = 0x5f82 -- index 2
player_score_timestamp_addr = 0x5f83 -- index 3

function establishConnection(playerName)

    -- wipe initial pins
    for pin = player_score_delta_addr, player_score_timestamp_addr do
        poke(pin)
    end

    local payload = {}
    payload[1] = 0
    local counter = 1
    for letter in all(playerName) do
        payload[counter + 1] = ord(playerName, counter)
    end

    memcpy(room_id_addr, payload, #payload)
end

function sendScore(scoreDelta, timestamp)
    poke(player_id_addr, 0) -- hard code to player 0
    poke(player_score_delta_addr, scoreDelta)
    poke(player_score_timestamp_addr, 11)
end
