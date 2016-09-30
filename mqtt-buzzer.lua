dofile("settings.lua")

buttonUser = 1
buttonTopic = "buttons/" .. myMACAddress
myMACAddress = wifi.sta.getmac()

red = 3
redTopic = "lights/" .. myMACAddress .. "/red"
green = 4
greenTopic = "lights/" .. myMACAddress .. "/green"
blue = 5
blueTopic = "lights/" .. myMACAddress .. "/blue"

buzzer = 8
buzzerTopic = "buzzer/" .. myMACAddress

defaultPWMFrequency = 1000

local function connectWifi()
    wifi.setmode(wifi.STATION)
    wifi.sta.config(wifiSSID, wifiPassword)
    wifi.sta.connect()
end

local function buttonUserCallback(level)
    print("Button is " .. level)
    mqttClient:publish(buttonTopic, 1 - level, 0, 0)
end

local function mqttConnected(client)
    print("MQTT connected")
    gpio.mode(buttonUser, gpio.INT, gpio.PULLUP)
    gpio.trig(buttonUser, "both", buttonUserCallback)

    print("Publishing button presses at '" .. buttonTopic .. "'")

    print("Listening for red LED requests at '" .. blueTopic .. "'")
    mqttClient:subscribe(redTopic, 0)

    print("Listening for green LED requests at '" .. blueTopic .. "'")
    mqttClient:subscribe(greenTopic, 0)

    print("Listening for blue LED requests at '" .. blueTopic .. "'")
    mqttClient:subscribe(blueTopic, 0)

    print("Listening for buzzer requests at '" .. buzzerTopic .. "'")
    mqttClient:subscribe(buzzerTopic, 0)
end

local function mqttDisconnected(client)
    print ("MQTT offline")
end

local function setupLEDs()
    gpio.mode(red, gpio.OUTPUT)
    pwm.setup(red, defaultPWMFrequency, 0)

    gpio.mode(green, gpio.OUTPUT)
    pwm.setup(green, defaultPWMFrequency, 0)

    gpio.mode(blue, gpio.OUTPUT)
    pwm.setup(blue, defaultPWMFrequency, 0)
end

local function setRedLED(value)
    if (value > 1.0) then
        value = 1.0
    elseif (value < 0) then
        value = 0
    end

    local dutyCycle = math.floor(value * 1023)
    print("Setting the red LED to " .. dutyCycle)
    
    pwm.setduty(red, dutyCycle)
    pwm.start(red)
end

local function setGreenLED(value)
    if (value > 1.0) then
        value = 1.0
    elseif (value < 0) then
        value = 0
    end

    local dutyCycle = math.floor(value * 1023)
    print("Setting the green LED to " .. dutyCycle)
    
    pwm.setduty(green, dutyCycle)
    pwm.start(green)
end

local function setBlueLED(value)
    if (value > 1.0) then
        value = 1.0
    elseif (value < 0) then
        value = 0
    end

    local dutyCycle = math.floor(value * 1023)
    print("Setting the blue LED to " .. dutyCycle)
    
    pwm.setduty(blue, dutyCycle)
    pwm.start(blue)
end

local function setupBuzzer()
    gpio.mode(buzzer, gpio.OUTPUT)
end

local function stopBuzzer()
    pwm.stop(buzzer)
    pwm.setclock(blue, defaultPWMFrequency)
end

local function fireBuzzer(message)
    local frequencyString, durationString = string.match(message, "(%d*),(%d*)")

    local frequency = tonumber(frequencyString)
    local duration = tonumber(durationString)

    if frequency < 20 then
        frequency = 20
    elseif frequency > 1000 then
        frequency = 1000
    end

    print("Sounding buzzer with frequency " .. frequency .. " for " .. duration .. " ms")

    pwm.setup(buzzer, frequency, 511)
    pwm.start(buzzer)
    tmr.alarm(2, duration, tmr.ALARM_SINGLE, stopBuzzer)
end

local function receiveMqttMessage(connection, topic, message)
    if topic == redTopic then
        setRedLED(tonumber(message))
    elseif topic == greenTopic then
        setGreenLED(tonumber(message))
    elseif topic == blueTopic then
        setBlueLED(tonumber(message))
    elseif topic == buzzerTopic then
        fireBuzzer(message)
    end
end

local function setupMqtt()
    mqttClient = mqtt.Client("myclient", 120, mqttUser, mqttPassword)
    
    mqttClient:on("connect", mqttConnected)
    mqttClient:on("offline", mqttDisconnected)
    mqttClient:on("message", receiveMqttMessage)

    mqttClient:connect(mqttServerAddress, mqttPort, 0, 1)
end

local function wifiConnected()
    ssid, password, bssid_set, bssid = wifi.sta.getconfig()
    ip, netmask, gateway = wifi.sta.getip()
    print("Connected to " .. ssid .. " with ip address " .. ip)

    setupMqtt()
end

local function checkConnection()
    if (1 == wifi.sta.status()) then
        print("Not connected")
    else
        tmr.stop(1)
        wifiConnected()
    end
end

connectWifi()
setupLEDs()
setupBuzzer()
tmr.alarm(1,1000, tmr.ALARM_AUTO, checkConnection)

