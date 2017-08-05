--oldOne.lua

--[[
TODO:
- Add float
- Reset animations after newOne is spawned
- Add slow horizontal movement (pause when spawning)
]]

local oldOne = {
    name = "oldOne",
    hp = 25,
    x = 5,
    y = 5,
    w = 6,
    h = 12,
    offX = -4,
    offY = -2.5,
    speed = 8,
    dir = 1,
    -- oldOne assets
    spriteSheet = "img/enemies/oldOne.png",
    spriteGrid = nil,
    animations = {},
    curAnim = 1,
    -- oldOne physics objets
    body = nil,
    shape = nil,
    fixture = nil,
    -- oldOne functions
    load = nil,
    behaviour = nil,
    draw = nil,
    -- other
    timers = {},
    isDead = false,
    category = CATEGORY.ENEMY,
    layer = 2,
}

oldOne.load = function(entity)
  --[[ Physics setup ]]
  entity.body = love.physics.newBody(world, 45, 25, "dynamic") -- makes it unmoving
  entity.shape = love.physics.newRectangleShape(0, 0, entity.w, entity.h)
  entity.fixture = love.physics.newFixture(entity.body, entity.shape, 1)

  entity.fixture:setCategory(entity.category)
  entity.body:setFixedRotation(true)

  entity.body:setGravityScale(0)
  entity.body:setMass(1000)
  --[[ Damping (decelaration) ]]
  entity.body:setLinearDamping(0.05)

  --[[ Load oldOne images/prep animations ]]
  entity.spriteGrid = anim8.newGrid(16, 16, 48, 32, 0, 0, 0)
  entity.spriteSheet = maid64.newImage(entity.spriteSheet)
  entity.animations = {
    anim8.newAnimation(entity.spriteGrid(1, 1, "2-3", 1, 2, 1), {2.0, 0.1, 0.1, 0.1}), -- 1 idle/float
    anim8.newAnimation(entity.spriteGrid("1-2", 2), 0.5, "pauseAtEnd"), -- 2 spawn sapling !!! need to reset these animations...
    anim8.newAnimation(entity.spriteGrid("2-1", 2, 1, 1), 0.5, "pauseAtEnd"), -- 3 back to idle !!! at some point!
  }

  entity.fixture:setMask(CATEGORY.ENEMY, CATEGORY.ENEMY)

  --[[ Setup oldOne Timers ]]
  addTimer(0.0, "isHit", entity.timers)
  addTimer(1.0, "spawn", entity.timers)
  addTimer(1.0, "spawning", entity.timers)
end

oldOne.behaviour = function(dt, entity)
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
    local dx, dy = entity.body:getLinearVelocity()

    if updateTimer(dt, "spawn", entity.timers) then
      entity.curAnim = 2
      if updateTimer(dt, "spawning", entity.timers) and entity.curAnim then
        addEnemy("newOne", entity.x - entity.offX, entity.y - entity.offY, 1)
        entity.curAnim = 3
        resetTimer(7.5, "spawn", entity.timers)
        resetTimer(1.0, "spawning", entity.timers)
      end
    end

  end

  if updateTimer(dt, "isHit", entity.timers) then
    entity.isHit = false
  end

  --[[ Once oldOne dies ]]
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

oldOne.draw = function(entity)
  --[[ Draw ]]
  if entity.isHit then
    love.graphics.setColor(128, 17, 17)
  end

  if entity.body:isDestroyed() == false then
    entity.animations[entity.curAnim]:draw(entity.spriteSheet, entity.x + entity.offX, entity.y + entity.offY)
  end

  --love.graphics.setColor(255, 0, 0)
  --love.graphics.polygon("line", entity.body:getWorldPoints(entity.shape:getPoints()))
  love.graphics.setColor(255, 255, 255)
end

return oldOne
