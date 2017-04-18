--player.lua
local player = {
  x = 25,
  y = 16,
  w = 3,
  h = 9,
  offX = -2.5,
  offY = -2,
  speed = 30,
  dir = 1, -- 1 = right, -1 = left
  -- basic player assets
  spriteSheet = "img/player2.png",
  spriteGrid = nil,
  animations = {},
  curAnim = 1,
  -- player physics objects
  body = nil,
  shape = nil,
  fixture = nil,
  -- basic player functions
  load = nil,
  update = nil,
  draw = nil,
  -- other
  timers = {},
  shootRate = 0.1,
  category = 1,
  isFalling = true,
}

player.load = function()
  -- physics
  player.body = love.physics.newBody(world, 25, 25, "dynamic")
  player.shape = love.physics.newRectangleShape(0, 0, player.w, player.h)
  player.fixture = love.physics.newFixture(player.body, player.shape, 1)

  player.fixture:setCategory(player.category)

  -- damping (decelaration)
  player.body:setLinearDamping(0.05)

  -- animations/sprites
  player.spriteGrid = anim8.newGrid(8, 16, 24, 64, 0, 0, 0)
  player.spriteSheet = maid64.newImage(player.spriteSheet)
  player.animations = {
    anim8.newAnimation(player.spriteGrid(1, 1), 0.5), -- 1 idle
    anim8.newAnimation(player.spriteGrid("1-3", "2-3"), 0.15), -- 2 walk
    anim8.newAnimation(player.spriteGrid(1, 4), 0.15), -- 3 falling
  }

  -- set up timers
  addTimer(0.0, "shoot", player.timers)
end

local function flip(player)
  for i=1, table.getn(player.animations) do
    player.animations[i]:flipH()
  end
  player.dir = -player.dir
end

player.update = function(dt)
  -- update anim
  player.animations[player.curAnim]:update(dt)

  -- movement
  if love.keyboard.isDown('a') and love.keyboard.isDown('d') == false then
    player.body:applyForce(-player.speed, 0)
    player.curAnim = 2
    if player.dir ~= -1 then
      flip(player)
    end
  elseif love.keyboard.isDown('d') and love.keyboard.isDown('a') == false then
    player.body:applyForce(player.speed, 0)
    player.curAnim = 2
    if player.dir ~= 1 then
      flip(player)
    end
  end

  if love.keyboard.isDown('m') and updateTimer(dt, "shoot", player.timers) then
    local x, y = player.body:getWorldPoints(player.shape:getPoints())
    local offD = 0
    if player.dir == 1 then offD = 5 else offD = -2 end

    addBullet(x + offD, y + 3.5, player.dir)
    resetTimer(player.shootRate, "shoot", player.timers)
  end

  local dx, dy = player.body:getLinearVelocity()

  if dx > player.speed and player.dir == 1 then
    player.body:setLinearVelocity(player.speed, dy)
  elseif dx < -player.speed and player.dir == -1 then
    player.body:setLinearVelocity(-player.speed, dy)
  end

  if player.body:getLinearVelocity() < 15 and player.body:getLinearVelocity() > -15 then
    player.curAnim = 1
  end

  if player.isFalling then
    player.curAnim = 3
  end

  local contacts = player.body:getContactList()

  for i = 1, #contacts do
    if contacts[i]:isTouching() and player.isFalling then
      local fixA, fixB = contacts[i]:getFixtures()
      if fixA:getCategory() == 4 or fixB:getCategory() == 4 then
        player.isFalling = false
        player.curAnim = 2
      end
    end
  end
end

player.draw = function()
 -- draw
 local x, y = player.body:getWorldPoints(player.shape:getPoints())
 player.animations[player.curAnim]:draw(player.spriteSheet, x + player.offX, y + player.offY)

 --love.graphics.setColor(255, 0, 0)
 --love.graphics.rectangle("line", player.x + player.offX, player.y + player.offY, player.w, player.h)
 --love.graphics.setColor(255, 255, 255)

 --love.graphics.polygon("line", player.body:getWorldPoints(player.shape:getPoints()))
end

return player
