function deepCopy(obj)
    if type(obj) ~= 'table' then
        return obj
    end

    local res = setmetatable({}, getmetatable(obj))

    for k, v in pairs(obj) do
        res[deepCopy(k)] = deepCopy(v)
    end

    return res
end

function concatPlayers()
    local tb = {}

    for e in all(room.team1) do
        add(tb, e)
    end

    for e in all(room.team2) do
        add(tb, e)
    end

    return tb
end

function split_str_part(strToSplit, divider, startPos, maxTokens)
    local tokens = {}
    local buffer = ""
    local k = 0

    for i=startPos, #strToSplit, 1 do
        k = i
        if #tokens >= maxTokens then
            break
        end

        if strToSplit[i] == divider then
            add(tokens, buffer)
            buffer = ""
        else
            buffer = buffer .. strToSplit[i]
        end
    end

    return {
        position = k,
        tokens = tokens,
    }
end

function lerp(p1, p2, stepCount)
    local v = {}
    local xStep = (p2.x - p1.x) / stepCount
    local yStep = (p2.y - p1.y) / stepCount
    local xOffset = 0
    local yOffset = 0

    for i = 1, stepCount do
        add(v, {
            x = p1.x + xOffset,
            y = p1.y + yOffset,
        })

        xOffset += xStep
        yOffset += yStep
    end

    return v
end