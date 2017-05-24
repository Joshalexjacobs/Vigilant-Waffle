local skull = require "enemies/skull"

local enemyDictionary = {
  {name = "skull", enemy = skull},
}

function loadEnemyDictionary()
  for i = 1, #enemyDictionary do
    enemyDictionary[i].enemy.load() -- load all enemies
  end
end

function getEnemy(name)
  for i = 1, #enemyDictionary do
    if name == enemyDictionary[i].name then
      local newEnemy = copy(enemyDictionary[i].enemy, newEnemy)
      return newEnemy
    end
  end
end
