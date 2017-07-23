--player.lua
local player = {
  x = 25,
  y = 16,
  w = 3,
  h = 9,
  offX = -2.5,
  offY = -2,
  speed = 30,
  jumpStrength = -70, -- determines height of player jump
  --dir = 1, -- 1 = right, -1 = left
  dir = {x = 1, y = 0},
  --dirY = 0,
  -- basic player assets
  spriteSheet = "img/player2Angle.png", --spriteSheet = "img/player2Jump.png",
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
  category = CATEGORY.PLAYER,
  isFalling = true,
  isJumping = false -- determines player jump until reaching the peak
}

player.load = function()
  --[[ Physics setup ]]
  player.body = love.physics.newBody(world, 45, 25, "dynamic")
  player.shape = love.physics.newRectangleShape(0, 0, player.w, player.h)
  player.fixture = love.physics.newFixture(player.body, player.shape, 1)

  player.fixture:setCategory(player.category)
  player.body:setFixedRotation(true)

  --[[ Damping (decelaration) ]]
  player.body:setLinearDamping(0.05)

  --[[ Player animations/sprites]]
  player.spriteGrid = anim8.newGrid(8, 16, 24, 96, 0, 0, 0)
  player.spriteSheet = maid64.newImage(player.spriteSheet)
  player.animations = {
    anim8.newAnimation(player.spriteGrid(1, 1), 0.5), -- 1 idle
    anim8.newAnimation(player.spriteGrid("1-3", "2-3"), 0.15), -- 2 walk
    anim8.newAnimation(player.spriteGrid(1, 4), 0.15), -- 3 falling
    anim8.newAnimation(player.spriteGrid("2-3", 4), {0.125, 0.10}, "pauseAtEnd"), -- 4 jumping
    anim8.newAnimation(player.spriteGrid("1-3", "5-6"), 0.15), -- 5 angleShot
  }

  --[[ Set up player timers ]]
  addTimer(0.0, "shoot", player.timers)
  addTimer(0.0, "jump", player.timers)
end

--[[ Player animation flip function ]]
local function flip(player)
  for i = 1, table.getn(player.animations) do
    player.animations[i]:flipH()
  end
  player.dir.x = -player.dir.x -- flip their direction as well
end

player.update = function(dt)
  --[[ Update player anim ]]
  player.animations[player.curAnim]:update(dt)

  --[[ Player left/right movement ]]
  if love.keyboard.isDown('a') and love.keyboard.isDown('d') == false then
    player.body:applyForce(-player.speed, 0)
    if player.isFalling == false then
      player.curAnim = 2
    end
    if player.dir.x ~= -1 then
      flip(player)
    end
  elseif love.keyboard.isDown('d') and love.keyboard.isDown('a') == false then
    player.body:applyForce(player.speed, 0)
    if player.isFalling == false then
      player.curAnim = 2
    end
    if player.dir.x ~= 1 then
      flip(player)
    end
  end


  -- this needs to go somewhere to make the angled shot anim work
  if love.keyboard.isDown('w') then
    player.curAnim = 5
    player.dir.y = -1
  else
    player.dir.y = 0
  end


  --[[ Player Shoot ]]
  if love.keyboard.isDown('m') and updateTimer(dt, "shoot", player.timers) then
    local x, y = player.body:getWorldPoints(player.shape:getPoints())
    local offD = 0
    if player.dir.x == 1 then offD = 5 else offD = -2 end


    if player.dir.y == 0 then
      addBullet(x + offD, y + 3.5, player.dir)
    elseif player.dir.y == -1 then
      addBullet(x + offD, y - 1, player.dir)
    end
    resetTimer(player.shootRate, "shoot", player.timers)
  end

  --[[ Get the player's current X and Y velocity ]]
  local dx, dy = player.body:getLinearVelocity()

  --[[ Player Jump ]]
  if love.keyboard.isDown('n') and player.isFalling == false then -- and player is touching the ground
    player.curAnim = 4
    player.isJumping = true
    player.isFalling = true
    player.body:applyForce(0, player.jumpStrength)
    resetTimer(0.3, "jump", player.timers)
  end

  --[[ Once player has reached the peak, begin free falling ]]
  if player.isJumping and updateTimer(dt, "jump", player.timers) then
    player.isJumping = false
  end

  --[[ Move player left/right depending on dx velocity and their direction ]]
  if dx > player.speed and player.dir.x == 1 then
    player.body:setLinearVelocity(player.speed, dy)
  elseif dx < -player.speed and player.dir.x == -1 then
    player.body:setLinearVelocity(-player.speed, dy)
  end

  --[[ Play idle animation ]]
  if player.body:getLinearVelocity() < 15 and player.body:getLinearVelocity() > -15 and player.isFalling == false then
    player.curAnim = 1
  end

  --[[ Play falling animation ]]
  if player.isFalling and player.isJumping == false then
    player.curAnim = 3
    player.animations[4]:gotoFrame(1)
    player.animations[4]:resume()
  end

  --[[ Traverse objects contacting with player ]]
  local contacts = player.body:getContactList()

  for i = 1, #contacts do
    if contacts[i]:isTouching() and player.isFalling then
      local fixA, fixB = contacts[i]:getFixtures()
      --[[ If the player is touching the ground and is falling, ground the player ]]
      if fixA:getCategory() == CATEGORY.GROUND or fixB:getCategory() == CATEGORY.GROUND then
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
