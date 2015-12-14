-- Global variables
sda=1
scl=2

-- UART setup
--uart.setup(0,19200,8,0,1,0)
tmr.delay(1000)
--I2C setup
i2c_speed=i2c.setup(0,sda,scl,i2c.SLOW)
tmr.delay(1000)
print("I2C setup, speed is " .. i2c_speed)

print("Heap @ startup: " .. node.heap())

--GPIO
-- for skipping deep-sleep mode
gpio.mode(6, gpio.INPUT, gpio.PULLUP)
gpio.mode(7, gpio.OUTPUT)
gpio.write(7, gpio.HIGH)

-- wifi SOFTAP
--wifi.sta.config("1113 - AirportExtreme","hurranyaralunk")
wifi.sta.config("1113-Kazy","r4ekkorn")
--wifi.sta.config("Xtalin","xtalout1")
wifi.setmode(1)
wifi.sta.autoconnect(1)

print("Heap before main.lua call: " .. node.heap())

if gpio.read(7)==0 then
    print("SW halted, main.lua not started.")   
else
    print("main.lua started.")
    dofile("main.lua")
end

