import serial

ser = serial.Serial(port='/dev/ttyACM0', baudrate=115200)

ser.open()
while True:
    buf = ''
    while True:
        while ser.inWaiting() > 0:
            next = ser.read(1)
            if next == '\n':
                break
            buf += next
        if buf != '':
            print buf
            buf = ''