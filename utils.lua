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
