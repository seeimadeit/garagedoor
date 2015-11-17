//
//  SignalViewController.swift
//  GarageDoor_Project
//
//  Created by Peter Hall on 10/12/15.
//  Copyright © 2015 Peter Hall. All rights reserved.
//

import UIKit
import CoreGraphics
import CustomParts

class SignalViewController: UIViewController , GaragedoorControllerSignalCallback{
    
    
    
    @IBOutlet var signalthing: Signalv2!
    var deviceName: String?
    @IBOutlet var indicator: UILabel!
    
    
    var needmore:Bool = false
    var last:Double = 0.0
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        needmore = true
        btservice.MonitorDeviceSignal(deviceName!,callback: self)
    }
    
    override func viewWillDisappear(animated: Bool) {
        needmore = false
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func GaragedoorControllerSignal(strength: NSNumber) -> Bool
    {
        print(strength)
        signalthing.signalstrength = Int(strength)
        last+=10
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.indicator.transform = CGAffineTransformMakeRotation(CGFloat(self.last.fromDegrees()!))
            
        })
        
    
        
        /*
        http://blog.industrialnetworking.com/2014/04/making-sense-of-signal-strengthsignal.html
        
        > -70 dBm  = Excellent
        -70 to -77
        -78 dBm to -85 dBm = Good
        -86 to -93
        -93 dBm to -100 dBm = Fair
        <-100 dBm = Poor
        -110 dBm = no signal
        */
        return needmore
    }
    
    
    func GaragedoorControllerSignalLost()
    {
        performSegueWithIdentifier("exit", sender: self)
    }
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
