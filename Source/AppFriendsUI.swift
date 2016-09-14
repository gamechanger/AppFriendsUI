//
//  AppFriendsUI.swift
//  AppFriendsCore
//
//  Created by HAO WANG on 8/29/16.
//  Copyright © 2016 Hacknocraft. All rights reserved.
//

import UIKit
import AppFriendsCore

public class AppFriendsUI: NSObject {
    
    public static let sharedInstance = AppFriendsUI()
    
    public func initialize(completion: ((success: Bool, error: NSError?) -> ())? = nil)
    {
        CoreStoreManager.sharedInstance.initialize { (success, error) in
        
            if success {
                MessagingManager.startReceivingMessage()
                completion?(success: success, error: nil)
            }
            else {
                completion?(success: success, error: error)
            }
        }
    }
    
    public func logout() {
        
        HCSDKCore.sharedInstance.logout()
        MessagingManager.sharedInstance.clearMessages()
        DialogsManager.sharedInstance.clearDialogs()
    }
    
    public func presentVCInSidePanel(fromVC fromVC: UIViewController, showVC: UIViewController, direction: HCSideDirection? = .Right) {
        
        let animator = HCSidePanelAnimator()
        let sidePanelVC = HCSidePanelViewController(animator: animator, contentVC: showVC)
        sidePanelVC.interactor = animator.interactor
        
        // make the back view controller co-exist
        sidePanelVC.modalPresentationStyle = .OverCurrentContext
        sidePanelVC.navigationController?.modalPresentationStyle = .OverCurrentContext
        
        if let d = direction {
            sidePanelVC.slideDirection = d
            animator.slideDirection = d
        }
        
        fromVC.presentVC(sidePanelVC)
    }
}
