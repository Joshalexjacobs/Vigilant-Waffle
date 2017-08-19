--skull.lua

local skull = {
    name = "skull",
    hp = 5,
    x = -50,
    y = -50,
    w = 6,
    h = 12,
    offX = -4,
    offY = -2.5,
    speed = 12,
    dir = 1,
    -- skull assets
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
    damage = nil,
    -- other
    timers = {},
    isDead = false,
    category = CATEGORY.ENEMY,
    layer = 1
}

skull.load = function(entity)
  --[[ Physics setup ]]
  entity.body = love.physics.newBody(world, 45, 25, "dynamic")
  entity.shape = love.physics.newRectangleShape(0, 0, entity.w, entity.h)
  entity.fixture = love.physics.newFixture(entity.body, entity.shape, 1)

  entity.fixture:setCategory(entity.category)
  entity.body:setFixedRotation(true)

  --[[ Damping (decelaration) ]]
  entity.body:setLinearDamping(0.05)

  --[[ Load Skull images/prep animations ]]
  entity.spriteGrid = anim8.newGrid(16, 16, 32, 16, 0, 0, 0)
  entity.spriteSheet = maid64.newImage(entity.spriteSheet)
  entity.animations = {
    anim8.newAnimation(entity.spriteGrid("1-2", 1), 0.2) -- idle/float
  }

  entity.fixture:setMask(CATEGORY.ENEMY, CATEGORY.ENEMY)

  --[[ Setup Skull Timers ]]
  addTimer(0.0, "isHit", entity.timers)
end

skull.damage = function(a, entity)
  entity.isHit = true
  resetTimer(0.05, "isHit", entity.timers)
  entity.hp = entity.hp - 1

  if a ~= nil then
    a:destroy()
  end
end

skull.behaviour = function(dt, entity)
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
        elseif b:getCategory() == CATEGORY.BULLET and b:isDestroyed() == false then
          entity.damage(b, entity)
        end
      end
    end

    entity.x, entity.y = entity.body:getWorldPoints(entity.shape:getPoints())
    local dx, dy = entity.body:getLinearVelocity()
    entity.body:setLinearVelocity(entity.speed * entity.dir, dy - 1)
  end

  if updateTimer(dt, "isHit", entity.timers) then
    entity.isHit = false
  end

  --[[ Once skull dies ]]
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

skull.draw = function(entity)

  --[[ Draw ]]
  if entity.isHit then
    love.graphics.setColor(128, 17, 17)
  end

  if entity.body:isDestroyed() == false then
    -- love.graphics.printf(entity.hp, entity.x, 0, 100) -- testing
    entity.animations[entity.curAnim]:draw(entity.spriteSheet, entity.x + entity.offX, entity.y + entity.offY)

    if DEBUG then
      love.graphics.setColor(255, 0, 0)
      love.graphics.polygon("line", entity.body:getWorldPoints(entity.shape:getPoints()))
    end
  end


  love.graphics.setColor(255, 255, 255)
end

return skull
