room_id_addr = 0x5f80 -- index 0
player_id_addr = 0x5f81 -- index 1
player_score_delta_addr = 0x5f82 -- index 2
player_score_timestamp_addr = 0x5f83 -- index 3

function establishConnection()
    poke(room_id_addr, 0) -- hard code to room 0
end

function sendScore(scoreDelta, timestamp)
    poke(player_id_addr, 0) -- hard code to player 0
    poke(player_score_delta_addr, scoreDelta)
    poke(player_score_timestamp_addr, timestamp)
end
