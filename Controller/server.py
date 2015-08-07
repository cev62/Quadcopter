import sys
import socket
from thread import *
import serial
import time
import threading
import subprocess



HOST = ""
PORT = 22333

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
print 'socket created'

try : 
    s.bind((HOST, PORT))
except socket.error, msg :
    print 'bind failed' + str(msg[0]) + 'message ' + msg[1]
    sys.exit()
    
print 'bind complete'

s.listen(10)
print 'listening...'

commands = "0,0,0,0"

c_lock = threading.Lock()

# Serial Thread
def serialThread(x):
    global commands
    global c_lock
    ser = None
    while True:
        if ser == None:
            try:
                ser = serial.Serial(port='/dev/ttyACM0', baudrate=115200)
            except:
                ser = None
                continue
        c_lock.acquire()
        cmd = commands.split(",")
        c_lock.release()
        out = [1]
        for c in cmd:
           out.append(int(c))
           if out[len(out) - 1] < 1:
               out[len(out) - 1] = 0
        ser.write(out)
        print("To uno: " + str(out))
        
        buf = ""
        while ser.inWaiting() > 0:
            serData = ser.read(1)
            if serData == "\n":
                break
            buf += serData
        print("From Uno: " + buf)
        time.sleep(0.010)
 
start_new_thread(serialThread, (1,))
 
def clientthread(conn):                                         
    global commands
    global c_lock
    print 'opening client'
    conn.send('Welcome to the server...\n')
    
    while True:
        data = conn.recv(1024)
        c_lock.acquire()
        commands = data.split("$")[0]
        c_lock.release()
        state_cmd = commands.split(",")[0]
        print(commands)

        if state_cmd == "RUN":
            pass
        elif state_cmd == "STOP":
            pass
        elif state_cmd == "DOWNLOAD_CODE":
            subprocess.Popen("./download-code.sh".split(" "))
            sys.exit(0)
        elif state_cmd == "POWER_OFF":
            subprocess.Popen("sudo halt".split(" "))
        
            
        reply = 'OK3...' + data
        conn.sendall(reply)
        time.sleep(0.010);
        if not data:
	        break
    print 'closing client'	
    conn.close()
 
while True:
    conn, addr = s.accept()

    print 'Connected with ' + addr[0] + ':' + str(addr[1])

    start_new_thread(clientthread, (conn,))
    
#data = conn.recv(1024)
#conn.sendall(data + "goodbye worldsfja;flkj")

#message = "Goodbye world\n"
#conn.sendall(message)

#conn.close()
s.close()
