--skull.lua

local skull = {
    name = "skull",
    hp = 3,
    x = 5,
    y = 5,
    w = 6,
    h = 12,
    offX = -4,
    offY = -2.5,
    speed = 0,
    dir = 1,
    -- skill assets
    spriteSheet = "img/enemies/skull.png",
    spriteGrid = nil,
    animations = {},
    curAnim = 1,
    -- skull physics objets
    body = nil,
    shape = nil,
    fixture = nil,
    -- skull functions
    load = nil,
    behaviour = nil,
    draw = nil,
    -- other
    timers = {},
    category = 5 -- category 5 = enemies
}

skull.load = function()
  --[[ Physics setup ]]
  skull.body = love.physics.newBody(world, 45, 25, "dynamic")
  skull.shape = love.physics.newRectangleShape(0, 0, skull.w, skull.h)
  skull.fixture = love.physics.newFixture(skull.body, skull.shape, 1)

  skull.fixture:setCategory(skull.category)
  skull.body:setFixedRotation(true)

  --[[ Damping (decelaration) ]]
  skull.body:setLinearDamping(0.05)

  --[[ Load Skull images/prep animations ]]
  skull.spriteGrid = anim8.newGrid(16, 16, 32, 16, 0, 0, 0)
  skull.spriteSheet = maid64.newImage(skull.spriteSheet)
  skull.animations = {
    anim8.newAnimation(skull.spriteGrid("1-2", 1), 0.2) -- idle/float
  }
end

skull.behaviour = function(dt, entity)
  --[[ Update skull anim ]]
  entity.animations[entity.curAnim]:update(dt)
end

skull.draw = function(entity)
  --[[ Draw ]]
  local x, y = entity.body:getWorldPoints(entity.shape:getPoints())
  entity.animations[entity.curAnim]:draw(entity.spriteSheet, x + entity.offX, y + entity.offY)

  --love.graphics.setColor(255, 0, 0)
  --love.graphics.polygon("line", entity.body:getWorldPoints(entity.shape:getPoints()))
  --love.graphics.setColor(255, 255, 255)
end

return skull
