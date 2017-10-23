-- flowerBig.lua

local flowerBig = {
    name = "flowerBig",
    hp = 30,
    x = -50,
    y = -50,
    w = 16,
    h = 64,
    offX = -4,
    offY = 0,
    speed = 0,
    dir = 1,
    -- flowerBig assets
    spriteSheet = "img/enemies/flowerBig.png",
    spriteGrid = nil,
    animations = {},
    curAnim = 1,
    -- flowerBig physics objects
    body = nil,
    shape = nil,
    fixture = nil,
    joint = nil,
    -- flowerBig functions
    load = nil,
    behaviour = nil,
    draw = nil,
    damage = nil,
    kill = nil,
    -- other
    timers = {},
    isDead = false,
    category = CATEGORY.ENEMY,
    layer = 2
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

flowerBig.load = function(entity)
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
  entity.body:setMass(1000)
  entity.body:setGravityScale(0)

  --[[ Damping (decelaration) ]]
  entity.body:setLinearDamping(0.05)

  --[[ Load flowerBig images/prep animations ]]
  entity.spriteGrid = anim8.newGrid(24, 64, 72, 64, 0, 0, 0)
  entity.spriteSheet = maid64.newImage(entity.spriteSheet)
  entity.animations = {
    anim8.newAnimation(entity.spriteGrid(1, 1), 0.5), -- 1 idle
    anim8.newAnimation(entity.spriteGrid("2-3", 1), {0.5, 0.1}), -- 2 spawn
  }

  entity.fixture:setMask(CATEGORY.ENEMY, CATEGORY.WALL, CATEGORY.GROUND)

  --[[ Setup flowerBig Timers ]]
  addTimer(0.0, "isHit", entity.timers)
  addTimer(0.0, "flip", entity.timers)
  addTimer(1.0, "spawn", entity.timers)
end

--[[ flip ]]
local function flip(entity)
  for i = 1, table.getn(entity.animations) do
    entity.animations[i]:flipH()
  end
  entity.dir = -entity.dir -- flip their direction as well
end

flowerBig.damage = function(a, entity)
  entity.isHit = true
  resetTimer(0.05, "isHit", entity.timers)
  entity.hp = entity.hp - 1

  if a ~= nil then
    a:destroy()
  end
end

flowerBig.kill = function(entity)
  entity.body:destroy()
end

flowerBig.behaviour = function(dt, entity)
  --[[ Update flowerBig anim ]]
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

    entity.speed = getBackgroundSpeed()
    entity.body:setLinearVelocity(0, entity.speed)

    if entity.y < 225 then
    	-- if entity.curAnim == 1 and getTimerStatus("spawn", entity.timers) == false then
				
    	if updateTimer(dt, "spawn", entity.timers) then
        addEnemy("roly", entity.x+6, entity.y+30, 1)
    		entity.curAnim = 2
	      -- entity.animations[2]:gotoFrame(1)
      	-- entity.animations[2]:resume()
    		resetTimer(5.0, "spawn", entity.timers)
    	end


    end
  end

  if updateTimer(dt, "isHit", entity.timers) then
    entity.isHit = false
  end

  --[[ Once flowerBig dies ]]
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

flowerBig.draw = function(entity)
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

return flowerBig
