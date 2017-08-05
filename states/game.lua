--game.lua
game = {}

--[[ Category Globals ]]
CATEGORY = {
  PLAYER = 1,
  BULLET = 2,
  WALL = 3,
  GROUND = 4,
  ENEMY = 5
}

player = require "player"
local background = require "scrollingBG"
require "bullets"
require "enemies"
require "enemyDictionary"


objects = {}
bg = {}

function game:enter()
  --let's create the ground
  objects.ground = {}
  objects.ground.body = love.physics.newBody(world, 128 / 2, 128 - 5 / 2)
  objects.ground.shape = love.physics.newRectangleShape(128 * 2, 5)
  objects.ground.fixture = love.physics.newFixture(objects.ground.body, objects.ground.shape); --attach shape to body
  objects.ground.sprite = maid64.newImage("img/platform.png")
  objects.ground.fixture:setCategory(4)

  objects.wallLeft = {}
  --objects.wallLeft.body = love.physics.newBody(world, 64 + 2.5 / 2, 64 / 2)
  --objects.wallLeft.body = love.physics.newBody(world, 82, 64 / 2)
  objects.wallLeft.body = love.physics.newBody(world, 194, 128 / 2)
  objects.wallLeft.shape = love.physics.newRectangleShape(5, 128)
  objects.wallLeft.fixture = love.physics.newFixture(objects.wallLeft.body, objects.wallLeft.shape);
  objects.wallLeft.fixture:setCategory(3)

  objects.wallRight = {}
  --objects.wallRight.body = love.physics.newBody(world, -2.5 / 2, 64 / 2)
  --objects.wallRight.body = love.physics.newBody(world, -1, 64 / 2)
  objects.wallRight.body = love.physics.newBody(world, -1, 128 / 2)
  objects.wallRight.shape = love.physics.newRectangleShape(5, 128)
  objects.wallRight.fixture = love.physics.newFixture(objects.wallRight.body, objects.wallRight.shape);
  objects.wallRight.fixture:setCategory(3)

  player.load()
  loadBullets()
  loadEnemyDictionary() -- loads a preset of every enemy, ready for instantiation
  background.load()

  -- testing
  --addEnemy("skull", 7, 0, 1)
  --addEnemy("oldOne", 25, 30, 1)
  addEnemy("oldOne", 25, 75, 1)
  --addEnemy("skull", 90, 0, -1)
end

function game:update(dt)
  world:update(dt)
  player.update(dt)
  updateBullet(dt)
  updateEnemy(dt)

  background.update(dt)
end

function game:draw()
  maid64.start()

  background.draw()

  --love.graphics.setColor(90, 85, 85) -- grey
  love.graphics.setColor(90, 17, 17)
  love.graphics.polygon("fill", objects.wallLeft.body:getWorldPoints(objects.wallLeft.shape:getPoints()))
  love.graphics.polygon("fill", objects.wallRight.body:getWorldPoints(objects.wallRight.shape:getPoints()))
  love.graphics.setColor(90, 17, 17)
  love.graphics.polygon("fill", objects.ground.body:getWorldPoints(objects.ground.shape:getPoints())) -- draw a "filled in" polygon using the ground's coordinates
  love.graphics.setColor(255, 255, 255)

  --love.graphics.draw(objects.ground.sprite, 0, 58) -- crappy platform i made

  player.draw()

  drawEnemy()

  drawBullet()


  --love.graphics.rectangle("fill", 10, 20, 2, 2)

  maid64.finish()
end
