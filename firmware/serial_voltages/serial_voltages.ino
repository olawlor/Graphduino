/*
 Arduino firmware to read the voltages from pins A0-A5, 
 and send them out the serial port.
 
 Designed for 5V Arduino Uno R3.

 (Public Domain)
*/
const int srcPin=A0; // data source
const int srcPinN=6; // number of pins

void setup() {
  Serial.begin(9600); // set baud rate for serial comms
  Serial.println("Sending serial data..."); 
}

void loop() {
  for (int i=0;i<srcPinN;i++) {
    int rawV = analogRead(srcPin+i);
    float V = rawV * (5.0/1023.0);
    Serial.print(V);
    Serial.print(",");
  }
  Serial.println(); // newline

  delay(20); 
}
