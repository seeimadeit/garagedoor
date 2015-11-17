//
//  ViewController.swift
//  BlueToothLE_test
//
//  Created by Peter Hall on 9/16/15.
//  Copyright © 2015 Peter Hall. All rights reserved.
//
// http://www.raywenderlich.com/62435/make-swipeable-table-view-cell-actions-without-going-nuts-scroll-views

import UIKit
import CoreBluetooth
import CustomParts


// digest characteristic uuid =       "E1FB481A-445B-4F3F-975B-57C36D08821F"
// device & md5 characteristic uuid = "D6BAF795-EDAE-41E1-BED4-363B33FA9252"

class GarageDoorControllerViewController: UITableViewController ,GaragedoorControllerDelegate {
    
    
    let msgboxtitle = "Garage door controller"
    var timeout : Int = 3 // default 5 second
    var items : [String] = [String]()
    var tappedRow: NSIndexPath = NSIndexPath()
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl?.addTarget(self, action: Selector("DoScan"), forControlEvents: UIControlEvents.ValueChanged)
        self.view.backgroundColor = UIColor.blueColor()
        btservice.delegate = self
        
        dispatch_async(dispatch_get_main_queue()) {
            self.refreshControl?.beginRefreshing()
            btservice.ScanForDevices(self.timeout)
        }
    }
    func DoScan() {
        btservice.Stop(nil)
        
        print("DoScan")
        btservice.ScanForDevices(self.timeout)
    }
    override func viewWillDisappear(animated: Bool) {
        btservice.Stop(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func GaragedoorControllerClearDevices() {
        items.removeAll()
        tableView.reloadData()
    }
    
    func GaragedoorControllerFoundDevice(named: String) {
        print("found new device \(named)")
        
        items.append(named)
        self.tableView.reloadData()
    }
    
    
    func GaragedoorControllerScanStopped() {
        print("scan stopped")
        self.refreshControl?.endRefreshing()
    }
    
    
    func GaragedoorControllerNoPassword() {
        let msg = UIAlertController(title: msgboxtitle , message: "Device password is not set", preferredStyle: UIAlertControllerStyle.Alert)
        msg.addAction( UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        presentViewController(msg, animated: true, completion: nil)
        
    }
    
    func GaragedoorControllerNotSupported() {
        let msg = UIAlertController(title: msgboxtitle , message: "Bluetooth LE not supported", preferredStyle: UIAlertControllerStyle.Alert)
        msg.addAction( UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        // showViewController(msg, sender: nil) // do not use showViewController as it will cause a crash
        presentViewController(msg, animated: true, completion: nil)
    }
    
    func GaragedoorControllerSuccess() {
        self.view.backgroundColor = UIColor.greenColor()
    }
    
    func GaragedoorControllerNeedpasswordfor()
    {
        performSegueWithIdentifier("Settings", sender: self)
    }
    func GaragedoorControllerFailed() {
        self.view.backgroundColor = UIColor.orangeColor()
        performSegueWithIdentifier("Settings", sender: self)
    }
    
    func GaragedoorControllerReset() {
        self.view.backgroundColor = UIColor.blueColor()
    }
    
    @IBAction func optionsunwind(segue: UIStoryboardSegue)
    {
        // required for the unwind, but it's does nothing more
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell")!
        
        cell.textLabel?.text = items[indexPath.row]
        
        return cell
    }
    func buttonclicked(sender:UIButton)
    {
        print("buttonclicked")
    }
    
    @IBAction func onLongPress(sender: UILongPressGestureRecognizer) {
        
        print("on long presss")
        if (sender.state ==  UIGestureRecognizerState.Ended) {
          let cgpoint =  sender.locationInView(tableView)
          tappedRow = tableView.indexPathForRowAtPoint(cgpoint)!
            print(tappedRow)
        performSegueWithIdentifier("SignalView", sender: self)
        }
        
    }
    func checkforNoDevices() {
        if items.count == 0 {
            // Display a message when the table is empty
            let messageLabel = UILabel(frame: CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height))
            
            messageLabel.text = "No device found.\r\nPlease pull down to refresh."
            messageLabel.textColor = UIColor.lightTextColor()
            messageLabel.numberOfLines = 0;
            messageLabel.textAlignment = NSTextAlignment.Center
            messageLabel.font = UIFont(name: "System", size: 20)
            messageLabel.sizeToFit()
            
            self.tableView.backgroundView = messageLabel;
            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        } else {
            self.tableView.separatorStyle  = UITableViewCellSeparatorStyle.SingleLine
            self.tableView.backgroundView = nil
        }
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        checkforNoDevices()
        return items.count
    }
    
    
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        btservice.ConnectWithDevice(items[indexPath.row])
    }
    
    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        print("tapped \(indexPath)")
        tappedRow = indexPath
        performSegueWithIdentifier("SetupDevice", sender: self)
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print(segue)
        if segue.identifier == "SetupDevice" {
            let vc = segue.destinationViewController as! SetupVC
            vc.devicename = items[tappedRow.row]
        }
        if segue.identifier == "SignalView" {
            let vc = segue.destinationViewController as! SignalViewController
            
            vc.deviceName = items[tappedRow.row]
            print(vc.deviceName)
            
        }
    }
    
    
}

