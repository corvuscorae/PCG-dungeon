-- Code by Professor Graeme Devine!
-- entity.lua
-- Base Entity class for all game objects

local Entity = {}
Entity.__index = Entity

-- Constructor
function Entity:new(x, y, w, h)
    local instance = {}
    setmetatable(instance, self)
    
    -- Common properties for all entities
    instance.x = x or 0
    instance.y = y or 0
    instance.width =  w or 32
    instance.height = h or 32
    -- LEGACY:
    --instance.speed = 100
    --instance.color = {1, 1, 1}
    --instance.type = "entity"
    --instance.active = true
    --instance.id = tostring(math.random(1000000))
    
    return instance
end

-- Common methods for all entities
function Entity:update(dt)
    -- Base update logic
end

function Entity:draw()
    -- Set color and draw rectangle
    love.graphics.setColor(self.color)
    love.graphics.rectangle("fill", self.x, self.y, 
                            self.width, self.height)
    
    -- LEGACY:                        
    -- Draw entity type
    --love.graphics.setColor(0, 0, 0)
    --love.graphics.print(self.type, self.x - self.width/2 + 5, self.y - 5)
    
    -- Reset color
    love.graphics.setColor(1, 1, 1)
end

-- LEGACY: entity functionality from Prof. Devine's code 
--          keeping commented out here in case it ends up being needed later
--function Entity:move(dx, dy)
--    self.x = self.x + dx
--    self.y = self.y + dy
--end
--
--function Entity:checkCollision(other)
--    return self.x + self.width/2 > other.x - other.width/2 and
--           self.x - self.width/2 < other.x + other.width/2 and
--           self.y + self.height/2 > other.y - other.height/2 and
--           self.y - self.height/2 < other.y + other.height/2
--end
--
--function Entity:onCollision(other)
--    -- Base collision behavior
--end
--
--function Entity:getInfo()
--    return {
--        type = self.type,
--        position = {x = self.x, y = self.y},
--        size = {width = self.width, height = self.height},
--        id = self.id
--    }
--end

return Entity
