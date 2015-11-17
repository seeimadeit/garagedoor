//
//  Extensions.swift
//  testgyro
//
//  Created by Peter Hall on 5/12/15.
//  Copyright (c) 2015 Peter Hall. All rights reserved.
//

import UIKit
import Foundation


extension String {
    func toDouble() -> Double? {
        return NSNumberFormatter().numberFromString(self)?.doubleValue
    }
}

/*
var speedMPH:String {
var mph = speed * 2.2369362920544

return formatter.stringFromNumber(mph < 0 ? 0 : mph)! + " MPH"
}

var speedKMH:String {
var kmh = (speed * 3600.0) / 1000
return formatter.stringFromNumber(kmh < 0 ? 0 : kmh)! + " km/h"
}*/




// useful website : http://www.metric-conversions.org/length/meters-to-feet.htm
extension Double {
    func toDegrees() -> Double? {
        return ( self *  180.0 ) / 3.141
    }
    func fromDegrees() -> Double? {
        let formula = 3.141 / 180.0
        return self * formula
    }
    
    func fromMtoMiles() -> Double? {
        return  self * 0.00062137
    }
    
    func fromMtoKm() -> Double? {
        return  self  / 1000
    }
    
    func fromMtoft() -> Double? {
        return self * 3.2808
    }
}

extension Float {
    func toDegrees() -> Float? {
        return ( self *  180.0 ) / 3.141
    }
    func fromDegrees() -> Float? {
        let formula = Float(3.141 / 180.0)
        return self * formula
    }
    
    func fromMtoMiles() -> Float? {
        return  self * 0.00062137
    }
    
    func fromMtoKm() -> Float? {
        return  self  / 1000
    }
    
    func fromMtoft() -> Float? {
        return self * 3.2808
    }
}


extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    
}



