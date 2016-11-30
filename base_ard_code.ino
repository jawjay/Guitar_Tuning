GIT REPO LINK:
https://github.com/jawjay/Guitar_Tuning



Arduino stepper code

/*
   BYJ48 Stepper motor code
   Connect :
   IN1 >> D8
   IN2 >> D9
   IN3 >> D10
   IN4 >> D11
   VCC ... 5V Prefer to use external 5V Source
   Gndc
   Adapted from code found at:
  http://www.instructables.com/member/Mohannad+Rawashdeh/
  
  Written by Mark Jajeh
  */


// set digital input pins for motor
#define IN1  8
#define IN2  9
#define IN3  10
#define IN4  11


int Steps = 0; // Records which wiring orientatation motor is currently at
boolean Direction = true;// gre

unsigned long last_time; // records time of motor step, used to insure signal is not sent to motor too fast
unsigned long currentMillis ; 
int steps_left = 4095; // use this variable to iterate over some number of steps
long time;
void setup()
{
  Serial.begin(115200);
  pinMode(IN1, OUTPUT);
  pinMode(IN2, OUTPUT);
  pinMode(IN3, OUTPUT);
  pinMode(IN4, OUTPUT);
  // delay(1000);

}
void loop()
{
    basic_rotate();
}


void basic_rotate(){
  move_x_steps(steps_left);
  Serial.println(time);
  Serial.println("Wait...!");
  delay(2000);
  Direction = !Direction;
  steps_left = 4095;
}

void right_write(){
  // function to move motor one step
  // handles all the different motor orientations as well as recycling the direction after orientation 8
  switch (Steps) {
      case 0:
        digitalWrite(IN1, LOW);
        digitalWrite(IN2, LOW);
        digitalWrite(IN3, LOW);
        digitalWrite(IN4, HIGH);
        break;
      case 1:
        digitalWrite(IN1, LOW);
        digitalWrite(IN2, LOW);
        digitalWrite(IN3, HIGH);
        digitalWrite(IN4, HIGH);
        break;
      case 2:
        digitalWrite(IN1, LOW);
        digitalWrite(IN2, LOW);
        digitalWrite(IN3, HIGH);
        digitalWrite(IN4, LOW);
        break;
      case 3:
        digitalWrite(IN1, LOW);
        digitalWrite(IN2, HIGH);
        digitalWrite(IN3, HIGH);
        digitalWrite(IN4, LOW);
        break;
      case 4:
        digitalWrite(IN1, LOW);
        digitalWrite(IN2, HIGH);
        digitalWrite(IN3, LOW);
        digitalWrite(IN4, LOW);
        break;
      case 5:
        digitalWrite(IN1, HIGH);
        digitalWrite(IN2, HIGH);
        digitalWrite(IN3, LOW);
        digitalWrite(IN4, LOW);
        break;
      case 6:
        digitalWrite(IN1, HIGH);
        digitalWrite(IN2, LOW);
        digitalWrite(IN3, LOW);
        digitalWrite(IN4, LOW);
        break;
      case 7:
        digitalWrite(IN1, HIGH);
        digitalWrite(IN2, LOW);
        digitalWrite(IN3, LOW);
        digitalWrite(IN4, HIGH);
        break;
      default:
        digitalWrite(IN1, LOW);
        digitalWrite(IN2, LOW);
        digitalWrite(IN3, LOW);
        digitalWrite(IN4, LOW);
        break;
    }
    SetDirection();// updates Steps variable 

}

void stepper(int number_of_steps) {
  // function to step motor number of steps
  // right_write() handles all the stepper specifics
  for (int x = 0; x < number_of_steps; x++) {
    right_write();
  }
}

void move_x_steps(int x_steps) {
    while (x_steps > 0) {
    currentMillis = micros();
    if (currentMillis - last_time >= 1000) { // making sure motor has enough time to move and settle down
      stepper(1); // 
      time = time + micros() - last_time;
      last_time = micros(); 
      x_steps--;
    }
  }

}

void SetDirection() {
  // function to update steps variable after a step has been sent to motor
  // Steps variable is updated based on current direction 
  if (Direction == 1) {
    Steps++;
  }
  if (Direction == 0) {
    Steps--;
  }
  if (Steps > 7) {
    Steps = 0;
  }
  if (Steps < 0) {
    Steps = 7;
  }
}


