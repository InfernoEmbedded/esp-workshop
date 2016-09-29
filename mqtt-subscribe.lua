dofile("settings.lua")

buttonUser = 1
myMACAddress = wifi.sta.getmac()
testTopic = "test/" .. myMACAddress

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

    print("Listening for messages on topic " .. testTopic)
    mqttClient:subscribe(testTopic, 0)
end

local function mqttDisconnected(client)
    print("MQTT offline")
end

local function receiveMqttMessage(connection, topic, message)
    print("Received MQTT message: topic='" .. topic .. "' message='" .. message .. "'")
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
tmr.alarm(1,1000, 1, checkConnection)

