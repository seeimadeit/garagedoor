//
//  SignalView.swift
//  GarageDoor_Project
//
//  Created by Peter Hall on 10/12/15.
//  Copyright © 2015 Peter Hall. All rights reserved.
//

import UIKit

@IBDesignable
public class SignalView: UIControl {

    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override public func drawRect(rect: CGRect) {
        // Drawing code
        print("draw")
        // Get the Graphics Context
        let context = UIGraphicsGetCurrentContext();
        
        // Set the circle outerline-width
        CGContextSetLineWidth(context, 5.0);
        
        // Set the circle outerline-colour
        UIColor.redColor().set()
        
        // Create Circle
        CGContextAddArc(context, (frame.size.width)/2, frame.size.height/2, (frame.size.width - 10)/2, 0.0, CGFloat(M_PI * 2.0), 1)
        
        // Draw
        CGContextStrokePath(context);
    }
    

}
