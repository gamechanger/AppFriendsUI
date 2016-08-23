//
//  NSDictionaryExtensions.swift
//  AppFriendsCore
//
//  Created by HAO WANG on 8/10/16.
//  Copyright © 2016 Hacknocraft. All rights reserved.
//

import Foundation

extension NSDictionary {
    
    public func toString() -> String {
        
        do {
            let data = try NSJSONSerialization.dataWithJSONObject(self, options:[])
            let dataString = NSString(data: data, encoding: NSUTF8StringEncoding)!
            return dataString as String
            
            // do other stuff on success
            
        } catch {
            print("JSON serialization failed:  \(error)")
        }
        
        return ""
    }
}