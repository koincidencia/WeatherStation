deep_sleep_time=60*20
sleep_timeout=20000

server_port=3333
--server_ip="152.66.180.1"
server_ip="192.168.1.111"

try_ip=10
cntr_ip=0

function goToSleep()
    if gpio.read(6)==1 then
        print("Going to sleep for "..deep_sleep_time.." sec.") 
        gpio.write(7, gpio.LOW)
        node.dsleep(deep_sleep_time*1000*1000,4)
    else
        print("Okay, i'll be awake.")
    end
end

function sendToServer()
    voltage=adc.read(0)
    sk=net.createConnection(net.TCP, 0)
    sk:on("receive", function(sck, c) 
        sck:close() 
        print("Closed.")
        print(c)
        print(gpio.read(1))
        goToSleep()
    end)
            
    sk:on("sent", function(sck, c) 
        print("Sent.")
    end)

    sk:on("connection", function(sck,c)
        print("Connected.")   
        print("Sending...")  
        sck:send(myi2c.read_str)
    end)
    
    sk:connect(server_port,server_ip)
end 

-- Here starts the main program
tmr.alarm(1,sleep_timeout,0,goToSleep) 
print("Heap at starting main.lua: " .. node.heap())

myi2c = require("myi2c");
print("Heap after requring myi2c.lua: " .. node.heap())
-- DEBUG: finding i2c devices

-- Measurement
myi2c.read_sensor()
myi2c.read_fg()

myi2c.read_str=string.char(myi2c.raw_data[1],myi2c.raw_data[2],myi2c.raw_data[3],myi2c.raw_data[4],myi2c.raw_data[5],myi2c.raw_data[6])

tmr.alarm(0,1000,1,function()
    if wifi.sta.getip()==nil then
        print("Waiting for IP...")
    else
        print("IP is: "..wifi.sta.getip())
        tmr.stop(0)
        tmr.wdclr()
        tmr.alarm(2,1000,0,sendToServer)
    end
end)
