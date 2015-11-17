//
//  SetupVC.swift
//  GarageDoor_Project
//
//  Created by Peter Hall on 9/29/15.
//  Copyright © 2015 Peter Hall. All rights reserved.
//

import UIKit

class SetupVC: UIViewController {

    var devicename: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
txtDevicename.text = devicename
        // Do any additional setup after loading the view.
    }

    @IBOutlet var txtDevicepassword: UITextField!
    @IBOutlet var txtDevicename: UITextField!
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func OnSetupDevice(sender: UIButton) {
        
        var devname = devicename
        if let _ = txtDevicename.text {
            devname = txtDevicename.text
        }
        if let pass = txtDevicepassword.text {
            btservice.SetupDevice(devicename!,password: pass, newdevicename: devname!)
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    // this is a delegate method, return false to ignore return key press
    // we will add extra functionally to hide the keyboard if the user presses
    // the returnkey
    // for this to work you must set the delegate (see viewDidLoad above)
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        // endEditing does hide the keyboard here - i tried it, however this works
        // you might want to test the textfield is the correct textfield before you
        // close the keyboard. (just saying)
        textField.resignFirstResponder()
        
        return false
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
