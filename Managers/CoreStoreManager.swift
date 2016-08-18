//
//  CoreStoreManager.swift
//  AppFriendsCore
//
//  Created by HAO WANG on 8/9/16.
//  Copyright © 2016 Hacknocraft. All rights reserved.
//

import UIKit
import CoreStore

class CoreStoreManager: NSObject {
    
    static let sharedInstance = CoreStoreManager()
    
    var _dataStack: DataStack?
    
    static func store() -> DataStack? {
        
        return sharedInstance._dataStack
    }
    
    func initialize(completion: ((success: Bool, error: NSError?) -> ())? = nil)
    {
        guard let bundleID = NSBundle.mainBundle().bundleIdentifier else { return }
        guard let bundle = NSBundle(identifier: bundleID) else { return }
        _dataStack = DataStack(modelName: "AppFriendsUIModels", bundle: bundle, migrationChain: nil)
        
        if let dataStack = _dataStack {
            
            dataStack.addStorage(
                SQLiteStore(fileName: "AppFriendsUIModels.sqlite", localStorageOptions: .RecreateStoreOnModelMismatch),
                completion: { (result) -> Void in
                    
                    var error: NSError? = nil
                    
                    if !result.boolValue
                    {
                        error = NSError(domain: "AppFriendsError", code: 1000, userInfo: [NSLocalizedDescriptionKey: "Coredata initialization failed", NSLocalizedFailureReasonErrorKey: "Coredata initialization failed"])
                    }
                    
                    if let complete = completion
                    {
                        complete(success: result.boolValue, error: error)
                    }
                }
            )
        }
    }
    
}
