--main.lua

Gamestate = require "lib/gamestate"
anim8 = require "lib/anim8"
require "lib/maid64"
require "lib/timer"

-- states
require "states/menu"
require "states/game"

world = love.physics.newWorld(0, 9.81*32, true) --create a world for the bodies to exist in with horizontal gravity of 0 and vertical gravity of 9.81

-- global function(s)
function copy(obj, seen)
  if type(obj) ~= 'table' then return obj end
  if seen and seen[obj] then return seen[obj] end
  local s = seen or {}
  local res = setmetatable({}, getmetatable(obj))
  s[obj] = res
  for k, v in pairs(obj) do res[copy(k, s)] = copy(v, s) end
  return res
end

function love.load(arg)
  love.window.setMode(160*3, 144*3, {resizable=true, vsync=true, minwidth=200, minheight=200})

  -- load fonts
  smallestFont = love.graphics.newFont("lib/kenpixel_mini.ttf", 6)
  smallFont = love.graphics.newFont("lib/kenpixel_mini.ttf", 7)
  medFont = love.graphics.newFont("lib/kenpixel_mini.ttf", 10)
  bigFont = love.graphics.newFont("lib/kenpixel_mini.ttf", 14)
  love.graphics.setFont(smallFont)

  -- setup maid64
  maid64.setup(64)

  -- setup physics (1 meter = 64 pixels)
  love.physics.setMeter(32)

  love.graphics.setDefaultFilter('nearest', 'nearest')

  Gamestate.registerEvents()
  Gamestate.switch(game) -- swtich to menu screen
end

function love:keypressed(key, code)
  if key == 'escape' then -- quit on escape
    love.event.quit()
  end
end

function love.update(dt)

end

function love.draw()

end

function love.resize(w, h)
  -- this is used to resize the screen correctly
  maid64.resize(w, h)
end
