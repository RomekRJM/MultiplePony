command_index = 0                -- index 0
-- player_id_addr = 0x5f81              -- index 1
-- player_score_delta_addr = 0x5f82     -- index 2
-- player_score_timestamp_addr = 0x5f83 -- index 3
-- command_addr = 0x5fff                -- index 127 0x5fff

BROWSER_GPIO_START_ADDR = 0x5f80
BROWSER_GPIO_END_ADDR = 0x5fff

JOIN_SERVER_CMD = 255
GPIO_LENGTH = 128

function clearPins()
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
  local playerName = "BAR"
  local payload = createEmptyPayload()

  payload[command_index] = JOIN_SERVER_CMD;

  for i = 1, #playerName do
    payload[i + 2] = ord(playerName, counter)
  end

  sendBuffer(payload)
end

function sendBuffer(payload)
  clearPins()

  for i = 1, GPIO_LENGTH do
    poke(BROWSER_GPIO_START_ADDR + i, payload[i])
  end
end
