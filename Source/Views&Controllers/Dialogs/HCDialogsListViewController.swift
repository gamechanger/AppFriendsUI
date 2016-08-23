//
//  HCDialogsListViewController.swift
//  AppFriendsCore
//
//  Created by HAO WANG on 8/9/16.
//  Copyright © 2016 Hacknocraft. All rights reserved.
//

import UIKit
import AppFriendsCore
import CoreStore
import FontAwesome_swift
import NSDate_TimeAgo
import SESlideTableViewCell
import DZNEmptyDataSet

class HCDialogsListViewController: HCBaseViewController, UITableViewDelegate, UITableViewDataSource, ListObjectObserver, SESlideTableViewCellDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate
{
    
    var monitor: ListMonitor<HCChatDialog>?
    
    @IBOutlet weak var tableView: UITableView!
    var currentUserID: String?
    var emptyLabel: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentUserID = HCSDKCore.sharedInstance.currentUserID()
        
        self.tableView.separatorStyle = .SingleLine
        self.tableView.separatorColor = HCColorPalette.contactsTableSeparatorColor
        self.tableView.backgroundColor = HCColorPalette.chatBackgroundColor
        self.view.backgroundColor = HCColorPalette.chatBackgroundColor
        self.tableView.tableFooterView = UIView()
        
        HCUtils.registerNib(self.tableView, nibName: "HCDialogTableViewCell", forCellReuseIdentifier: "HCDialogTableViewCell")
        
        let monitor = CoreStoreManager.store()!.monitorList(
            From(HCChatDialog),
            Where("ANY members.userID == %@", currentUserID!),
            OrderBy(.Descending("lastMessageTime"), .Descending("createTime")),
            Tweak { (fetchRequest) -> Void in
                fetchRequest.fetchBatchSize = 20
            }
        )
        
        monitor.addObserver(self)
        self.monitor = monitor
        
