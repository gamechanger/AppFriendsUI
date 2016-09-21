//
//  HCGroupCreatorViewController.swift
//  AppFriendsCore
//
//  Created by HAO WANG on 8/14/16.
//  Copyright © 2016 Hacknocraft. All rights reserved.
//

import UIKit
import CLTokenInputView
import CoreStore
import FontAwesome_swift

@objc
public protocol HCGroupCreatorViewControllerDelegate {
    func usersSelected(users:[String])
    func closeButtonTapped(selectVC: HCGroupCreatorViewController)
}

public class HCGroupCreatorViewController: HCContactsViewController, CLTokenInputViewDelegate {
    
    @IBOutlet weak var tokenField: HCContactSelectField!
    
    weak var delegate: HCGroupCreatorViewControllerDelegate?
    var dialogID: String?
    
    override public func viewDidLoad() {
        
        if let groupID = dialogID
        {
            if let groupDialog = CoreStoreManager.store()?.fetchOne(From(HCChatDialog), Where("dialogID", isEqualTo: groupID))
            {
                for member in groupDialog.members{
                    if let user = member as? HCUser
                    {
                        if let userID = user.userID where userID != currentUserID
                        {
                            hiddenUsers.append(userID)
                        }
                    }
                }
            }
        }
        super.viewDidLoad()
        
        let titleLabel = UILabel(x: 0, y: 0, w: 150, h: 30, fontSize: 17)
        if let currentTitle = self.title {
            if currentTitle.isEmpty {
                titleLabel.text = "Create a Group"
            }
            else {
                titleLabel.text = currentTitle
            }
        }
        titleLabel.backgroundColor = UIColor.clearColor()
        titleLabel.textAlignment = .Center
        titleLabel.textColor = HCColorPalette.navigationBarTitleColor
        self.navigationItem.titleView = titleLabel
        
        self.edgesForExtendedLayout = .None
        
        tokenField.userInteractionEnabled = false
        tokenField.backgroundColor = HCColorPalette.chatBackgroundColor
        tokenField.fieldColor = UIColor.lightGrayColor()
        tokenField.tintColor = UIColor.whiteColor()
        tokenField.fieldName = "Members: "
        tokenField.drawBottomBorder = true
        
        // close button
        let closeItem = UIBarButtonItem(image: nil, style: .Plain, target: self, action: #selector(HCGroupCreatorViewController.closeButtonTapped))
        closeItem.setGMDIcon(GMDType.GMDClose, iconSize: 20)
        self.navigationItem.leftBarButtonItem = closeItem
        self.navigationItem.leftBarButtonItem?.tintColor = HCColorPalette.navigationBarIconColor
        
        // more button
        let checkItem = UIBarButtonItem(image: nil, style: .Plain, target: self, action: #selector(HCGroupCreatorViewController.done))
        checkItem.setGMDIcon(GMDType.GMDCheck, iconSize: 20)
        self.navigationItem.rightBarButtonItem = checkItem
        self.navigationItem.rightBarButtonItem?.tintColor = HCColorPalette.navigationBarIconColor
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: Action
    
    func done() {
        
        if tokenField.allTokens.count > 0 {
            
            var userIDs = [String]()
            for token in tokenField.allTokens {
                if let userID = token.context {
                    userIDs.append(userID as! String)
                }
            }
            self.delegate?.usersSelected(userIDs)
        }
    }
    
    func closeButtonTapped() {
        
        self.delegate?.closeButtonTapped(self)
        
    }

    // MARK: tableview
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath) as! HCContactTableViewCell
        
        let contact = self.monitor?.objectsInSection(safeSectionIndex: indexPath.section)![indexPath.row]
        if let userName = contact?.userName, let userID = contact?.userID
        {
            let token = CLToken(displayText: userName, context: userID)
            if tokenField.allTokens.contains(token)
            {
                let checkImage = UIImage.fontAwesomeIconWithName(FontAwesome.CheckCircle, textColor: UIColor.whiteColor(), size: CGSizeMake(25, 25))
                cell.rightImageView.image = checkImage
            }
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let contact = self.monitor?.objectsInSection(safeSectionIndex: indexPath.section)![indexPath.row]
        if let userName = contact?.userName, let userID = contact?.userID
        {
            let token = CLToken(displayText: userName, context: userID)
            if tokenField.allTokens.contains(token)
            {
                tokenField.removeToken(token)
            }
            else {
                tokenField.addToken(token)
            }
        }
        
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
    }
    
    // MARK: CLTokenInputViewDelegate
    
    public func tokenInputView(view: CLTokenInputView, didAddToken token: CLToken) {
        
    }
    
    public func tokenInputView(view: CLTokenInputView, didRemoveToken token: CLToken) {
        
    }
}
