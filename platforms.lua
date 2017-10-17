-- platforms.lua

local platform = {
	x = 100,
	y = 200,
	w = 30,
	h = 5,
	-- platform physics objects
	body = nil,
	shape = nil, 
	fixture = nil,
	-- booleans
	isActive = false
}

local platforms = {}

function loadPlatforms()
	addPlatform(100, 210, 30, 5) -- delete me 
end

--[[ add platform should eventually be based on timeline ]]
function addPlatform(x, y, w, h)
	local newPlatform = copy(platform, newPlatform)
	
	newPlatform.x = x
	newPlatform.y = y
	newPlatform.w = w
	newPlatform.h = h
	
	newPlatform.body = love.physics.newBody(world, newPlatform.x, newPlatform.y)
	newPlatform.shape = love.physics.newRectangleShape(newPlatform.w, newPlatform.h)
	newPlatform.fixture = love.physics.newFixture(newPlatform.body, newPlatform.shape)
	
	newPlatform.fixture:setCategory(CATEGORY.PLATFORM)
	newPlatform.fixture:setMask(CATEGORY.BULLET, CATEGORY.PLAYER)
	newPlatform.fixture:setUserData(newPlatform)
	
	table.insert(platforms, newPlatform)
end

function updatePlatforms(dt, player)
	for _, newPlatform in ipairs(platforms) do
		if player.body:getY() + player.h / 2 < newPlatform.y - newPlatform.h / 2 then
			newPlatform.isActive = true
			newPlatform.fixture:setMask(CATEGORY.BULLET)
		else
			newPlatform.isActive = false
			newPlatform.fixture:setMask(CATEGORY.BULLET, CATEGORY.PLAYER)
		end
	end
	
	-- if player.y < platform.y + platform.h / 2 then
	-- platform mask does not include player
	-- else 
	-- platform mask includes the player
end

function drawPlatforms()
	for _, newPlatform in ipairs(platforms) do
		if newPlatform.isActive then
			love.graphics.setColor(0, 200, 0, 255)
		else
			love.graphics.setColor(200, 0, 0, 255)
		end
		
		love.graphics.polygon("fill", newPlatform.body:getWorldPoints(newPlatform.shape:getPoints()))
	end
	
	love.graphics.setColor(255, 255, 255, 255)
end