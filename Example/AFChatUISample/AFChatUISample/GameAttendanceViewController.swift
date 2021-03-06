//
//  GameAttendanceViewController.swift
//  AFChatUISample
//
//  Created by HAO WANG on 9/2/16.
//  Copyright © 2016 hacknocraft. All rights reserved.
//

import UIKit
import CoreStore
import AppFriendsCore
import AppFriendsUI
import Kingfisher

struct AttendeesCategory {
    static let Pending = "Pending", Accepted = "Accepted", Rejected = "Rejected"
}

struct Actions {
    static let Invite = "invite", Decision = "decision", Cancel = "cancel"
}

class GameAttendanceViewController: BaseViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, InviteUserViewControllerDelegate, ListObjectObserver, CancelActionButtonCellDelegate, ConfirmRejectTableViewCellDelegate
{
    var gameAttendanceDialogID: String?
    var monitor: ListMonitor<HCMessage>?
    var messageMonitor: ListMonitor<HCMessage>?
    
    var gameTitle: String?
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var acceptedUserIDs = [String]()
    var pendingUserIDs = [String]()
    var rejectedUserIDs = [String]()
    
    var isOwner = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let msgMonitor = CoreStoreManager.store()?.monitorList(
            From(HCMessage),
            Where("dialogID", isEqualTo: self.gameAttendanceDialogID),
            OrderBy(.Descending("receiveTime")),
            Tweak { (fetchRequest) -> Void in
                fetchRequest.fetchBatchSize = 20
            }
            )
        {
            msgMonitor.addObserver(self)
            self.messageMonitor = msgMonitor
            
            self.processMessage(msgMonitor.objectsInAllSections())
        }
        
        self.edgesForExtendedLayout = .None
        
