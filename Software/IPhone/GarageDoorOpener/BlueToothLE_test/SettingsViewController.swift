//
//  SettingsViewController.swift
//  BlueToothLE_test
//
//  Created by Peter Hall on 9/21/15.
//  Copyright © 2015 Peter Hall. All rights reserved.
//

import UIKit
import CustomParts



class SettingsViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var txtPasswordField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // swipe gesture is used to call the exit segue

        txtPasswordField.delegate = self
        // Do any additional setup after loading the view.
        
        if let theuserpassword = try? EasySecurity().Read("GarageDoor", name: passworddeviceuuid!.UUIDString) {
            
            txtPasswordField.text = theuserpassword
            
        }
    }
 
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func OnSaveClicked(sender: UIButton) {
        // the storyboard is connected to this method and also the exit segue
       
        if txtPasswordField.text!.isEmpty == false {
            do {
                try EasySecurity().Save("GarageDoor", name: passworddeviceuuid!.UUIDString, value: txtPasswordField.text!)
                
            }
                
            catch (let error)
            {
                let _ = try? EasySecurity().Delete("GarageDoor", name: passworddeviceuuid!.UUIDString)
                let _ = try? EasySecurity().Save("GarageDoor", name: passworddeviceuuid!.UUIDString, value: txtPasswordField.text!)
                print("error saving password, need to handle \(error)")
            }
            
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
