// Import libraries (BLEPeripheral depends on SPI)
#include <SPI.h>
#include <BLEPeripheral.h>
#include <MD5.h>
#include <EEPROM.h>

// define pins (varies per shield/board) - these values I've taken from TinySheild_NRF8001_BLE_Example
#define BLE_REQ   10 //
#define BLE_RDY   2 //
#define BLE_RST   9 //
#define LED 6

#define DOORPIN 8 // the relay to activate
#define PASSPIN 7 // button is enable password write.

// eprom
#define eprompasswordposition  0
#define epromlocalnameposition 10

#define dooruuid    "D6BAF795EDAE41E1BED4363B33FA9252"
#define digestuuid  "E1FB481A445B4F3F975B57C36D08821F"
#define ackuuid     "E337E5F0F9A64C369AD8D68056F602A1"
#define newpassword "872519870B484912AB3335086B5183AC"

char  devicepassword[9];                           // this is the device password
char localname[9];  // this is the localname (displays on the iphone app)
char        nonse[9];                                            // this is a generated random nonse
char        hashthisvalue[sizeof(devicepassword) + sizeof(nonse)]; // a place to store the prehash string


// create peripheral instance, see pinouts above
BLEPeripheral     blePeripheral     = BLEPeripheral(BLE_REQ, BLE_RDY, BLE_RST);

BLEService        doorcontroll      = BLEService(dooruuid);

BLECharacteristic switchthing       = BLECharacteristic(dooruuid, BLEWrite, 20);
BLEDescriptor     switchdescriptor  = BLEDescriptor("2901", "MD5");
BLECharacteristic digestnonse       = BLECharacteristic(digestuuid, BLERead, 8);
BLEDescriptor     digestdescriptor  = BLEDescriptor("2901", "nonse");
BLECharacteristic ack               = BLECharacteristic(ackuuid, BLENotify, 8);
BLEDescriptor     ackdescriptor     = BLEDescriptor("2901", "Ack");
BLECharacteristic newpass           = BLECharacteristic(newpassword, BLEWrite, 20);
BLEDescriptor     passdescriptor    = BLEDescriptor("2901", "Password");

//BLEBondStore      store             = BLEBondStore(10);

void setup() {

  Serial.begin(9600);
#if defined (__AVR_ATmega32U4__)
  while (!Serial); // wait for serial
#endif
  pinMode (DOORPIN, OUTPUT);
  pinMode (LED, OUTPUT);
  digitalWrite(LED,HIGH);
  //memset(devicepassword,0,sizeof(devicepass));
  EEPROM.get(eprompasswordposition, devicepassword);
  devicepassword[sizeof(devicepassword)] = '\0';
  EEPROM.get(epromlocalnameposition, localname);
  // cleanup the data - only valid characters
  for (int i = 9; i >= 0 ; i--)
  {
    if (localname[i] < ' ' || localname[i] >= 126 ) localname[i] = '\0';
  }
  // perform a trim
  for (int i = 9; i >= 0 ; i--)
  {
    if (localname[i] == ' ') localname[i] = '\0';
    if (localname[i] != '\0') break;
  }

  if (strlen(localname) == 0) strcpy(localname, "Garage Door");
  Serial.println(localname);
  blePeripheral.setLocalName(localname);
  //store.clearData();
  //blePeripheral.setBondStore(store);

  blePeripheral.setAdvertisedServiceUuid(doorcontroll.uuid());
  // add service and characteristics
  blePeripheral.addAttribute(doorcontroll);
  blePeripheral.addAttribute(switchthing);
  blePeripheral.addAttribute(switchdescriptor);
  blePeripheral.addAttribute(digestnonse);
  blePeripheral.addAttribute(digestdescriptor);
  blePeripheral.addAttribute(ack);
  blePeripheral.addAttribute(ackdescriptor);
  blePeripheral.addAttribute(newpass);
  blePeripheral.addAttribute(passdescriptor);
  // set device name and appearance
  blePeripheral.setDeviceName("RCDO"); // remote controlled door opener
  // https://developer.bluetooth.org/gatt/characteristics/Pages/CharacteristicViewer.aspx?u=org.bluetooth.characteristic.gap.appearance.xml
  blePeripheral.setAppearance(384); // Generic Remote Control

  // begin initialization
  blePeripheral.begin();
  // setup initial password
  randomSeed(analogRead(0)); // set the random sequence - this appears to work reasonably.
  digestnonse.setValue((unsigned char*)getNonse(nonse), 8);

  Serial.println(F("Garage Door - v2"));
  digitalWrite(LED,LOW);
}


