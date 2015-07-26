import RPi.GPIO as GPIO

GPIO.setmode(GPIO.BCM)

GPIO.setup(35, GPIO.IN)

while True:
    print GPIO.input(35)