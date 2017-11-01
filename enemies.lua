--enemiesOne.lua

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

local enemiesOne = {}
local enemiesTwo = {}

function resetEnemies()
  for i, newEnemy in ipairs(enemiesOne) do
    newEnemy.kill(newEnemy)
  end

  for i, newEnemy in ipairs(enemiesTwo) do
    newEnemy.kill(newEnemy)
  end

  enemiesOne = {}
  enemiesTwo = {}
end

function addEnemy(name, x, y, dir)
  local newEnemy = getEnemy(name, x, y)
  if newEnemy.init then newEnemy.init(newEnemy, x, y, dir) 
  else
    if x then newEnemy.body:setX(x) end
    if y then newEnemy.body:setY(y) end
    if dir then newEnemy.dir = dir end
  end


  -- temporary flip until i think of a better place for this
  if tonumber(dir) == -1 then
    for i = 1, table.getn(newEnemy.animations) do
      newEnemy.animations[i]:flipH()
    end
  end

  if newEnemy.layer == 1 then
    table.insert(enemiesOne, newEnemy)
  else
    table.insert(enemiesTwo, newEnemy)
  end
end

-- function removeAllenemiesOne() end

function updateEnemy(dt)
  for i, newEnemy in ipairs(enemiesOne) do
    newEnemy.behaviour(dt, newEnemy)

    if newEnemy.isDead then
      table.remove(enemiesOne, i)
    end
  end

  for i, newEnemy in ipairs(enemiesTwo) do
    newEnemy.behaviour(dt, newEnemy)

    if newEnemy.isDead then
      table.remove(enemiesTwo, i)
    end
  end
end

function drawEnemyLayerOne()
    for i, newEnemy in ipairs(enemiesOne) do
    newEnemy.draw(newEnemy)
  end  
end

function drawEnemyLayerTwo()
  for i, newEnemy in ipairs(enemiesTwo) do
    newEnemy.draw(newEnemy)
  end
end

function getEnemyCount()
  return #enemiesOne + #enemiesTwo
end