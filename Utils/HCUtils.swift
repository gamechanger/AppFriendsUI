//
//  HCUtils.swift
//  AppFriendsCore
//
//  Created by HAO WANG on 8/10/16.
//  Copyright © 2016 Hacknocraft. All rights reserved.
//

import UIKit

class HCUtils: NSObject {

    static func createUniqueID() -> String
    {
        return NSUUID().UUIDString
    }
 
    static func jsonStringFromDictionary() -> String
    {
        do {
            let data = try NSJSONSerialization.dataWithJSONObject(self, options:[])
            let dataString = NSString(data: data, encoding: NSUTF8StringEncoding)!
            return dataString as String
            
        } catch {
            print("JSON serialization failed:  \(error)")
        }
        return ""
    }
    
    static func dictionaryFromJsonString(text: String) -> [String:AnyObject]?
    {
        if let data = text.dataUsingEncoding(NSUTF8StringEncoding) {
            do {
                return try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String:AnyObject]
            } catch let error as NSError {
                print(error)
            }
        }
        return nil
    }
}
