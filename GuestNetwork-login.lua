-- do whatever is required to authenticate in GuestNetwork

local mac  = wifi.sta.getmac()
local ip   = wifi.sta.getip()
local ssid = "GuestNetwork"
local host = "1.2.3.4" -- IP or name of auth server
local url  = "/cgi-bin/login" ..
    "?cmd=login" ..
    "&mac=" .. mac ..
    "&ip=" .. ip ..
    "&ssid=" .. ssid ..
    "&authstring=" .. "whatever" -- replace this accordingly

print("HOST:", host)
print("URL:", url)
-- https://nodemcu.readthedocs.io/en/master/en/modules/net/#example_5
srv = net.createConnection(net.TCP, 0)
srv:on("receive", function(sck, c) end)
-- Wait for connection before sending.
srv:on("connection", function(sck, c)
  -- 'Connection: close' rather than 'Connection: keep-alive' to have server
  -- initiate a close of the connection after final response (frees memory
  -- earlier here), https://tools.ietf.org/html/rfc7230#section-6.6
  sck:send("GET " .. url .. " HTTP/1.1\r\nHost: " .. host .. "\r\nConnection: close\r\nAccept: */*\r\n\r\n")
end)
srv:connect(80, host)

-- destroy connection
tmr.create():alarm(5000, tmr.ALARM_SINGLE, function()
  srv = nil
end)
