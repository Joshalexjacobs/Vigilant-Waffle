--pipes.lua

local pipes = {
    name = "pipes",
    hp = 35,
    x = -50,
    y = -50,
    w = 20,
    h = 20,
    offX = -5,
    offY = -7,
    speed = 10,
    dir = 1,
    -- pipes assets
    spriteSheet = "img/enemies/skullPipe.png",
    spriteGrid = nil,
    animations = {},
    curAnim = 1,
    -- pipes physics objets
    body = nil,
    shape = nil,
    fixture = nil,
    -- pipes functions
    load = nil,
    behaviour = nil,
    draw = nil,
    kill = nil,
    -- other
    timers = {},
    isDead = false,
    category = CATEGORY.ENEMY,
    layer = 2,
    skullCount = 0,
    skullMax = 5
}

pipes.load = function(entity)
  --[[ Physics setup ]]
  entity.body = love.physics.newBody(world, 45, 25, "dynamic") -- makes it unmoving
  entity.shape = love.physics.newRectangleShape(0, 0, entity.w, entity.h)
  entity.fixture = love.physics.newFixture(entity.body, entity.shape, 1)

  entity.fixture:setCategory(entity.category)
  entity.fixture:setUserData(entity)
  entity.body:setFixedRotation(true)

  entity.body:setGravityScale(0)
  entity.body:setMass(1000)

  --[[ Damping (decelaration) ]]
  entity.body:setLinearDamping(1.25)

  --[[ Load pipes images/prep animations ]]
  entity.spriteGrid = anim8.newGrid(32, 44, 96, 88, 0, 0, 0)
  entity.spriteSheet = maid64.newImage(entity.spriteSheet)
  entity.animations = {
    anim8.newAnimation(entity.spriteGrid("1-2", 1), 0.1), -- 1 idle
    anim8.newAnimation(entity.spriteGrid(3, 1, "1-2", 2), 1.0, "pauseAtEnd"), -- 2 opening mouth
    anim8.newAnimation(entity.spriteGrid("2-1", 2, 3, 1, 1, 1), 0.5, "pauseAtEnd"), -- 3 closing mouth
  }

  entity.fixture:setMask(CATEGORY.ENEMY, CATEGORY.WALL, CATEGORY.DIAMETER)

  --[[ Setup pipes Timers ]]
  addTimer(0.0, "isHit", entity.timers)
  addTimer(4.0, "moveToView", entity.timers)
  addTimer(3.0, "spawn", entity.timers)
  addTimer(4.0, "moveOutOfView", entity.timers)
end

--[[ flip ]]
local function flip(entity)
  for i = 1, table.getn(entity.animations) do
    entity.animations[i]:flipH()
  end
  entity.dir = -entity.dir -- flip their direction as well
end

pipes.kill = function(entity)
  entity.body:destroy()
end

pipes.behaviour = function(dt, entity)
  --[[ Update old one anim ]]
  entity.animations[entity.curAnim]:update(dt)

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

    if updateTimer(dt, "moveToView", entity.timers) == false then
      entity.body:setLinearVelocity(entity.speed * entity.dir, 0)
    end

    if updateTimer(dt, "moveToView", entity.timers) then
      if entity.curAnim == 1 then entity.curAnim = 2 end
      if updateTimer(dt, "spawn", entity.timers) and entity.skullCount < entity.skullMax then
        addEnemy("skull", entity.x + 10, entity.y + 4, entity.dir) -- addEnemy
        resetTimer(1.75, "spawn", entity.timers)-- resetTimer
        entity.skullCount = entity.skullCount + 1
      elseif entity.skullCount >= entity.skullMax and entity.curAnim ~= 3 then
        entity.curAnim = 3
        entity.dir = - entity.dir
      end

      if entity.curAnim == 3 and updateTimer(dt, "moveOutOfView", entity.timers) == false then
        entity.body:setLinearVelocity(entity.speed * entity.dir, 0)
      elseif entity.curAnim == 3 and updateTimer(dt, "moveOutOfView", entity.timers) then
        entity.hp = 0
      end
    end
  end

  if updateTimer(dt, "isHit", entity.timers) then
    entity.isHit = false
  end

  --[[ Once pipes dies ]]
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

pipes.draw = function(entity)
  --[[ Draw ]]
  if entity.isHit then
    love.graphics.setColor(128, 17, 17)
  end

  if entity.body:isDestroyed() == false then
    entity.animations[entity.curAnim]:draw(entity.spriteSheet, entity.x + entity.offX, entity.y + entity.offY)

    if DEBUG then
      love.graphics.setColor(255, 0, 0)
      love.graphics.polygon("line", entity.body:getWorldPoints(entity.shape:getPoints()))
    end
  end

  love.graphics.setColor(255, 255, 255)
end

return pipes
