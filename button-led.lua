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

-- Debounce code based on
-- https://gist.github.com/marcelstoer/59563e791effa4acb65f

function debounce (func)
    local last = 0
    local delay = 200 * 1000 -- 200ms * 1000 as tmr.now() has μs resolution

    return function (...)
        local now = tmr.now()
        local delta = now - last
        if delta < 0 then delta = delta + 2147483647 end; -- proposed because of delta rolling over, https://github.com/hackhitchin/esp8266-co-uk/issues/2
        if delta < delay then return end;

        last = now
        return func(...)
    end
end

local function buttonUserCallback(level)
    state = not state
    gpio.write(red, state and gpio.HIGH or gpio.LOW)
end
    
gpio.mode(buttonUser, gpio.INT, gpio.PULLUP)
gpio.trig(buttonUser, "down", debounce(buttonUserCallback))

