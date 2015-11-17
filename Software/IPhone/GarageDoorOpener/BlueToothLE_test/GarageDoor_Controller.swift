//
//  Bluetooth_Central.swift
//  BlueToothLE_test
//
//  Created by Peter Hall on 9/20/15.
//  Copyright © 2015 Peter Hall. All rights reserved.
//

import Foundation
import CoreBluetooth
import CustomParts

// shared information between GarageDoor_Controller and SettingsViewController
var passworddeviceuuid:NSUUID? = nil
let btservice = GaragedoorController()

protocol GaragedoorControllerDelegate
{
    func GaragedoorControllerNotSupported() // this will never happen because the 'require device capabilities are set to bluetooth le
    func GaragedoorControllerSuccess() // the activate was a success
    func GaragedoorControllerFailed() // the activie failed, a password failure
    func GaragedoorControllerReset()  // called after a success or fail, with a pause between them
    func GaragedoorControllerScanStopped() // when the scan has finished (after a timeout), or the Stop method was called
    func GaragedoorControllerFoundDevice(named: String) // when a device is located the name is returned here - note: duplicate names are suffixed with a number
    func GaragedoorControllerClearDevices() // before a scan is started the delegate should cleanup it's found devices to allow for a refreshed list
    func GaragedoorControllerNeedpasswordfor() // if a new device is found and we need the password, it's asked for here.
}

protocol GaragedoorControllerSignalCallback
{
    func GaragedoorControllerSignal(strength: NSNumber) -> Bool
    func GaragedoorControllerSignalLost()
}


// used to keep a track of the devices
struct deviceitem {
    let name                    : String
    let peripheral              : CBPeripheral
    var md5characteristic       : CBCharacteristic?
    var newpassword             : CBCharacteristic?
}

class GaragedoorController : NSObject, CBCentralManagerDelegate , CBPeripheralDelegate {
    
    var centralmgr              : CBCentralManager?
    
    let deviceuuid              : [CBUUID] = [ CBUUID(string: "D6BAF795-EDAE-41E1-BED4-363B33FA9252")]
    let nonseuuid               : [CBUUID] = [ CBUUID(string: "E1FB481A-445B-4F3F-975B-57C36D08821F")]
    let ackuuid                 : [CBUUID] = [ CBUUID(string: "E337E5F0-F9A6-4C36-9AD8-D68056F602A1")]
    let newpassworduuid         : [CBUUID] = [ CBUUID(string: "87251987-0B48-4912-AB33-35086B5183AC")]
    
    var founddevices            : [NSUUID: deviceitem ] = [NSUUID: deviceitem]()
    var nameddevices            : [String:Int] = [String:Int]()
    
    var delegate                : GaragedoorControllerDelegate?
    var devicepasswordsetup     : Bool
    var thenewdevicepasswordis  : String
    var signalstrength          : Bool
    
    var signalcallback          : GaragedoorControllerSignalCallback?
    
    override init()
    {
        devicepasswordsetup = false
        signalstrength = false
        thenewdevicepasswordis = ""
        super.init()
        centralmgr  = CBCentralManager(delegate: self, queue: dispatch_get_main_queue())
    }
    
