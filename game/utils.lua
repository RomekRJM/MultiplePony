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