--scrollingBG.lua

local background = {
  sprite = "img/bg5.png",
  x1 = 0,
  y1 = 0,
  x2 = 0,
  y2 = 1024,
  w = 0,
  h = 0,
  -- functions
  load = nil,
  update = nil,
  draw = nil,
  -- other
  speed = -10 -- -15
}

function getBackgroundSpeed()
  return background.speed
end

background.load = function ()
  background.sprite = maid64.newImage(background.sprite)
  background.h = background.sprite:getHeight()
end

background.update = function (dt)
  local move = background.speed * dt
  background.y1 = background.y1 + move
  background.y2 = background.y2 + move

  if background.y1 <= -background.h then
    background.y1 = background.h
  end

  if background.y2 <= -background.h then
    background.y2 = background.h
  end
end

background.draw = function ()
  -- back back
  love.graphics.draw(background.sprite, 0, 0)

  -- bottom
  love.graphics.draw(background.sprite, background.x1, background.y1)

  -- top
  love.graphics.draw(background.sprite, background.x2, background.y2)
end

return background