    func ScanForDevices(timeout: Int)
    {
        founddevices.removeAll()
        nameddevices.removeAll()
        delegate?.GaragedoorControllerClearDevices()
        print("scanforDevices")
        centralmgr!.scanForPeripheralsWithServices(deviceuuid, options: nil)
        NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(timeout), target: self, selector: Selector("Stop:"), userInfo: nil, repeats: false )
    }
    
    
    func Stop(sender: AnyObject? )
    {
        // stop the bluetooth scan , if it's not scanning it doesn't complain, if it is scanning it will stop.
        print("Stopped")
        centralmgr?.stopScan()
        if sender != nil {
            delegate?.GaragedoorControllerScanStopped()
        }
    }
    // check if the device has bluetooth LE support, if not display an error message
    @objc func centralManagerDidUpdateState(central: CBCentralManager) {
        
        if central.state == CBCentralManagerState.Unsupported {
            delegate?.GaragedoorControllerNotSupported()
        }
    }
    
    
    // if we discover a device, it must be the one we are looking for because we specified the uuid in the scan
    // so we save the peripheral.
    // note if you do not save the peripheral you cannot do anything else because it will be destroyed when the
    // method exits.
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        
        if let localname = advertisementData[CBAdvertisementDataLocalNameKey]
        {
            print("named \(peripheral.name)")
            print("ident \(peripheral.identifier.UUIDString)")
            print(" \(peripheral) : \(RSSI) : \(localname)")
            
            var nameid = peripheral.name
            if let _ = founddevices[peripheral.identifier] {
                // found the same device - this can happen, I've seen it when the device has changed name, but the iphone see's both the old and new names
            } else {
                nameid = getname(localname as! String)
                founddevices[peripheral.identifier] = deviceitem(name: nameid!, peripheral: peripheral,md5characteristic: nil, newpassword: nil)
                // we need to set the delegate or no messages will be delivered
                peripheral.delegate = self
                delegate?.GaragedoorControllerFoundDevice(nameid!)
            }
        } else {
            print("the impossible has happen, localname is blank for \(peripheral)")
        }
        
    }
    
    func getname(localname: String) -> String {
        var usename = localname
        if let count = nameddevices[usename] {
            nameddevices[usename] = count+1
            usename = "\(localname)\(count+1)"
        } else {
            nameddevices[usename] = 0
        }
        return usename
    }
    
    func ConnectWithDevice(named: String) -> ()
    {
        for (_,device) in founddevices where device.name == named
        {
            // we have the device so connect to it.
            devicepasswordsetup = false
            centralmgr!.connectPeripheral(device.peripheral, options: nil)
        }
    }
    
    func SetupDevice(named: String, password: String, newdevicename: String) -> ()
    {
        for (_,device) in founddevices where device.name == named
        {
            // we have the device so connect to it.
            thenewdevicepasswordis = password + "\0" + newdevicename
            devicepasswordsetup = true
            centralmgr!.connectPeripheral(device.peripheral, options: nil)
        }
        
    }
    
    func MonitorDeviceSignal(named: String, callback : SignalViewController) ->()
    {
        for (_,device) in founddevices where device.name == named
        {
            // we have the device so connect to it.
            signalstrength = true
            signalcallback = callback
            centralmgr!.connectPeripheral(device.peripheral, options: nil)
        }

    }
    
    
    
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print("didDisconnectPeripheral")
        signalcallback?.GaragedoorControllerSignalLost()
    }
    
    // must perform a discover or we can't use the thing.
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        if signalstrength == false {
            // only perform discovery if not looking at the signal
            peripheral.discoverServices(deviceuuid)
        } else {
            peripheral.readRSSI()
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: NSError?) {
        if true == signalcallback?.GaragedoorControllerSignal(RSSI)
        {
            peripheral.readRSSI()
        } else {
            centralmgr?.cancelPeripheralConnection(peripheral)
            signalcallback = nil
        }

    }
  /*  func peripheralDidUpdateRSSI(peripheral: CBPeripheral, error: NSError?) {
            if true == signalcallback?.GaragedoorControllerSignal(peripheral.RSSI!)
            {
                    peripheral.readRSSI()
            } else {
                centralmgr?.cancelPeripheralConnection(peripheral)
                signalcallback = nil
        }
    }
    */
    
    // after the services are found , find the characteristics
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        for service in  peripheral.services! where service.UUID == deviceuuid[0] {
            peripheral.discoverCharacteristics(/*uuids*/nil, forService: service)
        }
    }
    
    // when we find the characteristic we write some data to it. we don't care what the data is.
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        for characteristics in service.characteristics! {
            print("found digest \(characteristics.UUID)")
            
            if characteristics.UUID == ackuuid[0] {
                peripheral.setNotifyValue(true, forCharacteristic: characteristics)
            }
            if characteristics.UUID == nonseuuid[0] && devicepasswordsetup == false {
                
                peripheral.readValueForCharacteristic(characteristics)
            }
            if characteristics.UUID == deviceuuid[0] {
                // we will need this later, so store it
                founddevices[peripheral.identifier]?.md5characteristic = characteristics
            }
            if characteristics.UUID == newpassworduuid[0]  && devicepasswordsetup == true {
                founddevices[peripheral.identifier]?.newpassword = characteristics
                peripheral.writeValue(thenewdevicepasswordis.dataUsingEncoding(NSUTF8StringEncoding)!, forCharacteristic: characteristics, type: CBCharacteristicWriteType.WithResponse)
            }
        }// for char
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        print("didUpdateNotifictionStateForCharacteristic \(characteristic)")
    }
    
    
    // a confirmation the data was written.
    func peripheral(peripheral: CBPeripheral, didWriteValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        print("did write \(characteristic)" )
        if characteristic.UUID == newpassworduuid[0] {
            centralmgr?.cancelPeripheralConnection(peripheral)
            print("password was set")
        }
    }
    
    
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        
        if characteristic.UUID == ackuuid[0] {
            let datastring = NSString(data: characteristic.value!, encoding:NSUTF8StringEncoding)
            print("got ack \(datastring) ")
            centralmgr?.cancelPeripheralConnection(peripheral)
            
            if datastring! == "Success" {
                delegate?.GaragedoorControllerSuccess()
            } else if datastring! == "Flash" {
                
                } else {
                passworddeviceuuid = peripheral.identifier
                delegate?.GaragedoorControllerFailed()
            }
            NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("resetview"), userInfo: nil, repeats: false )
        } else if characteristic.UUID == nonseuuid[0] {
            let digest =  String(data: characteristic.value!, encoding: NSUTF8StringEncoding)
            print("didUpdateValueForCharacteristic \(digest)")
            if let theuserpassword = try? EasySecurity().Read("GarageDoor", name: peripheral.identifier.UUIDString) {
                print(theuserpassword)
                let getmd5fromvalue = (theuserpassword + digest!).MD5NSData()
                
                print( getmd5fromvalue )
                
                peripheral.writeValue(getmd5fromvalue, forCharacteristic: (founddevices[peripheral.identifier]?.md5characteristic)!, type: CBCharacteristicWriteType.WithResponse)
            } else {
                // no password for the device.
                passworddeviceuuid = peripheral.identifier
                delegate?.GaragedoorControllerNeedpasswordfor()
            }
            
        }
    }
    
    
    // called from a timer in didUpdateValueForCharacteristic
    func resetview() {
        delegate?.GaragedoorControllerReset()
    }
    
}