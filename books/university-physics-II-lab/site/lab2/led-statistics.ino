// Lab: LED Forward Voltage Measurements (Data Collection Only)
// Students will record raw voltage data and perform ALL analysis separately.
//
// Circuit:
//   D8 -> R -> LED -> GND
//   A0 connected to LED anode
//   A1 connected to LED cathode
//
// What this code does:
// - Turns the LED ON at constant DC (no PWM)
// - Records 20 measurements of LED forward voltage Vf = V(A0) - V(A1)
// - Prints each measurement as a table students can copy into a notebook
//
// Serial Monitor settings:
//   Baud rate: 9600
//   Line ending: Newline
//
// Student workflow:
// 1. Insert LED
// 2. Press 'r' + ENTER
// 3. Copy the 20 Vf values into Jupyter
// 4. Swap LED and repeat

const int PIN_SUPPLY  = 8;
const int PIN_ANODE   = A0;
const int PIN_CATHODE = A1;

const int N = 20;              // measurements per LED
const int settle_ms = 100;     // wait after turning LED on
const int sample_delay_ms = 100;

double readVoltage(int pin) {
  int raw = analogRead(pin);           // 0–1023
  return raw * (5.0 / 1023.0);         // volts (assumes 5.0 V reference)
}

void setup() {
  Serial.begin(9600);
  pinMode(PIN_SUPPLY, OUTPUT);
  digitalWrite(PIN_SUPPLY, LOW);

  // Stabilize ADC
  analogRead(PIN_ANODE);
  analogRead(PIN_CATHODE);

  Serial.println("=== LED Forward Voltage Data Collection ===");
  Serial.println("Press 'r' + ENTER to record 20 measurements for one LED.");
  Serial.println("Columns: trial, Vf (V)");
  Serial.println();
  Serial.println("trial,Vf_V");
}

void loop() {
  if (!Serial.available()) return;

  char c = Serial.read();
  while (Serial.available()) Serial.read();  // clear buffer

  if (c != 'r' && c != 'R') return;

  digitalWrite(PIN_SUPPLY, HIGH);
  delay(settle_ms);

  for (int i = 1; i <= N; i++) {
    double Va = readVoltage(PIN_ANODE);
    double Vc = readVoltage(PIN_CATHODE);
    double Vf = Va - Vc;

    Serial.print(i);
    Serial.print(",");
    Serial.println(Vf, 5);

    delay(sample_delay_ms);
  }

  digitalWrite(PIN_SUPPLY, LOW);

  Serial.println();
  Serial.println("=== End of run ===");
  Serial.println("Swap LED, then press 'r' + ENTER to start next run.");
  Serial.println();
}
