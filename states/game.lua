--game.lua

player = require "player"
require "bullets"

game = {}

objects = {}

function game:enter()
  --let's create the ground
  objects.ground = {}
  objects.ground.body = love.physics.newBody(world, 64 / 2, 64 - 5 / 2)
  objects.ground.shape = love.physics.newRectangleShape(64, 5)
  objects.ground.fixture = love.physics.newFixture(objects.ground.body, objects.ground.shape); --attach shape to body

  objects.wallLeft = {}
  objects.wallLeft.body = love.physics.newBody(world, 64 + 2.5 / 2, 64 / 2)
  objects.wallLeft.shape = love.physics.newRectangleShape(5, 64)
  objects.wallLeft.fixture = love.physics.newFixture(objects.wallLeft.body, objects.wallLeft.shape);
  objects.wallLeft.fixture:setCategory(3)

  objects.wallRight = {}
  objects.wallRight.body = love.physics.newBody(world, -2.5 / 2, 64 / 2)
  objects.wallRight.shape = love.physics.newRectangleShape(5, 64)
  objects.wallRight.fixture = love.physics.newFixture(objects.wallRight.body, objects.wallRight.shape);
  objects.wallRight.fixture:setCategory(3)

  player.load()
  loadBullets()
end

function game:update(dt)
  world:update(dt)
  player.update(dt)
  updateBullet(dt)
end

function game:draw()
  maid64.start()

  love.graphics.setColor(128, 17, 17)
  love.graphics.polygon("fill", objects.ground.body:getWorldPoints(objects.ground.shape:getPoints())) -- draw a "filled in" polygon using the ground's coordinates
  love.graphics.polygon("fill", objects.wallLeft.body:getWorldPoints(objects.wallLeft.shape:getPoints()))
  love.graphics.polygon("fill", objects.wallRight.body:getWorldPoints(objects.wallRight.shape:getPoints()))
  love.graphics.setColor(255, 255, 255)

  player.draw()

  drawBullet()

  --love.graphics.rectangle("fill", 10, 20, 2, 2)

  maid64.finish()
end
