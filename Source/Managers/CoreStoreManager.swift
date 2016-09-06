//
//  CoreStoreManager.swift
//  AppFriendsCore
//
//  Created by HAO WANG on 8/9/16.
//  Copyright © 2016 Hacknocraft. All rights reserved.
//

import UIKit
import CoreStore

public class CoreStoreManager: NSObject {
    
    public static let sharedInstance = CoreStoreManager()
    
    var _dataStack: DataStack?
    
    public static func store() -> DataStack? {
        
        return sharedInstance._dataStack
    }
    
    public func initialize(completion: ((success: Bool, error: NSError?) -> ())? = nil)
    {
        if _dataStack != nil {
            
            if let complete = completion
            {
                complete(success: true, error: nil)
            }
            return
        }
        
        guard let bundle = HCUtils.coreDataBundle() else { return }
        _dataStack = DataStack(modelName: "AppFriendsUIModels", bundle: bundle, migrationChain: nil)
        
        if let dataStack = _dataStack {
            
            dataStack.addStorage(
                SQLiteStore(fileName: "AppFriendsUIModels.sqlite", localStorageOptions: .AllowSynchronousLightweightMigration),
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
