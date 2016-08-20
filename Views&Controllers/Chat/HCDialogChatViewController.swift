//
//  HCDialogChatViewController.swift
//  AppFriendsCore
//
//  Created by HAO WANG on 8/9/16.
//  Copyright © 2016 Hacknocraft. All rights reserved.
//

import UIKit
import Google_Material_Design_Icons_Swift

public class HCDialogChatViewController: HCBaseChatViewController, HCGroupCreatorViewControllerDelegate {

    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        // more button
        let moreItem = UIBarButtonItem(image: nil, style: .Plain, target: self, action: #selector(HCDialogChatViewController.moreButtonTapped))
        moreItem.setGMDIcon(GMDType.GMDMoreVert, iconSize: 20)
        self.navigationItem.rightBarButtonItem = moreItem
        self.navigationItem.rightBarButtonItem?.tintColor = HCColorPalette.navigationBarIconColor
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func moreButtonTapped()
    {
        let moreActionPopup = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        moreActionPopup.addAction(UIAlertAction(title: "Invite others", style: .Default, handler: {[weak self] (action) in
            let groupCreateVC = HCGroupCreatorViewController()
            groupCreateVC.title = "Group Members"
            groupCreateVC.delegate = self
            groupCreateVC.dialogID = self?._dialogID
            let nav = UINavigationController(rootViewController: groupCreateVC)
            self?.presentVC(nav)
            }))
        moreActionPopup.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) in
            
        }))
        self.presentVC(moreActionPopup)
    }

    // MARK: HCGroupCreatorViewControllerDelegate
    
    public func usersSelected(users:[String])
    {
        self.dismissVC {
            
            
        }
    }
    
    public func closeButtonTapped(selectVC: HCGroupCreatorViewController)
    {
        self.dismissVC(completion: nil)
    }
    
}
