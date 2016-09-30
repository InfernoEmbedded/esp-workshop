buttonUser = 1
red = 3
green = 4
blue = 5
state = false
    
gpio.mode(red, gpio.OUTPUT) 
gpio.mode(green, gpio.OUTPUT) 
gpio.mode(blue, gpio.OUTPUT) 

gpio.write(green, gpio.LOW)
gpio.write(blue, gpio.LOW)
    
local function buttonUserCallback(level)
    state = not state
    gpio.write(red, state and gpio.HIGH or gpio.LOW)
end
    
gpio.mode(buttonUser, gpio.INT, gpio.PULLUP)
gpio.trig(buttonUser, "down", buttonUserCallback)

