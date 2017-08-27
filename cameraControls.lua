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
    cam:lookAt(x + (love.math.random(-1, 1) * magnitude), y + (love.math.random(-1, 1) * magnitude))
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
