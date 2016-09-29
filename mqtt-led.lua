dofile("settings.lua")

buttonUser = 1
myMACAddress = wifi.sta.getmac()
blueLED = 5
blueTopic = "lights/" .. myMACAddress .. "/blue"

local function connectWifi()
    wifi.setmode(wifi.STATION)
    wifi.sta.config(wifiSSID, wifiPassword)
    wifi.sta.connect()
end

local function buttonUserCallback(level)
    mqttClient:publish("buttons/" .. myMACAddress, 1 - level, 0, 0)
end

local function mqttConnected(client)
    print("MQTT connected")
    gpio.mode(buttonUser, gpio.INT, gpio.PULLUP)
    gpio.trig(buttonUser, "both", buttonUserCallback)

    print("Listening for blue LED requests at '" .. blueTopic .. "'")
    mqttClient:subscribe(blueTopic, 0)
end

local function mqttDisconnected(client)
    print ("MQTT offline")
end

local function setupLEDs()
    gpio.mode(blueLED, gpio.OUTPUT)
    pwm.setup(blueLED, 1000, 0)
end

local function setBlueLED(value)
    if (value > 1.0) then
        value = 1.0
    end

    if (value < 0) then
        value = 0
    end

    local dutyCycle = math.floor(value * 1023)
    print("Setting the blue LED to " .. dutyCycle)
    
    pwm.setduty(blueLED, dutyCycle)
end

local function receiveMqttMessage(connection, topic, message)
    if topic == blueTopic then
        setBlueLED(tonumber(message))
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
tmr.alarm(1,1000, 1, checkConnection)