        self.collectionView.registerNib(UINib(nibName: "AttendanceCell", bundle: nil), forCellWithReuseIdentifier: "AttendanceCell")
        self.collectionView.registerNib(UINib(nibName: "ConfirmRejectTableViewCell", bundle: nil), forCellWithReuseIdentifier: "ConfirmRejectTableViewCell")
        self.collectionView.registerNib(UINib(nibName: "CancelActionButtonCell", bundle: nil), forCellWithReuseIdentifier: "CancelActionButtonCell")
        self.collectionView.registerNib(UINib(nibName: "PlayerSectionHeaderView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: PlayerSectionHeaderView.identifier)
        
        if let dialogID = self.gameAttendanceDialogID, let gameDialog = CoreStoreManager.store()?.fetchOne(From(HCChatDialog), Where("dialogID == %@", dialogID))
        {
            if let customData = gameDialog.customData {
                
                if let gameInfo = HCUtils.dictionaryFromJsonString(customData) {
                    
                    if let ownerID = gameInfo[Keys.gameOwnerKey] as? String {
                        self.acceptedUserIDs.append(ownerID)
                        self.isOwner = HCSDKCore.sharedInstance.currentUserID() == ownerID
                    }
                    
                    self.gameTitle = gameInfo[Keys.gameTitleKey] as? String
                }
            }
        }
        
        collectionView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Process messages
    
    func processMessage(messages: [HCMessage]) {
        
        for message in messages {
            
            if let customData = message.customData {
                
                if let messageInfo = HCUtils.dictionaryFromJsonString(customData), let action = messageInfo["action"] as? String
                {
                    if action == Actions.Invite {
                        if let userIDs = messageInfo["invites"] as? [String] {
                            var newUsers = [String]()
                            for userID in userIDs {
                                if !self.pendingUserIDs.contains(userID) && !self.acceptedUserIDs.contains(userID) && !self.rejectedUserIDs.contains(userID)
                                {
                                    newUsers.append(userID)
                                }
                            }
                            self.pendingUserIDs.appendContentsOf(newUsers)
                        }
                    }
                    else if action == Actions.Decision {
                        if let accepted = messageInfo["accept"] as? Bool, let senderID = message.senderID {
                            if accepted {
                                if !self.acceptedUserIDs.contains(senderID) {
                                    self.acceptedUserIDs.append(senderID)
                                }
                                if self.rejectedUserIDs.contains(senderID) {
                                    self.rejectedUserIDs.removeObject(senderID)
                                }
                                if self.pendingUserIDs.contains(senderID) {
                                    self.pendingUserIDs.removeObject(senderID)
                                }
                            }
                            else {
                                if self.acceptedUserIDs.contains(senderID) {
                                    self.acceptedUserIDs.removeObject(senderID)
                                }
                                if !self.rejectedUserIDs.contains(senderID) {
                                    self.rejectedUserIDs.append(senderID)
                                }
                                if self.pendingUserIDs.contains(senderID) {
                                    self.pendingUserIDs.removeObject(senderID)
                                }
                            }
                        }
                    }
                    else if action == Actions.Cancel {
                        // TODO: handle cancel
                    }
                }
            }
        }
        
        self.collectionView.reloadData()
    }
    
    // MARK: ListObserver
    
    func listMonitorWillChange(monitor: ListMonitor<HCMessage>) {
    }
    
    func listMonitorDidChange(monitor: ListMonitor<HCMessage>) {
    }
    
    func listMonitorWillRefetch(monitor: ListMonitor<HCMessage>) {
    }
    
    func listMonitorDidRefetch(monitor: ListMonitor<HCMessage>) {
    }
    
    // MARK: ListObjectObserver
    
    func listMonitor(monitor: ListMonitor<HCMessage>, didInsertObject object: HCMessage, toIndexPath indexPath: NSIndexPath)
    {
        
        // new accept, reject response received
        self.processMessage([object])
    }
    
    func listMonitor(monitor: ListMonitor<HCMessage>, didDeleteObject object: HCMessage, fromIndexPath indexPath: NSIndexPath) {
    }
    
    func listMonitor(monitor: ListMonitor<HCMessage>, didUpdateObject object: HCMessage, atIndexPath indexPath: NSIndexPath) {
    }
    
    func listMonitor(monitor: ListMonitor<HCMessage>, didMoveObject object: HCMessage, fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
    }
    
    // MARK: - Actions
    
    
    // MARK: - UICollectionViewDelegate, UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
        return 4
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if section == 0 {
            return acceptedUserIDs.count
        }
        if section == 1 {
            return rejectedUserIDs.count
        }
        if section == 2 {
            return pendingUserIDs.count
        }
        
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if self.isOwner && indexPath.section == 3 {
            
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CancelActionButtonCell", forIndexPath: indexPath) as? CancelActionButtonCell
            cell?.delegate = self
            
            return cell!
        }
        else if !self.isOwner && indexPath.section == 3 {
            
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ConfirmRejectTableViewCell", forIndexPath: indexPath) as? ConfirmRejectTableViewCell
            cell?.delegate = self
            
            return cell!
        }
        else {
            
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("AttendanceCell", forIndexPath: indexPath) as? AttendanceCell
            
            var userID: String? = nil
            
            if indexPath.section == 0 {
                userID = self.acceptedUserIDs[indexPath.row]
                cell?.checkMarkView.image = UIImage(named: "ic_check_mark")
                cell?.checkMarkView.hidden = false
            }
            else if indexPath.section == 1 {
                userID = self.rejectedUserIDs[indexPath.row]
                cell?.checkMarkView.image = UIImage(named: "ic_stop_mark")
                cell?.checkMarkView.hidden = false
            }
            else if indexPath.section == 2{
                userID = self.pendingUserIDs[indexPath.row]
                cell?.checkMarkView.hidden = true
            }
            
            if let id = userID, let user = CoreStoreManager.store()?.fetchOne(From(HCUser), Where("userID == %@", id)), let avatar = user.avatar
            {
                cell?.avatarImageView.kf_setImageWithURL(NSURL(string: avatar))
            }
            
            return cell!
        }
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionElementKindSectionHeader
        {
            let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader,
                                                                                   withReuseIdentifier:PlayerSectionHeaderView.identifier, forIndexPath: indexPath) as! PlayerSectionHeaderView
            if indexPath.section == 0 {
                headerView.sectionHeaderLabel.text = AttendeesCategory.Accepted
            }
            if indexPath.section == 1 {
                headerView.sectionHeaderLabel.text = AttendeesCategory.Rejected
            }
            if indexPath.section == 2 {
                headerView.sectionHeaderLabel.text = AttendeesCategory.Pending
            }
            
            return headerView
        }else {
            return UICollectionReusableView()
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        
        if self.isOwner && indexPath.section == 3 {
            return CGSizeMake(collectionView.w - 40, 50)
        }
        if !self.isOwner && indexPath.section == 3 {
            return CGSizeMake(collectionView.w - 40, 50)
        }
        else {
            return CGSizeMake(80, 80)
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        
        return 20
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsetsMake(10, 20, 10, 20)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        
        if section == 0 {
            return CGSizeMake(collectionView.w, 30)
        }
        if section == 1 {
            return CGSizeMake(collectionView.w, 30)
        }
        if section == 2 {
            return CGSizeMake(collectionView.w, 30)
        }
        
        return CGSizeZero
    }
    
    // MARK: Storyboard
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "inviteUserSegue" {
            
            if let inviteUserVC = segue.destinationViewController as? InviteUserViewController {
                
                inviteUserVC.delegate = self
            }
            
        }
    }
    
    // MARK: InviteUserViewControllerDelegate
    
    func usersSelected(users: [String]) {
        
        var newUsers = [String]()
        
        for userID in users {
            if !self.pendingUserIDs.contains(userID) && !self.acceptedUserIDs.contains(userID) && !self.rejectedUserIDs.contains(userID)
            {
                newUsers.append(userID)
            }
        }
        
        // add invited users to the dialog
        if let dialogID = self.gameAttendanceDialogID {
            
            DialogsManager.sharedInstance.addMembersToDialog(dialogID, members: newUsers, completion: { (error) in
                
                if let err = error {
                    
                    self.showErrorWithMessage(err.localizedDescription)
                }
                else {
                    
                    let inviteUsersJSON = self.inviteUsersJSON(newUsers)
                    
                    MessagingManager.sharedInstance.sendMessageWithCustomJSON("Invite to game\(self.gameTitle)", customJSON: inviteUsersJSON, dialogID: dialogID, dialogType: HCSDKConstants.kMessageTypeGroup, completion: { (success, error) in
                        
                        if let err = error {
                            self.showErrorWithMessage(err.localizedDescription)
                        }
                        else {
                            self.pendingUserIDs.appendContentsOf(newUsers)
                            self.collectionView.reloadData()
                        }
                    })
                }
            })
            
        }
    }
    
    // MARK: custom message jsons
    
    func inviteUsersJSON(userIDs: [String]) -> NSDictionary {
        let json = NSMutableDictionary()
        json["action"] = Actions.Invite
        json["invites"] = userIDs
        return json
    }
    
    func decisionJSON(accept: Bool) -> NSDictionary {
        let json = NSMutableDictionary()
        json["action"] = Actions.Decision
        json["accept"] = accept
        return json
    }
    
    func cancelJSON() -> NSDictionary {
        let json = NSMutableDictionary()
        json["action"] = Actions.Decision
        return json
    }
    
    // MARK: CancelActionButtonCellDelegate, ConfirmRejectTableViewCellDelegate
    
    func cancelButtonTapped(cell: CancelActionButtonCell) {
        // TODO: implement cancel
    }
    
    func rejectButtonTapped(cell: ConfirmRejectTableViewCell) {
        
        self.showLoading("")
        if let dialogID = self.gameAttendanceDialogID {
            
            let acceptedJSON = self.decisionJSON(false)
            MessagingManager.sharedInstance.sendMessageWithCustomJSON("Rejected to join game\(self.gameTitle)", customJSON: acceptedJSON, dialogID: dialogID, dialogType: HCSDKConstants.kMessageTypeGroup, completion: { (success, error) in
                
                if let err = error {
                    self.showErrorWithMessage(err.localizedDescription)
                }
                self.hideHUD()
            })
        }
    }
    
    func acceptButtonTapped(cell: ConfirmRejectTableViewCell) {
        
        if let dialogID = self.gameAttendanceDialogID {
            
            self.showLoading("")
            let acceptedJSON = self.decisionJSON(true)
            MessagingManager.sharedInstance.sendMessageWithCustomJSON("Accepted to join game\(self.gameTitle)", customJSON: acceptedJSON, dialogID: dialogID, dialogType: HCSDKConstants.kMessageTypeGroup, completion: { (success, error) in
                
                if let err = error {
                    self.showErrorWithMessage(err.localizedDescription)
                }
                self.hideHUD()
            })
        }
    }
}
