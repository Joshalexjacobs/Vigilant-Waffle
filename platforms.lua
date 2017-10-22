-- platforms.lua

local platform = {
	-- platform dimensions
	x = 100,
	y = 200,
	w = 30,
	h = 5,
	offX = 5,
	offY = 5,
	-- platform assets
	sprite = nil,
	-- platform physics objects
	body = nil,
	shape = nil, 
	fixture = nil,
	-- booleans
	isActive = false
}

local platforms = {}

local platformTypes = {
	{name = "shortPlatform", w = 32, h = 10, sprite = "img/platforms/shortPlatform.png", offX = -15, offY = -5},
	{name = "medPlatform", w = 64, h = 5},
	{name = "longPlatform", w = 128, h = 5}
}

local platformSpeed = 0

function loadPlatforms(speed)
	-- for i = 1, #platformTypes do
	
	-- end
	platformSpeed = speed
end

function addTimelinePlatform(name, x, y)
	for i = 1, #platformTypes do
		if name == platformTypes[i].name then
			--addPlatform(x, y, platformTypes[i].w, platformTypes[i].h, platformTypes[i].sprite)
			addPlatform(x, y, platformTypes[i])
			return true
		end
	end
	
	return false
end

--function addPlatform(x, y, w, h, sprite)
function addPlatform(x, y, platformType)
	local newPlatform = copy(platform, newPlatform)
	
	newPlatform.x = x
	newPlatform.y = y
	newPlatform.w = platformType.w
	newPlatform.h = platformType.h
	newPlatform.sprite = maid64.newImage(platformType.sprite)
	newPlatform.offX = platformType.offX
	newPlatform.offY = platformType.offY
	
	
	newPlatform.body = love.physics.newBody(world, newPlatform.x, newPlatform.y, "dynamic")
	newPlatform.shape = love.physics.newRectangleShape(newPlatform.w, newPlatform.h)
	newPlatform.fixture = love.physics.newFixture(newPlatform.body, newPlatform.shape)
	
	newPlatform.body:setFixedRotation(true)
	newPlatform.body:setGravityScale(0)
	
	newPlatform.fixture:setCategory(CATEGORY.PLATFORM)
	newPlatform.fixture:setMask(CATEGORY.BULLET, CATEGORY.GROUND, CATEGORY.WALL)
	newPlatform.fixture:setUserData(newPlatform)
	
	table.insert(platforms, newPlatform)
end

function updatePlatforms(dt, player)
	for i, newPlatform in ipairs(platforms) do
		newPlatform.body:setLinearVelocity(0, platformSpeed)

		if player.body:getY() + player.h / 2 < newPlatform.body:getY() + newPlatform.h / 2 then
			newPlatform.isActive = true
			newPlatform.fixture:setMask(CATEGORY.BULLET, CATEGORY.GROUND, CATEGORY.WALL)
		else
			newPlatform.isActive = false
			newPlatform.fixture:setMask(CATEGORY.BULLET, CATEGORY.GROUND, CATEGORY.WALL, CATEGORY.PLAYER)
		end
		
		--[[ may need this at a later point ?
		local contacts = newPlatform.body:getContactList()
		
		for i = 1, #contacts do
			if contacts[i]:isTouching() then
				local fixA, fixB = contacts[i]:getFixtures()
				local platformFixture = nil
				local otherFixture = nil
				
				if fixA:getCategory() == CATEGORY.PLATFORM then
					platformFixture = fixA
					otherFixture = fixB
				else
					platformFixture = fixB
					otherFixture = fixA
				end			
				
			end
			
		end ]]
		
		if newPlatform.body:getY() < -50 then
			destroyPlatform(newPlatform)
			table.remove(platforms, i)
		end
		
	end
	
end

function drawPlatforms()
	for _, newPlatform in ipairs(platforms) do
		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.draw(newPlatform.sprite, newPlatform.body:getX() + newPlatform.offX, newPlatform.body:getY() + newPlatform.offY)

		if DEBUG then
			if newPlatform.isActive then
				love.graphics.setColor(0, 200, 0, 255)
			else
				love.graphics.setColor(200, 0, 0, 255)
			end

			love.graphics.polygon("fill", newPlatform.body:getWorldPoints(newPlatform.shape:getPoints()))			
		-- 	love.graphics.setColor(0, 0, 200, 255)
		-- 	love.graphics.points(newPlatform.body:getX(), newPlatform.body:getY() + newPlatform.h / 2)
		end
	end
	
	love.graphics.setColor(255, 255, 255, 255)
end

function destroyPlatform(newPlatform)
	newPlatform.body:destroy()
end

function resetPlatforms()
	for _, newPlatform in ipairs(platforms) do
		destroyPlatform(newPlatform)
	end
	
	platforms = {}
	platform.isActive = false
end