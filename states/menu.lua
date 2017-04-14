--menu.lua

require "states/game"

menu = {}

function menu:enter()
  -- test sprite
  titleImg = maid64.newImage("img/title.png")
  botImg = maid64.newImage("img/titleBot.png")
end

function menu:keypressed(key, code)
  -- pressed enter/space
  if key == 'space' or key == 'return' then -- quit on escape
    Gamestate.switch(game) -- swtich to game screen
  end
end

function menu:update(dt)

end

function menu:draw()
  maid64.start()

  love.graphics.printf("- Press Start -", 0, 55, 65, "center")
  love.graphics.draw(titleImg, 32, 32, 0, 1, 1, 32, 32)

  maid64.finish()
end
