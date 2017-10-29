-- cameraControls.lua

local camera = require "lib/camera"
local timers = {}
local magnitude = 0
cam = nil

function loadCamera()
  cam = camera()
  cam.smoother = camera.smooth.linear(1) -- test smoother
  -- cam.smoother = camera.smooth.damped(20) -- test smoother
  addTimer(0.0, "shake", timers)
end

function setShake(x, y)
  resetTimer(x, "shake", timers)
  magnitude = y
end

local function screenShake()
  if getTimerStatus("shake", timers) == false then
    local x, y = cam:position()
    
    local shakeX = love.math.random(0, 1)
    if shakeX == 0 then shakeX = -1 end

    local shakeY = love.math.random(0, 1)
    if shakeY == 0 then shakeY = -1 end

    cam:lookAt(x + (shakeX * magnitude), y + (shakeY * magnitude))
  end
end

function updateCamera(dt)
  local x, y = love.graphics.getDimensions()
  local camX, camY = cam:position()

  x = x / 2
  y = y / 2

  if updateTimer(dt, "shake", timers) and (camX ~= x or camY ~= y) then
    cam:lookAt(x, y)
  end

  screenShake()
end
