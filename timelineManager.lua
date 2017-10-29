-- timelineManager.lua

local timeline = {}

local timelineName = "timelines/demo_2.txt"
-- local timelineName = "timelines/bats.txt"
-- local timelineName = "timelines/pipes.txt"

local scenes = {
 --"timelines/demo_1.txt",
 -- "timelines/demo_2.txt" 
 "timelines/wall.txt" 
}

local curScene = 1

local overallTime = 0

local time = 0

local allSpawned = false

function loadTimelineManager()
  -- load timeline and store in timeline
  -- for line in io.lines(timelineName) do
  for line in io.lines(scenes[curScene]) do
    local row = {name = nil, time = nil, x = nil, y = nil, dir = 1}

    if line == nil or line == '' or line == ' ' or string.sub(line, 1, 2) == "--" then
      -- do nothing
    else
      row.name = string.sub(line, 1, string.find(line, ' ') - 1)
      line = string.gsub(line, row.name .. ' ', '')

      row.time = string.sub(line, 1, string.find(line, ' ') - 1)
      line = string.gsub(line, row.time .. ' ', '', 1)

      row.x = string.sub(line, 1, string.find(line, ' ') - 1)
      line = string.gsub(line, row.x .. ' ', '', 1)

      row.y = string.sub(line, 1, string.find(line, ' ') - 1)
      line = string.gsub(line, row.y .. ' ', '', 1)

      row.dir = line

      table.insert(timeline, row)
    end
  end

  return true
end

local function resetTime()
  time = 0
end

function resetTM()
  resetTime()
  timeline = {}
  loadTimelineManager()
end

function updateTM()
  while #timeline > 1 and tonumber(timeline[1].time) <= time do
		--[[ should the platforms live in a seperate file? or at least a seperate list? ]]
		if addTimelinePlatform(timeline[1].name, timeline[1].x, timeline[1].y) == false then
			addEnemy(timeline[1].name, timeline[1].x, timeline[1].y, timeline[1].dir)
		end
		
    table.remove(timeline, 1)
    if #timeline <= 1 then
      allSpawned = true
    end
  end

  if allSpawned and getEnemyCount() <= 0 then
    curScene = curScene + 1
    if curScene > #scenes then
      curScene = 1
    end

    resetTM()
    allSpawned = false
  end
end

function getTime()
  return time
end

function updateTime(dt)
  time = math.floor((time + dt ) * (10 ^ 2) + 0.5) / (10 ^ 2)
  overallTime = math.floor((overallTime + dt ) * (10 ^ 2) + 0.5) / (10 ^ 2)

  return time
end

function drawTime()
  if DEBUG then
    love.graphics.printf(time, 5, 0, 200) -- testing
    
    love.graphics.printf("- " .. scenes[curScene], 35, 0, 200) -- testing
  end

  love.graphics.printf(overallTime, 5, 10, 200) -- testing
end
