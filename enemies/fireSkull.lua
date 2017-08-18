-- fireSkull.lua

local fireSkull = {
    name = "fireSkull",
    hp = 1,
    x = -50,
    y = -50,
    w = 0,
    h = 0,
    offX = 0,
    offY = 0,
    speed = 0,
    dir = 1,
    -- fireSkull assets
    spriteSheet = nil -- "img/enemies/fireSkull.png",
    spriteGrid = nil,
    animations = {},
    curAnim = 1,
    -- fireSkull physics objets
    body = nil,
    shape = nil,
    fixture = nil,
    joint = nil,
    -- fireSkull functions
    load = nil,
    behaviour = nil,
    draw = nil,
    damage = nil,
    -- other
    timers = {},
    isDead = false,
    category = CATEGORY.ENEMY,
    layer = 1,
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

fireSkull.load = function(entity)
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
  -- entity.body:setMass(1000) -- questionable whether i need this or not

  --[[ Damping (decelaration) ]]
  entity.body:setLinearDamping(0.05)

  --[[ Load fireSkull images/prep animations ]]
  entity.spriteGrid = anim8.newGrid(16, 16, 48, 96, 0, 0, 0)
  entity.spriteSheet = maid64.newImage(entity.spriteSheet)
  entity.animations = {
    anim8.newAnimation(entity.spriteGrid(1, 1), 0.5), -- 1 idle
  }

  entity.fixture:setMask(CATEGORY.ENEMY, CATEGORY.ENEMY)

  --[[ Setup fireSkull Timers ]]
  addTimer(0.0, "isHit", entity.timers)
  addTimer(0.0, "flip", entity.timers)
end

--[[ flip ]]
local function flip(entity)
  for i = 1, table.getn(entity.animations) do
    entity.animations[i]:flipH()
  end
  entity.dir = -entity.dir -- flip their direction as well
end

fireSkull.damage = function(a, entity)
  entity.isHit = true
  resetTimer(0.05, "isHit", entity.timers)
  entity.hp = entity.hp - 1

  if a ~= nil then
    a:destroy()
  end
end

fireSkull.behaviour = function(dt, entity)
  --[[ Update fireSkull anim ]]
  entity.animations[entity.curAnim]:update(dt)

  if entity.body:isDestroyed() == false then
    local contacts = entity.body:getContactList()

    for i = 1, #contacts do
      if contacts[i]:isTouching() then
        b, a = contacts[i]:getFixtures()
        if a:getCategory() == CATEGORY.BULLET and a:isDestroyed() == false then
          entity.damage(a, entity)
        elseif b:getCategory() == CATEGORY.BULLET and b:isDestroyed() == false then
          entity.damage(b, entity)
        end
      end
    end

    entity.x, entity.y = entity.body:getWorldPoints(entity.shape:getPoints())
    local dx, dy = entity.body:getLinearVelocity()
  end

  if updateTimer(dt, "isHit", entity.timers) then
    entity.isHit = false
  end

  --[[ Once fireSkull dies ]]
  if entity.hp <= 0 then
    if checkTimer("playDead", entity.timers) == false then
      addTimer(0.01, "playDead", entity.timers)
      entity.body:destroy()
    end

    if updateTimer(dt, "playDead", entity.timers) then
      entity.isDead = true
    end
  end

end

fireSkull.draw = function(entity)
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

      love.graphics.setColor(0, 255, 0)
      love.graphics.polygon("line", entity.head.body:getWorldPoints(entity.head.shape:getPoints()))
    end
  end

  love.graphics.setColor(255, 255, 255)
end

return fireSkull
