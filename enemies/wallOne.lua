-- wallOne.lua

local wallOne = {
    name = "wallOne",
    hp = 20,
    x = -50,
    y = -50,
    w = 16,
    h = 25,
    offX = 0,
    offY = 0,
    speed = 0,
    dir = 1,
    -- wallOne assets
    spriteSheet = "img/enemies/wallOne.png",
    spriteGrid = nil,
    animations = {},
    curAnim = 1,
    -- wallOne physics objects
    body = nil,
    shape = nil,
    fixture = nil,
    joint = nil,
    -- wallOne functions
    load = nil,
    behaviour = nil,
    draw = nil,
    damage = nil,
    kill = nil,
    -- other
    timers = {},
    isDead = false,
    category = CATEGORY.WALL,
    layer = 1,
    offsets = {
      left ={
        offX = 0,
        offY = -9,
      },
      right = {
        offX = 0,
        offY = -9,
      }
    },
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

wallOne.load = function(entity)
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
  entity.body:setMass(1000) -- questionable whether i need this or not

  entity.body:setGravityScale(0)

  --[[ Damping (decelaration) ]]
  entity.body:setLinearDamping(0.05)

  --[[ Load wallOne images/prep animations ]]
  entity.spriteGrid = anim8.newGrid(16, 32, 16, 32, 0, 0, 0)
  entity.spriteSheet = maid64.newImage(entity.spriteSheet)
  entity.animations = {
    anim8.newAnimation(entity.spriteGrid(1, 1), 0.5), -- 1 idle
  }

  entity.fixture:setMask(CATEGORY.ENEMY, CATEGORY.ENEMY)

  --[[ Setup wallOne Timers ]]
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

wallOne.damage = function(a, entity)
  entity.isHit = true
  resetTimer(0.05, "isHit", entity.timers)
  entity.hp = entity.hp - 1

  if a ~= nil then
    a:destroy()
  end
end

wallOne.kill = function(entity)
  entity.body:destroy()
end

wallOne.behaviour = function(dt, entity)
  --[[ Update wallOne anim ]]
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

  --[[ Once wallOne dies ]]
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

wallOne.draw = function(entity)
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
    end
  end

  love.graphics.setColor(255, 255, 255)
end

return wallOne
