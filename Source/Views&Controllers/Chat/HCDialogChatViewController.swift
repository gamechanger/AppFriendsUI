//
//  HCDialogChatViewController.swift
//  AppFriendsCore
//
//  Created by HAO WANG on 8/9/16.
//  Copyright © 2016 Hacknocraft. All rights reserved.
//

import UIKit
import AppFriendsCore
import CoreStore
import Google_Material_Design_Icons_Swift

public class HCDialogChatViewController: HCBaseChatViewController, HCGroupCreatorViewControllerDelegate {

    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        // more button
        let moreItem = UIBarButtonItem(image: nil, style: .Plain, target: self, action: #selector(HCDialogChatViewController.moreButtonTapped))
        moreItem.setGMDIcon(GMDType.GMDMoreVert, iconSize: 20)
        self.navigationItem.rightBarButtonItem = moreItem
        self.navigationItem.rightBarButtonItem?.tintColor = HCColorPalette.navigationBarIconColor
        
        updateTitle()
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateTitle() {
        
        let dialog = CoreStoreManager.store()?.fetchOne(From(HCChatDialog),
                                                        Where("dialogID", isEqualTo: _dialogID))
        let titleLabel = UILabel(x: 0, y: 0, w: 150, h: 30, fontSize: 17)
        if let isEmpty = dialog?.title?.isEmpty where isEmpty == false {
            titleLabel.text = dialog?.title
        }else {
            
            titleLabel.text = dialog?.defaultGroupName()
        }
        titleLabel.backgroundColor = UIColor.clearColor()
        titleLabel.textAlignment = .Center
        titleLabel.textColor = HCColorPalette.navigationBarTitleColor
        self.navigationItem.titleView = titleLabel
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
        
        if _dialogType == HCSDKConstants.kMessageTypeGroup {
            moreActionPopup.addAction(UIAlertAction(title: "Change Conversation Name", style: .Default, handler: {[weak self] (action) in
                
                self?.showNameChangePopup()
            }))
        }
        
        moreActionPopup.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) in
            
        }))
        self.presentVC(moreActionPopup)
    }

    func showNameChangePopup() {
        
        let nameChangeAlert = UIAlertController(title: "Change Converstaion Title", message: nil, preferredStyle: .Alert)
        nameChangeAlert.addTextFieldWithConfigurationHandler({ [weak self] (textField) in
            
            let dialog = CoreStoreManager.store()?.fetchOne(From(HCChatDialog),
                Where("dialogID", isEqualTo: self?._dialogID))
            if let isEmpty = dialog?.title?.isEmpty where isEmpty == false {
                textField.placeholder = dialog?.title
            }else {
                textField.placeholder = dialog?.defaultGroupName()
            }
        })
        nameChangeAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { [weak nameChangeAlert, weak self] (action) in
            
            if let textField = nameChangeAlert?.textFields?.first
            {
                if let text = textField.text where !text.isEmpty
                {
                    if let dialogID = self?._dialogID {
                        
                        DialogsManager.sharedInstance.updateDialogName(dialogID, dialogName: text, completion: { (error) in
                            
                            if let err = error {
                                self?.showErrorWithMessage(err.localizedDescription)
                            }
                            else {
                                self?.updateTitle()
                            }
                        })
                    }
                }
            }
            }))
        
        nameChangeAlert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) in
            
        }))
        
        self.presentVC(nameChangeAlert)
    }
    
    // MARK: HCGroupCreatorViewControllerDelegate
    
    public func usersSelected(users:[String])
    {
        self.dismissVC {
        }
        
        if users.count > 0 {
            DialogsManager.sharedInstance.addMembersToDialog(_dialogID, members: users, completion: { (error) in
                
                if let err = error {
                    self.showErrorWithMessage(err.localizedDescription)
                }
                else {
                    self.updateTitle()
                }
            })
        }
    }
    
    public func closeButtonTapped(selectVC: HCGroupCreatorViewController)
    {
        self.dismissVC(completion: nil)
    }
    
}
