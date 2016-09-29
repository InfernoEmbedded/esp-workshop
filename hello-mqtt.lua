dofile("settings.lua")

wifi.setmode(wifi.STATION)
wifi.sta.config(wifiSSID, wifiPassword)
wifi.sta.connect()

function wifiConnected()
    ssid, password, bssid_set, bssid = wifi.sta.getconfig()
    ip, netmask, gateway = wifi.sta.getip()
    print("Connected to " .. ssid .. " with ip address " .. ip)

    mqttClient = mqtt.Client("myclient", 120, mqttUser, mqttPassword)
    
    mqttClient:on("connect", function(client)
        print ("MQTT connected")
        mqttClient:publish("test", "hello from my remote node", 0, 0)
    end)
    mqttClient:on("offline", function(client)
        print ("MQTT offline")
    end)

    mqttClient:connect(mqttServerAddress, 1883, 0, 1)
end

function checkConnection()
    if (1 == wifi.sta.status()) then
        print("Not connected")
    else
        tmr.stop(1)
        wifiConnected()
    end
end

tmr.alarm(1,1000, 1, checkConnection)

