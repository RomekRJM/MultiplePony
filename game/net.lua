room_id_addr = 0x5f80 -- index 0
player_score_delta = 0x5f81 -- index 1
player_score_timestamp = 0x5f82 -- index 2

function _init()
    poke(room_id_addr, 0) -- hard code to 0
end

function sendScore(scoreDelta, timestamp)
    poke(player_score_delta, scoreDelta)
    poke(player_score_timestamp, timestamp)
end
