whoami > /home/pi/user
sleep 2
cd /home/pi/Quadcopter
git pull > /home/pi/log
python Controller/server.py
