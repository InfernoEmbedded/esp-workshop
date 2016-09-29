buttonUser=1
buzzer=8
    
gpio.mode(buzzer, gpio.OUTPUT)  
    
local function buttonUserCallback(level)
    pwm.setup(buzzer, 256, 511)
    pwm.start(buzzer)
    tmr.delay(0.2 * 1000000) -- converts seconds to microseconds
    pwm.stop(buzzer)
end
    
gpio.mode(buttonUser, gpio.INT, gpio.PULLUP)
gpio.trig(buttonUser, "down", buttonUserCallback)

