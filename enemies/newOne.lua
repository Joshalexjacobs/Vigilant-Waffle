--newOne.lua -- soon to be renamed saplings

local newOne = {
    name = "newOne",
    hp = 15,
    x = -50,
    y = -50,
    w = 6,
    h = 8,
    offX = -5,
    offY = -4,
    speed = 14,
    dir = 1,
    -- newOne assets
    spriteSheet = "img/enemies/newOne.png",
    spriteGrid = nil,
    animations = {},
    curAnim = 1,
    -- newOne physics objets
    body = nil,
    shape = nil,
    fixture = nil,
    -- newOne functions
    load = nil,
    behaviour = nil,
    draw = nil,
    -- other
    timers = {},
    isDead = false,
    category = CATEGORY.ENEMY,
    layer = 1,
}

newOne.load = function(entity)
  --[[ Physics setup ]]
  entity.body = love.physics.newBody(world, 45, 25, "dynamic") -- makes it unmoving
  entity.shape = love.physics.newRectangleShape(0, 0, entity.w, entity.h)
  entity.fixture = love.physics.newFixture(entity.body, entity.shape, 1)

  entity.fixture:setCategory(entity.category)
  entity.fixture:setUserData(entity)
  entity.body:setFixedRotation(true)

  --entity.body:setGravityScale(0)
  entity.body:setMass(1000)
  --[[ Damping (decelaration) ]]
  entity.body:setLinearDamping(0.05)

  --[[ Load newOne images/prep animations ]]
  entity.spriteGrid = anim8.newGrid(16, 16, 48, 96, 0, 0, 0)
  entity.spriteSheet = maid64.newImage(entity.spriteSheet)
  entity.animations = {
    anim8.newAnimation(entity.spriteGrid(1, 1), 0.5), -- 1 fall
    anim8.newAnimation(entity.spriteGrid("2-3", 1, 2, 1, "1-3", "2-3", "1-3", 4), 0.125, "pauseAtEnd"), -- 2 land
    anim8.newAnimation(entity.spriteGrid("1-3", 5, 1, 6), 0.1), -- 3 walk
  }

  entity.fixture:setMask(CATEGORY.ENEMY, CATEGORY.ENEMY)

  --[[ Setup newOne Timers ]]
  addTimer(0.0, "isHit", entity.timers)
  addTimer(1.5, "land", entity.timers)
  addTimer(0.0, "flip", entity.timers)
end

--[[ flip ]]
local function flip(entity)
  for i = 1, table.getn(entity.animations) do
    entity.animations[i]:flipH()
  end
  entity.dir = -entity.dir -- flip their direction as well
end

newOne.behaviour = function(dt, entity)
  --[[ Update newOne anim ]]
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
        elseif entity.curAnim == 1 and (a:getCategory() == CATEGORY.GROUND or b:getCategory() == CATEGORY.GROUND) then
          entity.curAnim = 2
        elseif (a:getCategory() == CATEGORY.WALL or b:getCategory() == CATEGORY.WALL) and updateTimer(dt, "flip", entity.timers) == true then
          flip(entity)
          resetTimer(0.20, "flip", entity.timers)
        -- elseif b:getCategory() == CATEGORY.PLAYER then
        --   local myX, myY = a:getBody():getWorldCenter() -- newOne
        --   local bodX, bodY = b:getBody():getWorldCenter() -- player
        --
        --   if bodY < myY - entity.h / 2 and bodX >= myX - entity.w / 3 and bodX <= myX + entity.w / 3 then
        --     -- print("bounce")
        --   else
        --     -- print("kill")
        --   end
        end
      end

      if entity.curAnim == 3 then
        entity.x, entity.y = entity.body:getWorldPoints(entity.shape:getPoints())
        local dx, dy = entity.body:getLinearVelocity()
        entity.body:setLinearVelocity(entity.speed * entity.dir, dy)
      end

    end

    entity.x, entity.y = entity.body:getWorldPoints(entity.shape:getPoints())
    local dx, dy = entity.body:getLinearVelocity()
  end

  if entity.curAnim == 2 then
    if updateTimer(dt, "land", entity.timers) then
      entity.curAnim = 3
    end
  end

  if updateTimer(dt, "isHit", entity.timers) then
    entity.isHit = false
  end

  --[[ Once newOne dies ]]
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

newOne.draw = function(entity)
  --[[ Draw ]]
  if entity.isHit then
    love.graphics.setColor(128, 17, 17)
  end

  if entity.body:isDestroyed() == false then
    entity.animations[entity.curAnim]:draw(entity.spriteSheet, entity.x + entity.offX, entity.y + entity.offY)
  end

  love.graphics.setColor(255, 0, 0)
  love.graphics.polygon("line", entity.body:getWorldPoints(entity.shape:getPoints()))
  love.graphics.setColor(255, 255, 255)
end

return newOne
