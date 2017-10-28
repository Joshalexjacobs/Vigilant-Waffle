-- roly.lua


local roly = {
    name = "roly",
    hp = 10,
    x = -50,
    y = -50,
    w = 12,
    h = 12,
    offX = -10,
    offY = -10,
    maxSpeed = 75,
    speed = 75,
    dir = 1,
    -- roly assets
    spriteSheet = "img/enemies/roly.png",
    spriteGrid = nil,
    animations = {},
    curAnim = 1,
    -- roly physics objects
    body = nil,
    shape = nil,
    fixture = nil,
    joint = nil,
    -- roly functions
    load = nil,
    behaviour = nil,
    draw = nil,
    damage = nil,
    kill = nil,
    -- other
    timers = {},
    isDead = false,
    category = CATEGORY.ENEMY,
    layer = 2,
    -- head = {
    --   name = "head",
    --   w = 8,
    --   h = 2,
    --   body = nil,
    --   shape = nil,
    --   fixture = nil,
    --   category = CATEGORY.HEAD
    -- }
}

roly.load = function(entity)
  --[[ Physics setup ]]

  -- enemy body
  entity.body = love.physics.newBody(world, 45, 25, "dynamic") -- makes it unmoving
  entity.shape = love.physics.newRectangleShape(0, 0, entity.w, entity.h)
  entity.fixture = love.physics.newFixture(entity.body, entity.shape, 1)

  -- set categories
  entity.fixture:setCategory(entity.category)

  -- set user data for fixtures
  entity.fixture:setUserData(entity)

  entity.body:setFixedRotation(true)

  entity.body:setGravityScale(1)
  --entity.body:setMass(1000)

  entity.fixture:setRestitution(0.7)

  --[[ Damping (decelaration) ]]
  entity.body:setLinearDamping(0.05)

  --[[ Load roly images/prep animations ]]
  entity.spriteGrid = anim8.newGrid(32, 32, 96, 96, 0, 0, 0)
  entity.spriteSheet = maid64.newImage(entity.spriteSheet)
  entity.animations = {
    anim8.newAnimation(entity.spriteGrid("1-3", 1, 1, 2), 0.05), -- 1 idle
  }

  entity.fixture:setMask(CATEGORY.ENEMY, CATEGORY.PLATFORM)

  --[[ Setup roly Timers ]]
  addTimer(0.0, "isHit", entity.timers)
  addTimer(0.0, "flip", entity.timers)
  addTimer(0.0, "bounce", entity.timers)
end

--[[ flip ]]
local function flip(entity)
  for i = 1, table.getn(entity.animations) do
    entity.animations[i]:flipH()
  end
  entity.dir = -entity.dir -- flip their direction as well
end

roly.damage = function(a, entity)
  entity.isHit = true
  resetTimer(0.05, "isHit", entity.timers)
  entity.hp = entity.hp - 1

  if a ~= nil then
    a:destroy()
  end
end

roly.kill = function(entity)
  entity.body:destroy()
end

roly.behaviour = function(dt, entity)
  --[[ Update roly anim ]]
  entity.animations[entity.curAnim]:update(dt)
  updateTimer(dt, "flip", entity.timers)

  if entity.body:isDestroyed() == false then
    local contacts = entity.body:getContactList()

    for i = 1, #contacts do
      if contacts[i]:isTouching() then
        b, a = contacts[i]:getFixtures()
        if a:getCategory() == CATEGORY.BULLET and a:isDestroyed() == false then
          entity.damage(a, entity)
        elseif b:getCategory() == CATEGORY.BULLET and b:isDestroyed() == false then
          entity.damage(b, entity)
        elseif (a:getCategory() == CATEGORY.WALL or b:getCategory() == CATEGORY.WALL) and getTimerStatus("flip", entity.timers) then
          flip(entity)
          resetTimer(0.20, "flip", entity.timers)
        end
      end
    end

    if updateTimer(dt, "bounce", entity.timers) then
      entity.body:setGravityScale(1)
    end

    entity.x, entity.y = entity.body:getWorldPoints(entity.shape:getPoints())
    local dx, dy = entity.body:getLinearVelocity()

    if entity.isHit then
      entity.speed = entity.maxSpeed - 30
    else
      entity.speed = entity.maxSpeed
    end

    entity.body:setLinearVelocity(entity.speed * entity.dir, dy)
  end

  if updateTimer(dt, "isHit", entity.timers) then
    entity.isHit = false
  end

  --[[ Once roly dies ]]
  if entity.hp <= 0 then
    if checkTimer("playDead", entity.timers) == false then
      addTimer(0.01, "playDead", entity.timers)
      entity.kill(entity)
    end

    if updateTimer(dt, "playDead", entity.timers) then
      entity.isDead = true
    end
  end

end

roly.draw = function(entity)
  --[[ Draw ]]
  if entity.isHit then
    love.graphics.setColor(128, 17, 17)
  end

  if entity.body:isDestroyed() == false then
    entity.animations[entity.curAnim]:draw(entity.spriteSheet, entity.x + entity.offX, entity.y + entity.offY)

    if DEBUG then
      love.graphics.setColor(255, 0, 0)
      love.graphics.printf(entity.hp, entity.x, 0, 100)
      love.graphics.polygon("line", entity.body:getWorldPoints(entity.shape:getPoints()))
    end
  end

  love.graphics.setColor(255, 255, 255)
end

return roly
