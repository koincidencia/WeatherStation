local myi2c={}

myi2c.id=0
myi2c.fg_dev_addr=0x55
myi2c.sens_dev_addr=0x45
myi2c.temp=0
myi2c.humidity=0
myi2c.voltage=0
myi2c.read_str=""
myi2c.read_buffer={}
myi2c.read_bytes=0
myi2c.send_buffer={}
myi2c.send_bytes=0
myi2c.raw_data={}

function myi2c.send_data(dev_addr)
     local b=0     
     i2c.start(myi2c.id)
     i2c.address(myi2c.id, dev_addr, i2c.TRANSMITTER)

     for i=1,myi2c.send_bytes do
        tmr.delay(10)
        b=b+i2c.write(myi2c.id, myi2c.send_buffer[i])
     end
     i2c.stop(myi2c.id)

     return b
end

function myi2c.read_data(dev_addr)
    i2c.start(myi2c.id)
    i2c.address(myi2c.id, dev_addr, i2c.RECEIVER)
    myi2c.read_str=i2c.read(myi2c.id, myi2c.read_bytes)
    i2c.stop(myi2c.id)

    for i=1,myi2c.read_bytes do
        myi2c.read_buffer[i]=string.byte(myi2c.read_str,i)
    end
    return myi2c.read_str
end

-- Temperature and humidity sensor functions
function myi2c.read_sensor()
    -- Send measurement command to the sensor
    myi2c.send_buffer[1]=0x24
    myi2c.send_buffer[2]=0x16
    myi2c.send_bytes=2
    myi2c.send_data(myi2c.sens_dev_addr) 
    
    tmr.delay(1000*10)
    -- Get measurement data
    myi2c.read_bytes=6
    myi2c.read_data(myi2c.sens_dev_addr)
    
    myi2c.raw_data[1]=myi2c.read_buffer[1]
    myi2c.raw_data[2]=myi2c.read_buffer[2]
    myi2c.raw_data[3]=myi2c.read_buffer[4]
    myi2c.raw_data[4]=myi2c.read_buffer[5]
    
    -- Convert data to variables
    local ST=myi2c.read_buffer[1]*256+myi2c.read_buffer[2]
    local SRH=myi2c.read_buffer[4]*256+myi2c.read_buffer[5]
    myi2c.temp=175*ST/(math.pow(2,16)-1)-45
    myi2c.humidity=100*SRH/(math.pow(2,16)-1)

    print("Temperature is: " .. myi2c.temp .. " °C")
    print("Humidity is : " .. myi2c.humidity .. " %")


    --myi2c.raw_data=string.char(myi2c.read_buffer[1],myi2c.read_buffer[2],myi2c.read_buffer[4],myi2c.read_buffer[5])print(high)
end

function myi2c.fg_vbat()
    myi2c.send_buffer[1]=0x08
    myi2c.send_buffer[2]=0x09
    myi2c.send_bytes=2
    myi2c.send_data(myi2c.fg_dev_addr)

    myi2c.read_bytes=1
    myi2c.read_data(myi2c.fg_dev_addr)
    local low=myi2c.read_buffer[1]
    myi2c.raw_data[5]=myi2c.read_buffer[1]
    
    myi2c.read_bytes=1
    myi2c.read_data(myi2c.fg_dev_addr)
    myi2c.raw_data[6]=myi2c.read_buffer[1]
    local high=myi2c.read_buffer[1]
    
    return high*256+low
end

function myi2c.fg_devtype()
    myi2c.send_buffer[1]=0x00
    myi2c.send_buffer[2]=0x01
    myi2c.send_buffer[3]=0x01
    myi2c.send_buffer[4]=0x00
    myi2c.send_bytes=4
    myi2c.send_data(myi2c.fg_dev_addr)
    
    myi2c.read_bytes=1
    myi2c.read_data(myi2c.fg_dev_addr)
    local low=myi2c.read_buffer[1]
    
    myi2c.read_bytes=1
    myi2c.read_data(myi2c.fg_dev_addr)
    local high=myi2c.read_buffer[1]
    
    print(low)
    print(high)
    
    return 0
end

function myi2c.read_fg()
    
    myi2c.fg_vbat()
    --myi2c.fg_devtype()
    --DEBUG
    myi2c.voltage=myi2c.fg_vbat()
    print("Battery voltage: " .. myi2c.voltage .. " mV")

    for i=1,6 do
        print(myi2c.raw_data[i])
    end
end

return myi2c

