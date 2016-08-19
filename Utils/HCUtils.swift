//
//  HCUtils.swift
//  AppFriendsCore
//
//  Created by HAO WANG on 8/10/16.
//  Copyright © 2016 Hacknocraft. All rights reserved.
//

import UIKit

public class HCUtils: NSObject {

    public static func createUniqueID() -> String
    {
        return NSUUID().UUIDString
    }
 
    public static func jsonStringFromDictionary() -> String
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
    
    public static func dictionaryFromJsonString(text: String) -> [String:AnyObject]?
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
    
    // MARK: resources bundle
    
    public static func imageInHCBundle(name: String) -> UIImage? {
        
        let bundle = self.appFriendsBundle()
        return UIImage(named: name, inBundle: bundle, compatibleWithTraitCollection: nil)
    }
    
    public static func xibBundle() -> NSBundle? {
        return NSBundle(forClass: self)
    }
    
    public static func coreDataBundle() -> NSBundle? {
        return NSBundle(forClass: self)
    }
    
    public static func appFriendsBundle() -> NSBundle? {
        
        let bundle = NSBundle(forClass: self)
        let sourcePath = bundle.pathForResource("AppFriendsResources", ofType: "bundle")
        if let path = sourcePath {
            return NSBundle(path: path)
        }else {
            return nil
        }
    }
    
    public static func registerNib(tableView: UITableView, nibName: String, forCellReuseIdentifier identifier: String)
    {
        tableView.registerNib(UINib(nibName: nibName, bundle: HCUtils.xibBundle()), forCellReuseIdentifier: identifier)
    }
}

