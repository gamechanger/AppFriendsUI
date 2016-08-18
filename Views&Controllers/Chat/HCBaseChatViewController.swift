//
//  HCBaseChatViewController.swift
//  AppFriendsCore
//
//  Created by HAO WANG on 8/9/16.
//  Copyright © 2016 Hacknocraft. All rights reserved.
//

import UIKit
import SlackTextViewController
import CoreStore
import FontAwesome_swift
import AppFriendsCore
import Kingfisher
import NSDate_TimeAgo

class HCBaseChatViewController: SLKTextViewController, ListObjectObserver {
    
    var monitor: ListMonitor<HCMessage>?
    var currentUserID: String?
    private var _isIndividualChat: Bool = false
    private (set) var _dialogID: String = ""
    
    
    init(dialog: String) {
        _dialogID = dialog
        if let dialog = CoreStoreManager.store()?.fetchOne(From(HCChatDialog), Where("dialogID", isEqualTo:_dialogID))
        {
            _isIndividualChat = dialog.type == HCSDKConstants.kDialogTypeIndividual
        }
        super.init(tableViewStyle: .Plain)
    }
    
    required init(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentUserID = HCSDKCore.sharedInstance.currentUserID()
        
        self.tableView.separatorStyle = .None
        self.tableView.tableFooterView = UIView()
        self.tableView.registerNib(UINib(nibName: "HCChatTextTableViewCell", bundle: nil), forCellReuseIdentifier: "HCChatTextTableViewCell")
        
        if let monitor = CoreStoreManager.store()?.monitorList(
            From(HCMessage),
            Where("dialogID", isEqualTo: _dialogID),
            OrderBy(.Descending("receiveTime")),
            Tweak { (fetchRequest) -> Void in
                fetchRequest.fetchBatchSize = 20
            }
            )
        {
            monitor.addObserver(self)
            self.monitor = monitor
        }
        
        configChatView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // override methods
    
    override var tableView: UITableView {
        get {
            return super.tableView!
        }
    }
    
    override func didPressRightButton(sender: AnyObject?) {
        
        if let text = self.textView.text
        {
            if _isIndividualChat {
                MessagingManager.sharedInstance.sendTextMessage(text, userID: _dialogID)
            } else {
                MessagingManager.sharedInstance.sendTextMessage(text, dialogID: _dialogID)
            }
        }
        
        super.didPressRightButton(sender)
    }

    // MARK: Config Chat View
    
    func configChatView() {
        
        self.view.backgroundColor = HCColorPalette.chatBackgroundColor
        self.tableView.backgroundColor = HCColorPalette.chatBackgroundColor
        
        let cameraImage = UIImage.fontAwesomeIconWithName(FontAwesome.Camera, textColor: UIColor.grayColor(), size: CGSizeMake(25, 25))
        self.leftButton.tintColor = UIColor.grayColor()
        self.leftButton.setImage(cameraImage, forState: .Normal)
        
        self.bounces = true
        self.shakeToClearEnabled = true
        self.keyboardPanningEnabled = true
        self.shouldScrollToBottomAfterKeyboardShows = false
        self.inverted = true
        
        let sendImage = UIImage.fontAwesomeIconWithName(FontAwesome.Send, textColor: UIColor.grayColor(), size: CGSizeMake(25, 25))
        self.rightButton.setImage(sendImage, forState: .Normal)
        self.rightButton.tintColor = HCColorPalette.chatSendButtonColor
        
        self.textInputbar.autoHideRightButton = true
        self.textInputbar.maxCharCount = 256
        self.textInputbar.counterStyle = .Split
        self.textInputbar.counterPosition = .Top
        
        self.textInputbar.editorTitle.textColor = UIColor.darkGrayColor()
        self.textInputbar.editorLeftButton.tintColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
        self.textInputbar.editorRightButton.tintColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
    }
    
    // MARK: Messaging Cell
    
    func messagingCell(atIndexPath indexPath:NSIndexPath) -> HCChatTableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("HCChatTextTableViewCell", forIndexPath: indexPath) as! HCChatTableViewCell
        cell.selectionStyle = .None
        
        let message = self.monitor?.objectsInSection(safeSectionIndex: indexPath.section)![indexPath.row]
        
        if let text = message?.text {
            let attributedText = NSAttributedString(string: text, attributes: self.messagingCellAttributes())
            cell.messageContentLabel.attributedText = attributedText
        }
        
        cell.transform = self.tableView.transform
        cell.contentView.backgroundColor = HCColorPalette.chatBackgroundColor
        
        if let senderID = message?.senderID where senderID == self.currentUserID
        {
            cell.setbubbleColor(HCColorPalette.chatOutMessageBubbleColor!)
        }else {
            cell.setbubbleColor(HCColorPalette.chatInMessageBubbleColor!)
        }
        
        cell.userNameLabel.text = message?.senderName
        cell.userAvatarImageView.image = nil
        cell.timeLabel.text = message?.messageDisplayTime()?.timeAgo()
        cell.messageTime = message?.messageDisplayTime()
        if let avatar = message?.senderAvatar
        {
            cell.userAvatarImageView.kf_setImageWithURL(NSURL(string: avatar))
        }
        
        if let failed = message?.sendingFailed() where failed == true {
            
            cell.messageLeadingEdge.constant = 24
            cell.failedButton.alpha = 1
            cell.failedButton.enabled = true
        }
        else {
            cell.messageLeadingEdge.constant = 5
            cell.failedButton.alpha = 0
            cell.failedButton.enabled = false
        }
        
        return cell
    }
    
