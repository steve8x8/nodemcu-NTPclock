# nodemcu-NTPclock
A WiFi, NTP controlled clock with an ESP8266 dev mod running NodeMCU/Lua

## HowTo:

### Hardware
  * LoLin ESP8266 developer module (with voltage regulator and USB-serial)
  * two small breadboards
  * a MAX7219-driven 8-digit 7-segment display, SPI interface
  * five jumper wires:
    * `3V -- VCC`
    * `G  -- GND`
    * `D7 -- DIN`
    * `D8 -- CS`
    * `D5 -- CLK`

### Firmware
  * NodeMCU build with modules:
    * `bit, gpio, http, net, node, rtctime, spi, tmr, wifi`
  * flashing software, e.g. `esptool`

### Software
  * display driver https://github.com/steve8x8/nodemcu-max7219 (fork of https://github.com/marcelstoer/nodemcu-max7219 with scrolling support and more)
    * `font7seg.lua`
    * `max7219.lua`
  * a tweaked `init.lua` (inspired by https://nodemcu.readthedocs.io/en/master/en/upload/#initlua)
  * to connect to one of multiple wifi networks, set up your `credentials.lua`
  * you must set the offset from UTC of your timezone in `utc_offset.lua`
  * a `payload.lua` that tries to combine it all
  * upload software, e.g. `luatool`

## Caveat: Work in progress!
