function tprint (tbl, indent)
    if not indent then
        indent = 0
    end
    local toprint = "{\r\n"
    indent = indent + 2

    for k, v in pairs(tbl) do
        toprint = toprint .. addIndent(indent)

        if (type(k) == "number") then
            toprint = toprint .. "[" .. k .. "] = "
        elseif (type(k) == "string") then
            toprint = toprint .. k .. "= "
        end

        if (type(v) == "number") then
            toprint = toprint .. v .. ",\r\n"
        elseif (type(v) == "string") then
            toprint = toprint .. "\"" .. v .. "\",\r\n"
        elseif (type(v) == "table") then
            toprint = toprint .. tprint(v, indent + 2) .. ",\r\n"
        else
            toprint = toprint .. "\"" .. tostring(v) .. "\",\r\n"
        end
    end
    toprint = addIndent(indent) .. toprint .. "}"
    return toprint
end

function addIndent(indent)
    local s = ''

    for i = 1, indent do
        s = s .. ' '
    end

    return s
end

function performanceInsights(f, name)
    local s1 = stat(1)
    local s2 = stat(2)

    f()

    printh(name .. ',' .. frame .. ',' .. stat(1) - s1 .. ',' .. stat(2) - s2)
end