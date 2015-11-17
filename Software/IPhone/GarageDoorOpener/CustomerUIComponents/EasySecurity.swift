//
//  EasySecurity.swift
//  BlueToothLE_test
//
//  Created by Peter Hall on 9/22/15.
//  Copyright © 2015 Peter Hall. All rights reserved.
//

import UIKit
/**
EasySecurity Class

Simple api access to save and read your passwords into the IOS keychain.

* Save("GarageDoorx", name: "password", value: "avalue")
* Read("GarageDoorx",name: "password")
* Delete("GarageDoorx",name: "password")

Throws KeychainError
*    NotFound
*    KeyChainError(errorcode:Int32)

error codes are from [OS X Keychain Services]

[OS X Keychain Services]: https://developer.apple.com/library/ios/documentation/Security/Reference/keychainservices/ "Apple Developer URL"


*/
public class EasySecurity: NSObject {
    enum KeychainError : ErrorType {
        case NotFound
        case KeyChainError(errorcode:Int32)
    }
    

    private func getQuery(service: String, name: String) -> [String:AnyObject] {
        var query:[String:AnyObject] = [String:AnyObject]()
        
        query[kSecClass as String] = kSecClassGenericPassword
        query[kSecAttrService as String] = service
        query[kSecAttrAccount as String] = name
        
        return query
    }
    
    /**
    ````
    var password:String
    do {
    password = try Read("GarageDoorx",name: "password")
    
    print("got \(password)")
    } catch let error {
    print ("got an error \(error)")
    }
    ````
    error codes are from [OS X Keychain Services]
    
    [OS X Keychain Services]: https://developer.apple.com/library/ios/documentation/Security/Reference/keychainservices/ "Apple Developer URL"
  */
    public func Read(service: String, name: String) throws -> String {
        var query = getQuery(service, name: name)
        

        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnData as String] = kCFBooleanTrue
        
        var result: AnyObject?
        let status2 = withUnsafeMutablePointer(&result) { SecItemCopyMatching(query, UnsafeMutablePointer($0)) }
        if status2 == errSecSuccess {
            let data = result as? NSData
            let password = String(data: data!, encoding: NSUTF8StringEncoding)
            return password!
        } else {
            throw KeychainError.NotFound
        }
        
    } // read
/**
    ````
      let _ = try? Delete("GarageDoorx",name: "password")
    ````
    error codes are from [OS X Keychain Services]
    
    [OS X Keychain Services]: https://developer.apple.com/library/ios/documentation/Security/Reference/keychainservices/ "Apple Developer URL"

*/
    public func Delete(service:String, name: String) throws
    {
        let query = getQuery(service, name: name)
        let status = SecItemDelete(query)
        if status != errSecSuccess {
            throw KeychainError.KeyChainError(errorcode: status)
        }
        
    } // delete
/**
    ````
    do {
    try  Save("GarageDoorx", name: "password", value: "avalue")
    
    }
    catch let err {
       print(err)
    }

    ````
    error codes are from [OS X Keychain Services]
    
    [OS X Keychain Services]: https://developer.apple.com/library/ios/documentation/Security/Reference/keychainservices/ "Apple Developer URL"

*/
    public func Save(service: String, name: String, value: String) throws {
        var query = getQuery(service, name: name)
        query[kSecAttrAccessible as String] =  kSecAttrAccessibleWhenUnlocked
        
        let status = SecItemCopyMatching(query, nil)
        if status == errSecSuccess {
            // found it so just update
            var update:[String:AnyObject] = [String:AnyObject]()
            update[kSecValueData as String] = value.dataUsingEncoding(NSUTF8StringEncoding)
            let err = SecItemUpdate(query, update)
            if err != errSecSuccess {
                throw KeychainError.KeyChainError(errorcode: err)
            }
        } else if status == errSecItemNotFound {
            // not found so add it
            query[kSecValueData as String] = value.dataUsingEncoding(NSUTF8StringEncoding)
            let err = SecItemAdd(query, nil)
            if err != errSecSuccess {
                throw KeychainError.KeyChainError(errorcode: err)
            }
        } else {
            throw KeychainError.KeyChainError(errorcode: status)
        }
        
    } // save

    
}
