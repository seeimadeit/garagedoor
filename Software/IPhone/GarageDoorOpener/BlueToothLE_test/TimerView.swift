//
//  TimerView.swift
//  BlueToothLE_test
//
//  Created by Peter Hall on 9/21/15.
//  Copyright © 2015 Peter Hall. All rights reserved.
//

import UIKit

@IBDesignable
public class TimerView: UIControl {
    
    var view:UIView
    
    @IBOutlet var lblMin: UILabel!
    @IBOutlet var lblSec: UILabel!
    @IBOutlet var txtMinutes: UITextField!
    @IBOutlet var txtSeconds: UITextField!
    @IBOutlet var sldTimeout: UISlider!
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
    // Drawing code
    }
    */
    
    override init(frame: CGRect) {
        view = UIView()
        super.init(frame: frame)
        load()
    }
    required public init(coder aDecoder: NSCoder) {
        view = UIView()
        super.init(coder: aDecoder)!
        load()
    }
    
    @IBInspectable
    var backColor: UIColor {
        get {
            return view.backgroundColor!
        }
        set {
            view.backgroundColor = newValue
        }
    }
    
    
    @IBInspectable
    var foreColor: UIColor {
        get {
            return lblMin.textColor
        }
        set {
            lblMin.textColor = newValue
            lblSec.textColor = newValue
        }
    }

    
    @IBInspectable
    public var Value: Int {
        get {
            return Int( sldTimeout.value)
        }
        set {
            sldTimeout.value = Float(newValue)
            OnSliderChange(sldTimeout)
        }
    }
    
   func load()
    {
        
        view = (NSBundle(forClass: TimerView.self).loadNibNamed("TimerView", owner: self, options: nil)[0] as! UIView)
        view.frame = self.bounds
        //   view.autoresizingMask = UIViewAutoresizing.FlexibleHeight.rawValue | UIViewAutoresizing.FlexibleWidth.rawValue
        self.addSubview(view)
        
        
    }
    
    
    @IBAction func OnSliderChange(sender: UISlider) {
      let seconds =  Int(sender.value)
    
        let mins = seconds / 60
        let secs = seconds % 60

        txtMinutes.text = String(format: "%0d", arguments: [mins])
        txtSeconds.text = String(format: "%02d", arguments: [secs])
        
        self.sendActionsForControlEvents(UIControlEvents.ValueChanged)
        
    }
    
    
   }
