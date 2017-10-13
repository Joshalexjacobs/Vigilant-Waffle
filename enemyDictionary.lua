local skull = require "enemies/skull"
local oldOne = require "enemies/oldOne"
local newOne = require "enemies/newOne"
local ogre = require "enemies/ogre"
local pipes = require "enemies/pipes"
local bat = require "enemies/bat"

local LS = require "enemies/laserShower"

local enemyDictionary = {
  {name = "skull", enemy = skull},
  {name = "oldOne", enemy = oldOne},
  {name = "newOne", enemy = newOne},
  {name = "ogre", enemy = ogre},
  {name = "bat", enemy = bat},
  {name = "pipes", enemy = pipes},
  {name = "LS", enemy = LS},
}

function loadEnemyDictionary()
  for i = 1, #enemyDictionary do
    --enemyDictionary[i].enemy.load(enemyDictionary[i].enemy) -- load all enemies
    -- repurpose this to only load enemy images etc... (no physic objects)
  end
end

function getEnemy(name)
  for i = 1, #enemyDictionary do
    if name == enemyDictionary[i].name then
      local newEnemy = copy(enemyDictionary[i].enemy, newEnemy)
      newEnemy.load(newEnemy)
      return newEnemy
    end
  end
end
