--bullets.lua

local bullet = {
  x = 10,
  y = 10,
  w = 2,
  h = 2,
  offX = -3,
  offY = -2,
  speedX = 50, -- 50
  dir = 1,
  -- basic player assets
  spriteSheet = "img/bullet.png",
  spriteGrid = nil,
  animations = {},
  curAnim = 1,
  -- player physics objects
  body = nil,
  shape = nil,
  fixture = nil,
  -- other
  timers = {},
  life = 1.0,
  category = 2, -- 2
  isDead = false
}

local bulletList = {}

function loadBullets()
  -- animations/sprites
  bullet.spriteGrid = anim8.newGrid(8, 8, 16, 32, 0, 0, 0)
  bullet.spriteSheet = maid64.newImage(bullet.spriteSheet)
  bullet.animations = {
    anim8.newAnimation(bullet.spriteGrid("1-2", 1), 0.03, "pauseAtEnd"),  -- 1 idle
    anim8.newAnimation(bullet.spriteGrid("1-2", 2, 2, 4), 0.035, "pauseAtEnd")   -- 2 dead
  }
end

function addBullet(x, y, dir)
  local newBullet = copy(bullet, newBullet)
  newBullet.x, newBullet.y, newBullet.dir = x, y, dir

  -- physics
  newBullet.body = love.physics.newBody(world, x, y, "dynamic")
  newBullet.shape = love.physics.newRectangleShape(0, 0, newBullet.w, newBullet.h)
  newBullet.fixture = love.physics.newFixture(newBullet.body, newBullet.shape, 1)

  newBullet.fixture:setCategory(newBullet.category)
  newBullet.fixture:setMask(1, 2)
  newBullet.body:setBullet(true)
  newBullet.body:setGravityScale(0)

  -- set up timers
  addTimer(newBullet.life, "life", newBullet.timers)

  table.insert(bulletList, newBullet)
end

function updateBullet(dt)
  for i, newBullet in ipairs(bulletList) do
    newBullet.animations[newBullet.curAnim]:update(dt)

    newBullet.body:applyForce(newBullet.speedX * newBullet.dir, 0)

    local dx, dy = newBullet.body:getLinearVelocity()

    if dx > newBullet.speedX and newBullet.dir == 1 then
      newBullet.body:setLinearVelocity(newBullet.speedX, dy)
    elseif dx < -newBullet.speedX and newBullet.dir == -1 then
      newBullet.body:setLinearVelocity(-newBullet.speedX, dy)
    end

    local contacts = newBullet.body:getContactList()

    for i = 1, #contacts do
      if contacts[i]:isTouching() then
        newBullet.isDead = true
        newBullet.curAnim = 2
        addTimer(0.5, "dead", newBullet.timers)
      end
    end

    if updateTimer(dt, "life", newBullet.timers) and newBullet.isDead == false then
      newBullet.isDead = true
    end

    if newBullet.isDead then
      newBullet.body:setLinearVelocity(0, 0)
    end

    if checkTimer("dead", newBullet.timers) and updateTimer(dt, "dead", newBullet.timers) then
      newBullet.body:destroy()
      table.remove(bulletList, i)
    end

  end
end

function drawBullet()
  for i, newBullet in ipairs(bulletList) do
    local x, y = newBullet.body:getWorldPoints(newBullet.shape:getPoints())
    newBullet.animations[newBullet.curAnim]:draw(newBullet.spriteSheet, x + newBullet.offX, y + newBullet.offY)
  end
end
