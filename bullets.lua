--bullets.lua

--[[
THE PLAN:
- add color to white bullets see if you like it
- add multiple muzzle flasshes that will be selected by random each shot
- add multiple bullet collision anims selected by random as well
- add a bullet that shares the same colors as player (look at top of gif for reference)
]]

local bullet = {
  x = 10,
  y = 10,
  w = 5,
  h = 5,
  offX = -10, -- -3
  offY = -6, -- -2
  speedX = 500, -- 500
  dir = {x = 0, y = 0},
  -- basic player assets
  -- spriteSheet = "img/bullet2.png",
  spriteSheet = "img/newBullet4.png",
  -- spriteSheet = "img/newbullet2.png",
  spriteGrid = nil,
  animations = {},
  curAnim = 1,
  -- bullet physics objects
  body = nil,
  shape = nil,
  fixture = nil,
  -- other
  timers = {},
  life = 2.0,
  category = CATEGORY.BULLET, -- 2
  isDead = false,
  rand = 0,
  angle = 0
}

local bulletList = {}

function loadBullets()
  -- animations/sprites
  bullet.spriteGrid = anim8.newGrid(18, 16, 60, 64, 0, 0, 0)
  bullet.spriteSheet = maid64.newImage(bullet.spriteSheet)
  bullet.animations = {
    anim8.newAnimation(bullet.spriteGrid("1-3", 1, "1-2", 2), 0.03, "pauseAtEnd"),  -- 1 idle
		anim8.newAnimation(bullet.spriteGrid(3, 2, "1-3", 3, "1-2", 4), 0.05, "pauseAtEnd"),   -- 2 dead
  }
end

--[[ flip ]]
local function flip(entity)
  for i = 1, table.getn(entity.animations) do
    entity.animations[i]:flipH()
  end
end

function addBullet(x, y, dir)
  local newBullet = copy(bullet, newBullet)
  newBullet.x, newBullet.y, newBullet.dir.x, newBullet.dir.y = x, y, dir.x, dir.y
  newBullet.rand = love.math.random(-1, 1) * 0.02
  -- physics
  newBullet.body = love.physics.newBody(world, x, y, "dynamic")
  newBullet.shape = love.physics.newRectangleShape(0, 0, newBullet.w, newBullet.h)
  newBullet.fixture = love.physics.newFixture(newBullet.body, newBullet.shape, 1)

  newBullet.fixture:setCategory(newBullet.category)
  newBullet.fixture:setMask(CATEGORY.PLAYER, CATEGORY.BULLET)
  newBullet.body:setBullet(true)
  newBullet.body:setFixedRotation(true)
  newBullet.body:setGravityScale(0)

  -- set up timers
  addTimer(newBullet.life, "life", newBullet.timers)

  newBullet.fixture:setUserData(newBullet)

  if newBullet.dir.x == -1 and newBullet.dir.y == 0 then -- left
    flip(newBullet)
    newBullet.offX = -2
  elseif newBullet.dir.x == -1 and newBullet.dir.y == -1 then -- top left
    flip(newBullet)
    newBullet.angle = ( math.pi ) / 4
    newBullet.offX = 4
    newBullet.offY = -8
  elseif newBullet.dir.x == 1 and newBullet.dir.y == -1 then -- top right
    newBullet.angle = ( math.pi * 7 ) / 4
    newBullet.offX = -10
    newBullet.offY = 2
  elseif newBullet.dir.x == 0 and newBullet.dir.y == -1 then -- up
    newBullet.angle = ( math.pi * 3 ) / 2
    newBullet.offX = -6
    newBullet.offY = 10
  end
  table.insert(bulletList, newBullet)
end

function updateBullet(dt)
  for i, newBullet in ipairs(bulletList) do
    newBullet.animations[newBullet.curAnim]:update(dt)

    --newBullet.body:setLinearVelocity(newBullet.speedX * newBullet.dir, 0)
    -- newBullet.body:setLinearVelocity(newBullet.speedX * newBullet.dir.x, newBullet.speedX * newBullet.dir.y)
    newBullet.body:setLinearVelocity(newBullet.speedX * (newBullet.dir.x +newBullet.rand), newBullet.speedX * (newBullet.dir.y + newBullet.rand))

    local dx, dy = newBullet.body:getLinearVelocity()

    local contacts = newBullet.body:getContactList()

    for i = 1, #contacts do
      if contacts[i]:isTouching() then
        newBullet.isDead = true
        newBullet.curAnim = 2
        addTimer(0.5, "dead", newBullet.timers)

        if newBullet.angle == ( math.pi ) / 4 or newBullet.angle == ( math.pi * 7 ) / 4 then
          newBullet.angle = 0
          if newBullet.dir.x == -1 then
            newBullet.offX = -2
            newBullet.offY = -6
          elseif newBullet.dir.x == 1 then
            newBullet.offX = -10
            newBullet.offY = -6
          end
        end

        -- testing out getUserData/getFixtures
        --a, b = contacts[i]:getFixtures()
        --if a:getUserData().name == "skull" then
          --a:getUserData().damage(a:getUserData(), newBullet.isDead)
        --end
        --print(b:getUserData().isDead)
      end
    end

    if updateTimer(dt, "life", newBullet.timers) and newBullet.isDead == false then
      newBullet.isDead = true
      if checkTimer("dead", newBullet.timers) == false then
        addTimer(0.0, "dead", newBullet.timers)
      end
    end

    if newBullet.isDead then
      newBullet.body:setLinearVelocity(0, 0)
    end

    if checkTimer("dead", newBullet.timers) and updateTimer(dt, "dead", newBullet.timers) then
      newBullet.body:destroy()
      --newBullet.fixture:destroy()
      table.remove(bulletList, i)
    end

  end
end

function drawBullet()
  for i, newBullet in ipairs(bulletList) do
    local x, y = newBullet.body:getWorldPoints(newBullet.shape:getPoints())
    newBullet.animations[newBullet.curAnim]:draw(newBullet.spriteSheet, x + newBullet.offX, y + newBullet.offY, newBullet.angle)

    if DEBUG then
      love.graphics.setColor(255, 0, 0)
      love.graphics.polygon("line", newBullet.body:getWorldPoints(newBullet.shape:getPoints()))
    end
    love.graphics.setColor(255, 255, 255)
  end
end