void loop() {

  BLECentral central = blePeripheral.central();

  if (central) {

    while (central.connected()) {

      if (newpass.written() )
      {
        if (digitalRead(PASSPIN) == 0) {
          Serial.println("ok");

          int currentpos = 0; // keep track of the string length
          int maxsize = newpass.valueLength() - 1; // need this so we don't overrun
          char *d ;
          char *p = (char*)newpass.value(); // pointer to first character in the data
          memset(localname, 0, sizeof(localname));
          memset(devicepassword, 0, sizeof(devicepassword));
          d = devicepassword; // the destination set to devicepassword
          while (*p && maxsize != 0) {
            if (currentpos++ >= 8) break; // if we reach the max number of characters
            *d++ = *p++;
            maxsize--; // keep track of size
          }
          *d = '\0'; // make sure we terminate the string
          Serial.print("password:"); Serial.println(devicepassword);

          while (*p != '\0' && maxsize != 0 ) {
            *p++;  // need to check we are at the null character, if not advance to the null
            maxsize--;
          }

          *p++; // advance passed the null to the second data part

          currentpos = 0;
          d = localname;  // the destination set to localname
          Serial.print(devicepassword);
          while (*p && maxsize != 0) {
            if (currentpos++ >= 8) break; // if we reach the max number of characters
            *d++ = *p++;
            maxsize--; // keep track of size
          }

          *d++ = '\0'; // make sure we terminate the string.

          //    strncpy(devicepassword,(const char*)newpass.value(),sizeof(devicepassword));
          //    devicepassword[newpass.valueLength()] = '\0';
          // Serial.print("name:"); Serial.println(localname);
          if (strlen(localname) > 0)    {
            EEPROM.put(epromlocalnameposition, localname);
            blePeripheral.setLocalName(localname);
          }
          if (strlen(devicepassword) > 0)   EEPROM.put(eprompasswordposition, devicepassword);



        }
      } else {
        Serial.println("could");
      }
      if (switchthing.written() && switchthing.valueLength() == 16) {

        // build the string we need to calc a hash value for
        strcpy(hashthisvalue, devicepassword);
        strcat(hashthisvalue, nonse);

        unsigned char* hash = MD5::make_hash(hashthisvalue);
        //dont' forget to Give the Memory back to the System
        Serial.println("*****");
        Serial.println((char*)hash);
        Serial.println("***");
        Serial.println((char*)switchthing.value());

        // check it's what we are expecting
        if (memcmp((const char*)hash, (const char*)switchthing.value(), 16) == 0) {
          digitalWrite(DOORPIN, HIGH);       // Turn relay 1 on
          delay(1000);                      // Wait 1 second
          digitalWrite(DOORPIN, LOW);        // Turn relay 1 off

          // at the end of the activate get ready , setup a new password.
          digestnonse.setValue((unsigned char*)getNonse(nonse), 8);
          ack.setValue((const unsigned char*)"Success", 7);

        } else {
          ack.setValue((const unsigned char*)"Fail", 4);
        } // if memcmp


        free(hash);

      } // if switchthing written
    } // while connected
  } // central
} // loop


// produce a random nonse - in the ascii character range 33 to 126, which are visible glyphs
char *getNonse(char *pw)
{

  for (int indx = 0; indx < 8; indx++)
  {
    pw[indx] = (char)random(33, 126);
  }
  pw[8] = 0;
  return (pw);
}




