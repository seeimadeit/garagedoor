//
//  Signalv2.swift
//  GarageDoor_Project
//
//  Created by Peter Hall on 10/14/15.
//  Copyright © 2015 Peter Hall. All rights reserved.
//

import UIKit


@IBDesignable
public class Signalv2: UIControl {

    

    let colors:[UIColor] = [
        UIColor(red: 160, green: 13, blue: 0),
        UIColor(red: 237, green: 19, blue: 0),
        UIColor(red: 248, green: 188, blue: 0),
        UIColor(red: 252, green: 252, blue: 0),
        UIColor.greenColor(),
        UIColor   (red: 108, green: 204, blue: 68)
    ]
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    /*
    

    
    http://blog.industrialnetworking.com/2014/04/making-sense-of-signal-strengthsignal.html
    
    > -70 dBm  = Excellent
    -70 dBm to -85 dBm = Good
    -86 dBm to -100 dBm = Fair
    <-100 dBm = Poor
    -110 dBm = no signal
    
    
    my version
    
    > -70 dBm  = Excellent
    -70 to -77
    -78 dBm to -85 dBm = Good
    -86 to -93
    -93 dBm to -100 dBm = Fair
    <-100 dBm = Poor
    -110 dBm = no signal
    
    */
    
    private var signal:Int = 0
    
    @IBInspectable
    public var signalstrength:Int {
        get {
            return signal
        }
        set {
            let a = abs(newValue)
            signal = 0
            if a < 110 { signal = 0 }
            if a < 100 { signal = 1 }
            if a < 93  { signal = 2 }
            if a < 86  { signal = 3 }
            if a < 78 { signal = 4 }
            if a < 70  { signal = 5 }
            setNeedsDisplay()
        }
    }
    
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override public func drawRect(rect: CGRect) {
        // Drawing code
        
        
        let divisions = self.frame.height / 6
        
        UIColor.redColor().set()
        for i in 0...signal {
            
            
            let rc = CGRectMake(self.frame.origin.x, CGFloat(i) * divisions, self.frame.width, divisions)
            
            
            colors[i].set()
            
            UIRectFill(rc)
            
        }
        
    }


}