        DialogsManager.sharedInstance.fetchDialogs { (error) in
            
            self.tableView.emptyDataSetSource = self
            self.tableView.emptyDataSetDelegate = self
            self.tableView.reloadEmptyDataSet()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - DZNEmptyDataSetSource, DZNEmptyDataSetDelegate
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        
        let title = NSAttributedString(string: "No Active Conversations", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: HCFont.EmptyTableViewLabelFont])
        return title
    }
    
    
    // MARK: - UITableViewDelegate, UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let numberOfRows = self.monitor?.numberOfObjectsInSection(safeSectionIndex: section) else {
            return 0
        }
        
        return numberOfRows
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 88
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if let dialog = self.monitor?.objectsInSection(safeSectionIndex: indexPath.section)![indexPath.row]
        {
            let chatView = HCDialogChatViewController(dialog: dialog.dialogID!)
            self.navigationController?.pushViewController(chatView, animated: true)

        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("HCDialogTableViewCell", forIndexPath: indexPath) as! HCDialogTableViewCell
        cell.selectionStyle = .None
        
        if !cell.addedRightButton {
            cell.addRightButtonWithText("Leave", textColor: UIColor.whiteColor(), backgroundColor: UIColor(hexString: "f2433d"))
        }
        
        cell.delegate = self
        cell.showsRightSlideIndicator = false
        cell.dialogAvatarImageView.badge = nil
        
        if let dialog = self.monitor?.objectsInSection(safeSectionIndex: indexPath.section)![indexPath.row]
        {
            if let groupTitle = dialog.title where groupTitle.length > 1 {
                cell.userNameLabel.text = dialog.title
            }
            else {
                cell.userNameLabel.text = dialog.defaultGroupName()
            }
            cell.lastMessageLabel.text = dialog.lastMessageText
            cell.dialogAvatarImageView.image = nil
            if let messageText = dialog.lastMessageText where !messageText.isEmpty {
                cell.lastMessageTimeLabel.text = dialog.lastMessageTime?.timeAgoSimple()
                cell.messageTime = dialog.lastMessageTime
            }else {
                cell.lastMessageTimeLabel.text = nil
                cell.messageTime = nil
            }
            
            if dialog.type == HCSDKConstants.kDialogTypeGroup {
                let groupDialogImage = UIImage.fontAwesomeIconWithName(FontAwesome.Group, textColor: UIColor.grayColor(), size: CGSizeMake(44, 44))
                cell.dialogAvatarImageView.image = groupDialogImage
            }
            else
            {
                for user in dialog.members
                {
                    if let u = user as? HCUser
                    {
                        if u.userID != currentUserID
                        {
                            if let avatar = u.avatar {
                                cell.dialogAvatarImageView.kf_setImageWithURL(NSURL(string: avatar))
                            }
                        }
                    }
                }
            }
            
            if let unreadMessageCount = dialog.unreadMessages{
                cell.dialogAvatarImageView.badge = "\(unreadMessageCount)"
            }
            
        }
        
        return cell
    }
    
    // MARK: SESlideTableViewCellDelegate
    func slideTableViewCell(cell: SESlideTableViewCell!, didTriggerRightButton buttonIndex: NSInteger) {
        
        if let indexPath = tableView.indexPathForCell(cell)
        {
            if let dialog = self.monitor?.objectsInSection(safeSectionIndex: indexPath.section)![indexPath.row]
            {
                if let dialogID = dialog.dialogID {
                    
                    if dialog.type == HCSDKConstants.kDialogTypeGroup
                    {
                        DialogsManager.sharedInstance.leaveGroupDialog(dialogID, completion: { (error) in
                            
                            if let err = error {
                                self.showErrorWithMessage(err.localizedDescription)
                            }
                        })
                    }
                    else if dialog.type == HCSDKConstants.kDialogTypeIndividual
                    {
                        let dialogObjectID = dialog.objectID
                        CoreStoreManager.store()?.beginAsynchronous({ (transaction) in
                            if let dialogObj = transaction.fetchExisting(dialogObjectID) {
                                transaction.delete(dialogObj)
                                transaction.commit()
                            }
                        })
                    }
                }
            }
        }
    }
    
    // MARK: ListObserver
    
    func listMonitorWillChange(monitor: ListMonitor<HCChatDialog>) {
        self.tableView.beginUpdates()
    }
    
    func listMonitorDidChange(monitor: ListMonitor<HCChatDialog>) {
        self.tableView.endUpdates()
    }
    
    func listMonitorWillRefetch(monitor: ListMonitor<HCChatDialog>) {
    }
    
    func listMonitorDidRefetch(monitor: ListMonitor<HCChatDialog>) {
        self.tableView.reloadData()
    }
    
    // MARK: ListObjectObserver
    
    func listMonitor(monitor: ListMonitor<HCChatDialog>, didInsertObject object: HCChatDialog, toIndexPath indexPath: NSIndexPath) {
        
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
    }
    
    func listMonitor(monitor: ListMonitor<HCChatDialog>, didDeleteObject object: HCChatDialog, fromIndexPath indexPath: NSIndexPath) {
        
        self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
    }
    
    func listMonitor(monitor: ListMonitor<HCChatDialog>, didUpdateObject object: HCChatDialog, atIndexPath indexPath: NSIndexPath) {
        
        self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }
    
    
    func listMonitor(monitor: ListMonitor<HCChatDialog>, didMoveObject object: HCChatDialog, fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
        
        self.tableView.deleteRowsAtIndexPaths([fromIndexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        self.tableView.insertRowsAtIndexPaths([toIndexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        
    }
    
    // MARK: ListSectionObserver
    
    func listMonitor(monitor: ListMonitor<HCChatDialog>, didInsertSection sectionInfo: NSFetchedResultsSectionInfo, toSectionIndex sectionIndex: Int) {
        
        let sectionIndexSet = NSIndexSet(index: sectionIndex)
        self.tableView.insertSections(sectionIndexSet, withRowAnimation: UITableViewRowAnimation.Fade)
        
    }
    
    func listMonitor(monitor: ListMonitor<HCChatDialog>, didDeleteSection sectionInfo: NSFetchedResultsSectionInfo, fromSectionIndex sectionIndex: Int) {
        
        let sectionIndexSet = NSIndexSet(index: sectionIndex)
        self.tableView.deleteSections(sectionIndexSet, withRowAnimation: UITableViewRowAnimation.Fade)
    }
}
