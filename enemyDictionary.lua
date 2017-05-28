local skull = require "enemies/skull"
local oldOne = require "enemies/oldOne"

local enemyDictionary = {
  {name = "skull", enemy = skull},
  {name = "oldOne", enemy = oldOne},
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
