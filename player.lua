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
  draw = nil
}

player.load = function()
  -- load

  -- physics
  player.body = love.physics.newBody(world, 25, 25, "dynamic")
  player.shape = love.physics.newRectangleShape(0, 0, player.w, player.h)
  love.physics.newFixture(player.body, player.shape, 1)

  -- damping (decelaration)
  player.body:setLinearDamping(0.05)

  -- animations/sprites
  player.spriteGrid = anim8.newGrid(8, 16, 24, 48, 0, 0, 0)
  player.spriteSheet = maid64.newImage(player.spriteSheet)
  player.animations = {
    anim8.newAnimation(player.spriteGrid(1, 1), 0.5), -- 1 idle
    anim8.newAnimation(player.spriteGrid("1-3", "2-3"), 0.15), -- 2 walk
  }
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

  -- TEMP MOVEMENT CODE
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

  local dx, dy = player.body:getLinearVelocity()

  if dx > player.speed and player.dir == 1 then
    player.body:setLinearVelocity(player.speed, dy)
  elseif dx < -player.speed and player.dir == -1 then
    player.body:setLinearVelocity(-player.speed, dy)
  end

  if player.body:getLinearVelocity() < 15 and player.body:getLinearVelocity() > -15 then
    player.curAnim = 1
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