    func messagingCellAttributes() -> [String: AnyObject] {
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .ByWordWrapping
        paragraphStyle.alignment = .Left
        
        let pointSize = HCChatTableViewCell.defaultPointSize()
        let attributes = [NSFontAttributeName: UIFont(name: HCFont.ChatCellContentFontName, size: pointSize)!, NSParagraphStyleAttributeName: paragraphStyle, NSForegroundColorAttributeName: HCColorPalette.chatContentTextColor]
        
        return attributes
    }
    
    // MARK: UITableViewDelegate, UITableViewDataSource
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        return self.messagingCell(atIndexPath: indexPath)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let numberOfRows = self.monitor?.numberOfObjects() else {
            return 0
        }
        
        return numberOfRows
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if tableView == self.tableView, let message = self.monitor?.objectsInSection(safeSectionIndex: indexPath.section)![indexPath.row]
        {
            let attributes = self.messagingCellAttributes()
            
            var width = tableView.frame.size.width - HCChatTableViewCell.kChatCellLeftMargin - HCChatTableViewCell.kChatCellRightMargin
            
            if message.sendingFailed() {
                // leave room for the failed button
                width -= 20
            }
            
            var height = HCChatTableViewCell.kChatCellTopMargin + HCChatTableViewCell.kChatCellBottomMargin
            let text = message.text
            if let textBounds = text?.boundingRectWithSize(CGSizeMake(width, CGFloat.max), options: .UsesLineFragmentOrigin, attributes: attributes, context: nil)
            {
                height += CGRectGetHeight(textBounds)
            }
            
            height += 16
            
            if height < HCChatTableViewCell.kChatCellMinimumHeight { height = HCChatTableViewCell.kChatCellMinimumHeight }
            
            return height
        }
        
        return HCChatTableViewCell.kChatCellMinimumHeight
    }
    
    // MARK: ListObserver
    
    func listMonitorWillChange(monitor: ListMonitor<HCMessage>) {
        self.tableView.beginUpdates()
    }
    
    func listMonitorDidChange(monitor: ListMonitor<HCMessage>) {
        self.tableView.endUpdates()
        
        // auto scroll
        let firstIndexPath = NSIndexPath(forRow: 0, inSection: 0)
        let scrollPosition = self.inverted ? UITableViewScrollPosition.Bottom : UITableViewScrollPosition.Top
        self.tableView.scrollToRowAtIndexPath(firstIndexPath, atScrollPosition: scrollPosition, animated: true)
        
        // Fixes the cell from blinking (because of the transform, when using translucent cells)
        // See https://github.com/slackhq/SlackTextViewController/issues/94#issuecomment-69929927
        self.tableView.reloadData()
    }
    
    func listMonitorWillRefetch(monitor: ListMonitor<HCMessage>) {
    }
    
    func listMonitorDidRefetch(monitor: ListMonitor<HCMessage>) {
        self.tableView.reloadData()
    }
    
    // MARK: ListObjectObserver
    
    func listMonitor(monitor: ListMonitor<HCMessage>, didInsertObject object: HCMessage, toIndexPath indexPath: NSIndexPath) {
        
        
        let firstIndexPath = NSIndexPath(forRow: 0, inSection: 0)
        let rowAnimation = self.inverted ? UITableViewRowAnimation.Bottom : UITableViewRowAnimation.Top
        
        self.tableView.insertRowsAtIndexPaths([firstIndexPath], withRowAnimation: rowAnimation)
        
    }
    
    func listMonitor(monitor: ListMonitor<HCMessage>, didDeleteObject object: HCMessage, fromIndexPath indexPath: NSIndexPath) {
        
        self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
    }
    
    func listMonitor(monitor: ListMonitor<HCMessage>, didUpdateObject object: HCMessage, atIndexPath indexPath: NSIndexPath) {
        
        self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }
    
    
    func listMonitor(monitor: ListMonitor<HCMessage>, didMoveObject object: HCMessage, fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
        
        self.tableView.deleteRowsAtIndexPaths([fromIndexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        self.tableView.insertRowsAtIndexPaths([toIndexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        
    }
    
    // MARK: ListSectionObserver
    
    func listMonitor(monitor: ListMonitor<HCMessage>, didInsertSection sectionInfo: NSFetchedResultsSectionInfo, toSectionIndex sectionIndex: Int) {
        
        let sectionIndexSet = NSIndexSet(index: sectionIndex)
        self.tableView.insertSections(sectionIndexSet, withRowAnimation: UITableViewRowAnimation.Fade)
        
    }
    
    func listMonitor(monitor: ListMonitor<HCMessage>, didDeleteSection sectionInfo: NSFetchedResultsSectionInfo, fromSectionIndex sectionIndex: Int) {
        
        let sectionIndexSet = NSIndexSet(index: sectionIndex)
        self.tableView.deleteSections(sectionIndexSet, withRowAnimation: UITableViewRowAnimation.Fade)
    }
}
