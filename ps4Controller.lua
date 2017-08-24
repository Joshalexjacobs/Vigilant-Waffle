-- ps4Controller.lua --

noController = false

function loadPS4Controller()
  local joysticks = love.joystick.getJoysticks()

  if joysticks[1] == nil then -- if no controller is found...
    noController = true -- set noController to true
    print("No PS4 controller was found.")
  else
    joystick = joysticks[1]
    print("PS4 Controller loaded.")
  end
end

function pressStart()
  if noController then
    return false
  else
    return joystick:isGamepadDown("start")
  end
end

function dPadLeft()
  if noController then
    return false
  else
    return joystick:isGamepadDown("dpleft")
  end
end

function dPadRight()
  if noController then
    return false
  else
    return joystick:isGamepadDown("dpright")
  end
end

function dPadUp()
  if noController then
    return false
  else
    return joystick:isGamepadDown("dpup")
  end
end

function dPadDown()
  if noController then
    return false
  else
    return joystick:isGamepadDown("dpdown")
  end
end

function pressX()
  if noController then
    return false
  else
    return joystick:isGamepadDown("a")
  end
end

function pressCircle()
  if noController then
    return false
  else
    return joystick:isGamepadDown("b")
  end
end

function pressStart()
  if noController then
    return false
  else
    return joystick:isGamepadDown("start")
  end
end
