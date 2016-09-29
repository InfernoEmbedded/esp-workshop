wifi.setmode(wifi.STATION)
wifi.sta.config(wifiSSID, wifiPassword)
wifi.sta.connect()


tmr.alarm(1,1000, 1, function()
    if (1 == wifi.sta.status()) then
        print("Not connected")
    else
        ssid, password, bssid_set, bssid = wifi.sta.getconfig()
        ip, netmask, gateway = wifi.sta.getip()
        print("Connected to " .. ssid .. " with ip address " .. ip)
        tmr.stop(1)
    end
end)

