/*
 Snowforce.ino
 Copyright (c) 2014 Kitronyx http://www.kitronyx.com
 GPL V3.0
*/

#include "Keyboard.h"
#include <Wire.h>
#include <Snowforce.h>

Snowforce snowforce;

const char threshold = 16;
const char debounceCount = 2;
const char keymap[] = {
  0, '4', 0, 0, 'd', 0, 0, 0, 0, 0,
  '1', 0, '2', 0, 'a', 0, 'b', 0, 0, 0,
  0, '3', 0, 0, 'c', 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0,   // 40~49
  0, 8, 0, 0, 0, 0, 0, 0, 13, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, '7', 0, 0, 0, 0, 0, 0, 0, 0,   // 90~99
  '5', 0, '6', 0, 0, 0, 0, 0, 0, 0,
  0, '8', 0, 0, 0, 0, 0, 0, 0, 0,
  0, 'y', 0, 0, 0, 0, 0, 0, 0, 0,
  '9', 0, '0', 0, 0, 0, 0, 0, 0, 0,
  0, 'z', 0, 0, 0, 0, 0, 0, 0, 0,   // 140~149
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0
};

int key = 0;        // key value set for keyboard event
int btn = -1;       // pressed button id
int debounce = 0;
int shift = 0;

// pressure mapping data
// tactile sensing part always give maximum
// number of data (10x16 = 160)
byte data[160] = {0, };


void setup()
{
  Wire.begin();           // start i2c communication
  Serial.begin(115200);   // start serial for output
  Keyboard.begin();       // start HID keyboard
  snowforce.begin();      // start tactile sensing part of snowboard
}

void loop()
{
  // read force matrix
  snowforce.read(data);

  // scan matrix when no button pressed
  if (key == 0) {
    // if (btn > 0) {
    //   Serial.print(btn);
    //   Serial.print(':');
    //   Serial.println(data[btn]);
    // }
    if (btn > 0 && data[btn] > threshold) {
      debounce++;

      if (debounce > debounceCount-1) {
        key = keymap[btn];
        debounce = 0;
        if (key > 0) {
          Serial.print("key:");
          Serial.println(key);
          
          Keyboard.press(key);
        }
      }
    }
    else {
      btn = 0;
      for (int i = 0; i < 160; i++)
      {
        if (data[i] > threshold) {
          Serial.print("Btn:");
          Serial.println(i);
          btn = i;
          debounce = 0;
          break;
        }
      }
    }
  }
  else {
    if (data[btn] <= threshold) debounce++;
    else debounce = 0;

    if (debounce > debounceCount) {
      Keyboard.releaseAll();
      debounce = 0;
      btn = -1;
      key = 0;
    }
  }
}
