local function buttonUserCallback(level)
    print("User button is " .. level)
end

buttonUser=1

gpio.mode(buttonUser, gpio.INPUT, gpio.PULLUP)
gpio.trig(buttonUser, "both", buttonUserCallback)

