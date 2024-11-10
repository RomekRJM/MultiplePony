defaultSpriteY = 58
defaultSpriteW = 2
defaultSpriteH = 2

sprite = {
    x = 128,
    y = defaultSpriteY,
    sprite = 0,
    w = defaultSpriteW,
    h = defaultSpriteH,
    flip_x = false,
    flip_y = false,
    visible = true,
}

function sprite:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end