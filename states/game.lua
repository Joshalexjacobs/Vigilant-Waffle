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
  DIAMETER = 7,
	PLATFORM = 8
}

player = require "player"
local background = require "scrollingBG"
require "platforms"
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
		resetPlatforms()
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
  objects.ground.shape = love.physics.newRectangleShape(496, 20)
  objects.ground.fixture = love.physics.newFixture(objects.ground.body, objects.ground.shape) --attach shape to body
  objects.ground.sprite = maid64.newImage("img/platform5.png")
  objects.ground.fixture:setCategory(4)

  objects.wallLeft = {}
  --objects.wallLeft.body = love.physics.newBody(world, 64 + 2.5 / 2, 64 / 2)
  --objects.wallLeft.body = love.physics.newBody(world, 82, 64 / 2)
  objects.wallLeft.body = love.physics.newBody(world, 410, 128) --  388
  objects.wallLeft.shape = love.physics.newRectangleShape(5, 256)
  objects.wallLeft.fixture = love.physics.newFixture(objects.wallLeft.body, objects.wallLeft.shape);
  objects.wallLeft.fixture:setCategory(3)

  objects.wallRight = {}
  --objects.wallRight.body = love.physics.newBody(world, -2.5 / 2, 64 / 2)
  --objects.wallRight.body = love.physics.newBody(world, -1, 64 / 2)
  objects.wallRight.body = love.physics.newBody(world, -1, 128)
  objects.wallRight.shape = love.physics.newRectangleShape(5, 256)
  objects.wallRight.fixture = love.physics.newFixture(objects.wallRight.body, objects.wallRight.shape);
  objects.wallRight.fixture:setCategory(3)

	
	--[[ Load calls ]] 
  player.load()
  loadBullets()
  background.load()
	loadPlatforms(background.speed)
end

function game:update(dt)
  if player.isDead then
    local newDT = dt / 4
    world:update(newDT)
    player.update(newDT)
    updateBullet(newDT)
    updateEnemy(newDT)

		updatePlatforms(newDT, player)
		
    -- updateTime(newDT)
    -- updateTM()

    background.update(newDT)
  else
    world:update(dt)
    player.update(dt)
    updateBullet(dt)
    updateEnemy(dt)
		
		updatePlatforms(dt, player)

    updateTime(dt)
    updateTM()

    background.update(dt)

    updateCamera(dt) -- camera
  end
end

function game:draw()
  -- print(cam:position())
  -- local camx, camy = cam:position()
  -- print(cam:worldCoords(camx,camy))
  -- print(cam:cameraCoords(camx,camy))
  maid64.start()
  cam:attach()

  background.draw()

	
	if DEBUG then
    love.graphics.polygon("fill", objects.wallLeft.body:getWorldPoints(objects.wallLeft.shape:getPoints()))
    love.graphics.polygon("fill", objects.wallRight.body:getWorldPoints(objects.wallRight.shape:getPoints()))
  end

  love.graphics.setColor(255, 255, 255)

  
  drawPlatforms()
  
  drawEnemy()

  player.draw()


  love.graphics.draw(objects.ground.sprite, 0, 230) -- crappy platform i made 

  if DEBUG then
    love.graphics.polygon("fill", objects.ground.body:getWorldPoints(objects.ground.shape:getPoints()))
  end

  drawBullet()

  drawTime()

  if player.isDead then
    love.graphics.setFont(bigFont)
    -- love.graphics.printf("You Are Dead.", 47, 50, 200)
    love.graphics.printf("You Are Dead.", 105, 100, 200, "center")
    love.graphics.printf(tostring(getTime()) .. 's', 105, 50, 200, "center")
    love.graphics.setFont(smallFont)
  end


  cam:detach()
  maid64.finish()
end
