dofile("settings.lua")

myMACAddress = wifi.sta.getmac()

buttonUser = 1
buttonTopic = "buttons/" .. myMACAddress


wifi.setmode(wifi.STATION)
wifi.sta.config(wifiSSID, wifiPassword)
wifi.sta.connect()

local function buttonUserCallback(level)
    mqttClient:publish(buttonTopic, 1 - level, 0, 0)
end

local function wifiConnected()
    ssid, password, bssid_set, bssid = wifi.sta.getconfig()
    ip, netmask, gateway = wifi.sta.getip()
    print("Connected to " .. ssid .. " with ip address " .. ip)

    mqttClient = mqtt.Client("myclient", 120, mqttUser, mqttPassword)
    
    mqttClient:on("connect", function(client)
        print ("MQTT connected")
	print("Publishing button presses at '" .. buttonTopic .. "'")

        gpio.mode(buttonUser, gpio.INT, gpio.PULLUP)
        gpio.trig(buttonUser, "both", buttonUserCallback)
    end)
    
    mqttClient:on("offline", function(client)
        print ("MQTT offline")
    end)

    mqttClient:connect(mqttServerAddress, mqttPort, 0, 1)
end

local function checkConnection()
    if (1 == wifi.sta.status()) then
        print("Not connected")
    else
        tmr.stop(1)
        wifiConnected()
    end
end

tmr.alarm(1,1000, 1, checkConnection)

