buttonUser = 1
red = 3
state = false
    
gpio.mode(red, gpio.OUTPUT) 
    
local function buttonUserCallback(level)
    state = not state
    gpio.write(red, state and gpio.HIGH or gpio.LOW)
end
    
gpio.mode(buttonUser, gpio.INT, gpio.PULLUP)
gpio.trig(buttonUser, "down", buttonUserCallback)

