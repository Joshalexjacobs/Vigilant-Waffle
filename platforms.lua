-- platforms.lua

local platform = {
	x = 100,
	y = 200,
	w = 30,
	h = 5,
	-- platform physics objects
	body = nil,
	shape = nil, 
	fixture = nil
}

local platforms = {}

function loadPlatforms()
	platform.body = love.physics.newBody(world, platform.x, platform.y)
	platform.shape = love.physics.newRectangleShape(platform.w, platform.h)
	platform.fixture = love.physics.newFixture(platform.body, platform.shape)
	
	platform.fixture:setCategory(CATEGORY.PLATFORM)
	platform.fixture:setMask(CATEGORY.BULLET)
	platform.fixture:setUserData(platform)
end

function updatePlatforms(dt)
	-- do stuff
end

function drawPlatforms()
	love.graphics.setColor(200, 0, 0, 255)
	love.graphics.polygon("fill", platform.body:getWorldPoints(platform.shape:getPoints()))
	love.graphics.setColor(255, 255, 255, 255)
end