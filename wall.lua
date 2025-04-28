-- Raven: made a wall class
-- wall.lua
-- Wall entity derived from base Entity

local Entity = require("entity")

local Wall = {}
Wall.__index = Wall
setmetatable(Wall, {__index = Entity})

function Wall:new(x, y, w, h)
    local instance = Entity:new(x, y, w, h)
    setmetatable(instance, Wall)
    
    -- Player-specific properties
    instance.type = "wall"
    instance.color = {0.3, 0.3, 0.3}  -- White
    instance.speed = 0
    
    return instance
end

function Wall:onCollision(other)
    -- Player-specific collision behavior
    -- if other.type == "player" then
    -- end
end

return Wall