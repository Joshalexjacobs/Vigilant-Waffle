--game.lua
game = {}

--[[ Category Globals ]]
CATEGORY = {
  PLAYER = 1,
  BULLET = 2,
  WALL = 3,
  GROUND = 4,
  ENEMY = 5,
  HEAD = 6,
  DIAMETER = 7
}

player = require "player"
local background = require "scrollingBG"
require "bullets"
require "enemies"
require "enemyDictionary"
require "timelineManager"


objects = {}
bg = {}

local function restart()

end

function game:keypressed(key, code)
  if key == 'r' and player.isDead then
    player.reset()
    resetEnemies()
    resetTM()
  end
end

function game:enter()
  loadEnemyDictionary() -- loads a preset of every enemy, ready for instantiation
  if loadTimelineManager() == false then
    love.errhand("Failed to load timelineManager")
  end

  --let's create the ground
  objects.ground = {}
  objects.ground.body = love.physics.newBody(world, 160, 256)
  objects.ground.shape = love.physics.newRectangleShape(496, 5)
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
  objects.wallRight.body = love.physics.newBody(world, -1, 128)
  objects.wallRight.shape = love.physics.newRectangleShape(5, 256)
  objects.wallRight.fixture = love.physics.newFixture(objects.wallRight.body, objects.wallRight.shape);
  objects.wallRight.fixture:setCategory(3)

  player.load()
  loadBullets()
  background.load()

  -- testing
  -- addEnemy("skull", 7, 0, 1)
  -- addEnemy("oldOne", 25, 30, 1)
  -- addEnemy("oldOne", 25, 75, 1)
  -- addEnemy("newOne", 25, 75, 1)
  -- addEnemy("skull", 90, 0, -1)
  -- addEnemy("ogre", 25, 75, 1)
  -- addEnemy("bat", 25, 75, 1)
  -- addEnemy("bat", 50, 10, 1)
  -- addEnemy("bat", 80, 25, 1)
  -- addEnemy("pipes", 203, 75, -1) -- 175
end

function game:update(dt)
  if player.isDead then
    local newDT = dt / 4
    world:update(newDT)
    player.update(newDT)
    updateBullet(newDT)
    updateEnemy(newDT)

    updateTime(newDT)
    updateTM()

    background.update(newDT)
  else
    world:update(dt)
    player.update(dt)
    updateBullet(dt)
    updateEnemy(dt)

    updateTime(dt)
    updateTM()

    background.update(dt)
  end
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

  drawEnemy()

  player.draw()

  drawBullet()

  drawTime()

  if player.isDead then
    love.graphics.setFont(bigFont)
    love.graphics.printf("You Are Dead.", 47, 50, 200)
    love.graphics.setFont(smallFont)
  end

  maid64.finish()
end
