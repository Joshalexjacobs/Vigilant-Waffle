-- timelineManager.lua

local timeline = {}

local timelineName = "timelines/demo.txt"

local time = 0

function loadTimelineManager()
  -- load timeline and store in timeline
  for line in io.lines(timelineName) do
    local row = {name = nil, time = nil, x = nil, y = nil, dir = 1}

    if line == nil or line == '' or line == ' ' or string.sub(line, 1, 2) == "--" then
      print("Skipped blank line during timeline load.")
    else
      row.name = string.sub(line, 1, string.find(line, ' ') - 1)
      line = string.gsub(line, row.name .. ' ', '')

      row.time = string.sub(line, 1, string.find(line, ' ') - 1)
      line = string.gsub(line, row.time .. ' ', '', 1)

      row.x = string.sub(line, 1, string.find(line, ' ') - 1)
      line = string.gsub(line, row.x .. ' ', '', 1)

      print(line)

      -- row.y = line
      row.y = string.sub(line, 1, string.find(line, ' ') - 1)
      line = string.gsub(line, row.y .. ' ', '', 1)

      row.dir = line

      table.insert(timeline, row)
    end
  end

  for i = 1, 5, 1 do
    print(timeline[i].name .. " - " .. timeline[i].time .. " @ " .. timeline[i].x .. ", " .. timeline[i].y)
  end

  return true
end

function resetTM()
  time = 0
  timeline = {}
  loadTimelineManager()
end

function updateTM()
  while #timeline > 1 and tonumber(timeline[1].time) <= time do
    -- print("adding " .. timeline[1].name, timeline[1].time)
    addEnemy(timeline[1].name, timeline[1].x, timeline[1].y, timeline[1].dir)
    table.remove(timeline, 1)
  end
end

function updateTime(dt)
  time = math.floor((time + dt )* (10 ^ 2) + 0.5) / (10 ^ 2)

  return time
end

function drawTime()
  if DEBUG then
    love.graphics.printf(time, 5, 0, 200) -- testing
    love.graphics.printf("- " .. timelineName, 35, 0, 200) -- testing
  end
end
