--ogre.lua

--[[
TODO:
- Design and implement ogre boss fight
]]

local ogre = {
    name = "ogre",
    hp = 10,
    x = 50,
    y = 10,
    w = 24,
    h = 24,
    offX = -12,
    offY = -12,
    speed = 150,
    dir = 1,
    -- ogre assets
    spriteSheet = "img/ogre.png",
    spriteGrid = nil,
    animations = {},
    curAnim = 1,
    hood = {
      spriteSheet = "img/ogreHood.png",
      spriteGrid = nil,
      animations = {},
      curAnim = 1,
      loadHood = function (entity)
        --[[ Load Ogre Hood images/prep animations ]]
        entity.spriteGrid = anim8.newGrid(48, 48, 48, 48, 0, 0, 0)
        entity.spriteSheet = maid64.newImage(entity.spriteSheet)

        entity.animations = {
          anim8.newAnimation(entity.spriteGrid(1, 1), 0.2) -- idle
        }
      end
    },
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
    isDead = false,
    category = CATEGORY.ENEMY,
    layer = 1,
    speedH = 5,
}

ogre.load = function(entity)
  --[[ Physics setup ]]
  entity.body = love.physics.newBody(world, 10, 0, "dynamic")
  entity.shape = love.physics.newRectangleShape(10, 0, entity.w, entity.h)
  entity.fixture = love.physics.newFixture(entity.body, entity.shape, 1)

  entity.fixture:setCategory(entity.category)
  entity.fixture:setUserData(entity)
  entity.body:setFixedRotation(true)

  entity.body:setGravityScale(0)
  entity.body:setMass(1000)

  entity.x, entity.y = entity.body:getWorldPoints(entity.shape:getPoints())

  --[[ Damping (decelaration) ]]
  entity.body:setLinearDamping(0.05)

  --[[ Load Ogre images/prep animations ]]
  entity.spriteGrid = anim8.newGrid(48, 48, 144, 480, 0, 0, 0)
  entity.spriteSheet = maid64.newImage(entity.spriteSheet)

  entity.animations = {
    anim8.newAnimation(entity.spriteGrid(3, 10), 0.2) -- idle/float
  }

  --[[ Load Ogre Hood ]]
  entity.hood.loadHood(entity.hood)

  entity.fixture:setMask(CATEGORY.ENEMY, CATEGORY.ENEMY)

  --[[ Setup Skull Timers ]]
  addTimer(0.0, "isHit", entity.timers)
end

--[[ flip ]]
local function flip(entity)
  for i = 1, table.getn(entity.animations) do
    entity.animations[i]:flipH()
  end
  entity.dir = -entity.dir -- flip their direction as well
end

ogre.behaviour = function(dt, entity)
  --[[ Update skull anim ]]
  entity.animations[entity.curAnim]:update(dt)

  --[[ Is skull shot? ]]
  if entity.body:isDestroyed() == false then
    local contacts = entity.body:getContactList()

    for i = 1, #contacts do
      if contacts[i]:isTouching() then
        b, a = contacts[i]:getFixtures()
        if a:getCategory() == CATEGORY.BULLET and a:isDestroyed() == false then
          entity.isHit = true
          resetTimer(0.05, "isHit", entity.timers)
          entity.hp = entity.hp - 1
          a:destroy()
        end
      end
    end

    entity.x, entity.y = entity.body:getWorldPoints(entity.shape:getPoints())
    -- entity.body:setLinearVelocity(entity.speedH * entity.dir, 0)
  end

  if updateTimer(dt, "isHit", entity.timers) then
    entity.isHit = false
  end

  --[[ Once Ogre dies ]]
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

ogre.draw = function(entity)

  --[[ Draw ]]
  if entity.isHit then
    love.graphics.setColor(128, 17, 17)
  end

  if entity.body:isDestroyed() == false then
    --love.graphics.printf(entity.hp, entity.x, 0, 100) -- testing
    --entity.hood.animations[entity.hood.curAnim]:draw(entity.hood.spriteSheet, entity.x + entity.offX, entity.y + entity.offY)
    entity.animations[entity.curAnim]:draw(entity.spriteSheet, entity.x + entity.offX, entity.y + entity.offY)

    if DEBUG then
      love.graphics.setColor(255, 0, 0)
      love.graphics.polygon("line", entity.body:getWorldPoints(entity.shape:getPoints()))
    end
  end


  love.graphics.setColor(255, 255, 255)
end

return ogre
