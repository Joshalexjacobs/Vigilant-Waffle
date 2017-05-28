--enemies.lua

local enemy = {
  name = "",
  hp = 1,
  x = 0,
  y = 0,
  w = 0,
  h = 0,
  offX = 0,
  offY = 0,
  speed = 0,
  dir = 1,
  -- basic enemy assets
  spriteSheet = nil,
  spriteGrid = nil,
  animations = {},
  curAnim = 1,
  -- enemy physics objects
  body = nil,
  shape = nil,
  fixture = nil,
  -- basic enemy functions
  load = nil,
  update = nil,
  draw = nil,
  -- other
  timers = {}
}

local enemies = {}

function addEnemy(name, x, y, dir)
  local newEnemy = getEnemy(name)
  if x then newEnemy.body:setX(x) end
  if y then newEnemy.body:setY(y) end
  if dir then newEnemy.dir = dir end

  -- temporary flip until i think of a better place for this 
  if dir == -1 then
    for i = 1, table.getn(newEnemy.animations) do
      newEnemy.animations[i]:flipH()
    end
  end

  table.insert(enemies, newEnemy)
end

-- function removeAllEnemies() end

function updateEnemy(dt)
  for i, newEnemy in ipairs(enemies) do
    newEnemy.behaviour(dt, newEnemy)

    if newEnemy.isDead then
      table.remove(enemies, i)
    end
  end
end

function drawEnemy()
  for i, newEnemy in ipairs(enemies) do
    newEnemy.draw(newEnemy)
  end
end
