//
//  MD5.swift
//  BlueToothLE_test
//
//  Created by Peter Hall on 9/19/15.
//  Copyright © 2015 Peter Hall. All rights reserved.
//

import Foundation


extension String {
    func MD5() -> String {
        let data = (self as NSString).dataUsingEncoding(NSUTF8StringEncoding)
        let result = NSMutableData(length: Int(CC_MD5_DIGEST_LENGTH))
        let resultBytes = UnsafeMutablePointer<CUnsignedChar>(result!.mutableBytes)
        CC_MD5(data!.bytes, CC_LONG(data!.length), resultBytes)
        
       
        let a = UnsafeBufferPointer<CUnsignedChar>(start: resultBytes, count: result!.length)

        let hash = NSMutableString()
        
        for i in a {
            hash.appendFormat("%02x", i)
        }
        print("size \(hash.length)")
        return hash as String

    }
    
    func MD5NSData() -> NSData {
        let data = (self as NSString).dataUsingEncoding(NSUTF8StringEncoding)
        let result = NSMutableData(length: Int(CC_MD5_DIGEST_LENGTH))
        let resultBytes = UnsafeMutablePointer<CUnsignedChar>(result!.mutableBytes)
        CC_MD5(data!.bytes, CC_LONG(data!.length), resultBytes)
        
        
      //  let a = UnsafeBufferPointer<CUnsignedChar>(start: resultBytes, count: result!.length)
              return result!
        
    }

}