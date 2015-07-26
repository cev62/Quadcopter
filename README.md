# Quadcopter
A control system for a quadcopter I plan to build. Uses an Arduino controller on board, with a Processing sketch communicating to the quadcopter via bluetooth.

 
Powering up the ESC's. This method worked (1-4 are one time only):

1. Power on via pwm cable with arduino outputing high trottle.
2. Wait for settings mode beeping.
3. In the middle of the first four beeps, lower throttle to < half and wait for two conformation beeps.
4. Once settings mode beeping resumes, cut power to esc.
5. Apply power to esc via pwm cable with arduino outputing low throttle. Beeps will begin indicating that power from li-po is not there (Sometimes they might not beep).
6. Apply power via the battery pack. Beeps should stop
7. Slowly raise throttle until 2 confirmation beeps occur (at ~halfway). This means the esc is in working mode
8. Keep raising the throttle and the motor should turn on. If it doesn't, lower the throttle back to 0 and raise it again.
9. After the motor is turned on, if the throttle is lowered to 0, there may be simple beeping. This is fine, the motor will still work if you raise the throttle again.