-- bigBat.lua

local bigBat = {
    name = "bigBat",
    hp = 6,
    x = -50,
    y = -50,
    w = 16,
    h = 10,
    speed = 35,
    dir = 1,
    -- bigBat assets
    spriteSheet = "img/enemies/bigBat2.png",
    spriteGrid = nil,
    animations = {},
    curAnim = 1,
    -- bigBat physics objects
    body = nil,
    shape = nil,
    fixture = nil,
    joint = nil,
    -- bigBat functions
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
    offsets = {
      left ={
        offX = -7,
        offY = -10,
      },
      right = {
        offX = -7,
        offY = -10,
      }
    },
    destination = {x = 150, y = 10},
    diameter = {
      name = "diameter",
      r = 13,
      body = nil,
      shape = nil,
      fixture = nil,
      category = CATEGORY.DIAMETER
    }
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

bigBat.load = function(entity)
  --[[ Physics setup ]]

  -- enemy body
  entity.body = love.physics.newBody(world, 45, 25, "dynamic") -- makes it unmoving
  entity.shape = love.physics.newRectangleShape(0, 0, entity.w, entity.h)
  entity.fixture = love.physics.newFixture(entity.body, entity.shape, 1)

  -- enemy diameter
  entity.diameter.body = love.physics.newBody(world, 45, 25, "dynamic") -- makes it unmoving
  entity.diameter.shape = love.physics.newCircleShape(0, 0, entity.diameter.r)
  entity.diameter.fixture = love.physics.newFixture(entity.diameter.body, entity.diameter.shape, 1)

  -- joint that connects the enemie's body and head
  local jointX, jointY = entity.body:getWorldCenter()
  entity.joint = love.physics.newWeldJoint(entity.body, entity.diameter.body, jointX, jointY + entity.h / 2, false)

  -- generate first destination
  entity.destination.x = math.random(player.body:getX() - 10, player.body:getX() + 10)
  entity.destination.y = math.random(10, 240)

  -- set categories
  entity.fixture:setCategory(entity.category)
  entity.diameter.fixture:setCategory(entity.diameter.category)

  -- set user data for fixtures
  entity.fixture:setUserData(entity)

  entity.body:setFixedRotation(true)
  entity.body:setGravityScale(0)
  entity.body:setMass(1000)

  --[[ Damping (decelaration) ]]
  entity.body:setLinearDamping(0.05)

  --[[ Load bigBat images/prep animations ]]
  entity.spriteGrid = anim8.newGrid(32, 32, 96, 64, 0, 0, 0)
  entity.spriteSheet = maid64.newImage(entity.spriteSheet)
  entity.animations = {
    --anim8.newAnimation(entity.spriteGrid(1, 1), 0.5), -- 1 idle
    anim8.newAnimation(entity.spriteGrid("1-3", 1, "1-2", 2, "2-1", 2, "3-1", 1), 0.05), -- 1 idle
  }

  entity.fixture:setMask(CATEGORY.ENEMY, CATEGORY.WALL, CATEGORY.DIAMETER, CATEGORY.PLATFORM)
  entity.diameter.fixture:setMask(CATEGORY.ENEMY, CATEGORY.WALL, CATEGORY.DIAMETER, CATEGORY.BULLET, CATEGORY.PLAYER, CATEGORY.PLATFORM)

  --[[ Setup bigBat Timers ]]
  addTimer(0.0, "isHit", entity.timers)
  addTimer(0.0, "flip", entity.timers)
end

--[[ local functions ]]
local function flip(entity)
  for i = 1, table.getn(entity.animations) do
    entity.animations[i]:flipH()
  end
  entity.dir = -entity.dir -- flip their direction as well
end

local function getFrame(x, y, w, h, entity)
  local width = entity.spriteGrid.imageWidth

  -- determine and return exact frame # (see spritesheet)
  local rowNum = width / w
  local frameX = (x / w) + 1
  local frameY = (y / h)
  
  return (frameY * rowNum) + frameX 
end

local function getOffsets(entity)
  if tonumber(entity.dir) == 1 then
    return entity.offsets.left.offX, entity.offsets.left.offY
  else
    return entity.offsets.right.offX, entity.offsets.right.offY
  end
end

local function setPoint(entity)
  local xMin = player.body:getX() - 10
  local xMax = player.body:getX() + 10

  if xMin < 5 then xMin = 5 end 
  if xMax > 400 then xMax = 400 end -- entity.destination.x = math.random(5, 400)

  entity.destination.x = math.random(xMin, xMax)
  entity.destination.y = math.random(10, 240)
end

bigBat.damage = function(a, entity)
  entity.isHit = true
  resetTimer(0.05, "isHit", entity.timers)
  entity.hp = entity.hp - 1

  if a ~= nil then
    a:destroy()
  end
end

bigBat.kill = function(entity)
  entity.body:destroy()
  entity.diameter.body:destroy()
end

bigBat.behaviour = function(dt, entity)
  --[[ Update bigBat anim ]]
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

    --[[Move bat to random point within elevator walls]]
    local testX, testY = entity.diameter.body:getWorldPoints(entity.diameter.shape:getPoint())
    if entity.diameter.shape:testPoint(testX, testY, 0, entity.destination.x, entity.destination.y) then
      setPoint(entity)
    end

    -- local tx = entity.destination.x - entity.x
    -- local ty = entity.destination.y - entity.y
    local tx = player.body:getX() - entity.x
    local ty = player.body:getY() - entity.y
    local dist = math.sqrt(tx * tx + ty * ty)

    entity.body:setLinearVelocity((tx / dist) * entity.speed, (ty / dist) * entity.speed)    
  end

  if updateTimer(dt, "isHit", entity.timers) then
    entity.isHit = false
  end

  --[[ Once bigBat dies ]]
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

bigBat.draw = function(entity)
  --[[ Draw ]]
  if entity.isHit then
    love.graphics.setColor(128, 17, 17)
  end

  if entity.body:isDestroyed() == false then
    local offX, offY = getOffsets(entity)
    entity.animations[entity.curAnim]:draw(entity.spriteSheet, entity.x + offX, entity.y + offY)

    if DEBUG then
      love.graphics.setColor(255, 0, 0)
      love.graphics.printf(entity.hp, entity.x, 0, 100)
      love.graphics.polygon("line", entity.body:getWorldPoints(entity.shape:getPoints()))

      love.graphics.setColor(0, 255, 0)
      local x, y = entity.diameter.body:getWorldPoints(entity.diameter.shape:getPoint())
      love.graphics.circle("line", x, y, entity.diameter.r)

      love.graphics.setColor(0, 0, 255)
      love.graphics.points(entity.destination.x, entity.destination.y)      
    end
  end

  love.graphics.setColor(255, 255, 255)
end

return bigBat
