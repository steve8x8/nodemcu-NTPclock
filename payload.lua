-- ESP8266 payload to drive an 8-digit 7-segment display
-- using NTP time
-- Steve Sixty-Four, 2017

-- requirements:
-- - NodeMCU firmware with bit, gpio, http, net, node, rtctime, spi, tmr, wifi
-- - nodemcu-max7219 with scrolling support
-- - utc_offset.lua
-- - credentials.lua
-- - xxx-login.lua for networks that need authentication

-- UTC offset
--local UTC_OFFSET = 7200
dofile("utc_offset.lua")

-- got valid time once
local timetag = "_" -- becomes "-" once time ok

-- get SNTP info, update display
local function sntp7seg()
  sntp.sync({"pool.ntp.org", "194.94.224.118", "ptbtime1.ptb.de"},
    function(sec, usec, server, info) -- success callback
      print("SNTP server " .. server)
      max7219.write7segment("SNTP set")
      timetag = "-"
    end,
    function(errno, errstr) -- error callback
      print("SNTP failure")
      max7219.write7segment("SNTP err")
      timetag = "_"
    end)
end

-- initialize MAX7219 for 8 7-segments
-- do no set this to "local" while testing
max7219 = require("max7219")
max7219.setup({
    numberOfModules = 1, -- 8 7-seg digits
    slaveSelectPin = 8,  -- CLK=D5(HCLK), DATA=D7(HMOSI), CS=D8(HCS)
    intensity = 2,       -- still bright enough
    scrollmode = 1,      -- left
    scrolldelay = 1,     -- 100 ms per digit
  })
--max7219.clear()
--max7219.shutdown(true)
--max7219.shutdown(false)

-- initialize display
max7219.clear()
max7219.write7segment("Starting,,,")

-- do the networking stuff
if (wifi.sta.status() ~= wifi.STA_GOTIP) then
  print("no WiFi, status " .. wifi.sta.status())
  max7219.write7segment("No netwk")
else
  -- it may be necessary to authenticate to network, etc
  local apinfo = wifi.sta.getapinfo()
  local ssid = apinfo[1]["ssid"]
  print("Connected to " .. ssid)
  max7219.clear()
  max7219.write7segment(ssid)
  -- if there's a login routine run it
  if (file.exists(ssid .. "-login.lua")) then
    print("Authenticate " .. ssid)
    -- authentication
    dofile(ssid .. "-login.lua")
    print("Done")
  end
  -- set clock for the first time
  tmr.create():alarm(10000, tmr.ALARM_SINGLE, function()
    print("Initial SNTP")
    max7219.write7segment("SNTP ,,,")
    sntp7seg()
  end)
end

-- protect against restarts
if payload_started ~= false then
  print("WARNING: re-entered payload")
else
  payload_started = true

  -- NTP refresh
  -- max alarm range: 6870947, use one hour
  tmr.create():alarm(1*60*60*1000, tmr.ALARM_AUTO, function()
    sntp7seg()
  end)
  -- time display refresh
  tmr.create():alarm(250, tmr.ALARM_AUTO, function()
    -- read time
    local sec, usec = rtctime.get()
    -- RTC must be set
    if (sec ~= 0) then
      local tm = rtctime.epoch2cal(sec + UTC_OFFSET)
      local date = string.format("%04d.%02d.%02d", tm["year"], tm["mon"], tm["day"])
      local time = string.format("%02d%s%02d%s%02d", tm["hour"], timetag, tm["min"], timetag, tm["sec"])
      if (sec % 30 == 25) then
        max7219.write7segment(date)
      else
        max7219.write7segment(time)
      end
    end
  end)

end
