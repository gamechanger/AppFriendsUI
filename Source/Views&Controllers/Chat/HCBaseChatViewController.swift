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
import EZSwiftExtensions
import AFDateHelper
import JGProgressHUD

public class HCBaseChatViewController: SLKTextViewController, ListObjectObserver, UIImagePickerControllerDelegate, UINavigationControllerDelegate, HCChatTableViewCellDelegate
{
    static var HUD: JGProgressHUD?
    var monitor: ListMonitor<HCMessage>?
    var currentUserID: String?
    private (set) var _dialogType: String = HCSDKConstants.kMessageTypeIndividual
    private (set) var _dialogID: String = ""
    
    let imagePicker = UIImagePickerController()
    
    init(dialog: String) {
        _dialogID = dialog
        if let dialog = CoreStoreManager.store()?.fetchOne(From(HCChatDialog), Where("dialogID", isEqualTo:_dialogID))
        {
            _dialogType = dialog.type!
        }
        
        super.init(tableViewStyle: .Plain)
        imagePicker.delegate = self
    }
    
    required public init(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        currentUserID = HCSDKCore.sharedInstance.currentUserID()
        
        self.tableView.separatorStyle = .None
        self.tableView.tableFooterView = UIView()
        
        HCUtils.registerNib(self.tableView, nibName: "HCChatTextTableViewCell", forCellReuseIdentifier: "HCChatTextTableViewCell")
        HCUtils.registerNib(self.tableView, nibName: "HCChatImageTableViewCell", forCellReuseIdentifier: "HCChatImageTableViewCell")
        HCUtils.registerNib(self.tableView, nibName: "HCChatSystemMessageTableViewCell", forCellReuseIdentifier: "HCChatSystemMessageTableViewCell")
        
        let twoDaysAgo = NSDate().dateBySubtractingDays(HCConstants.oldestMessageDays)
        
        if let monitor = CoreStoreManager.store()?.monitorList(
            From(HCMessage),
            Where("dialogID", isEqualTo: _dialogID) && Where("receiveTime > %@", twoDaysAgo),
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

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // override methods
    
    override public  var tableView: UITableView {
        get {
            return super.tableView!
        }
    }
    
    override public func didPressRightButton(sender: AnyObject?) {
        
        if let text = self.textView.text
        {
            MessagingManager.sharedInstance.sendTextMessage(text, dialogID: _dialogID, dialogType: _dialogType)
        }
        
        super.didPressRightButton(sender)
    }

    public override func didPressLeftButton(sender: AnyObject?) {
        
        if UIImagePickerController.isSourceTypeAvailable(.Camera)
        {
            let popup = UIAlertController(title: "Pick image", message: "", preferredStyle: .ActionSheet)
            
            popup.addAction(UIAlertAction(title: "Take a new picture", style: .Default, handler: { (action) in
                self.imagePicker.sourceType = .Camera
                self.imagePicker.allowsEditing = false
                self.presentViewController(self.imagePicker, animated: true, completion: nil)
            }))
            popup.addAction(UIAlertAction(title: "Choose from photo library", style: .Default, handler: { (action) in
                self.imagePicker.sourceType = .PhotoLibrary
                self.imagePicker.allowsEditing = false
                self.presentViewController(self.imagePicker, animated: true, completion: nil)
            }))
            self.presentVC(popup)
        }
        else {
            self.imagePicker.sourceType = .PhotoLibrary
            self.imagePicker.allowsEditing = true
            self.presentViewController(self.imagePicker, animated: true, completion: nil)
        }
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
        
        let message = self.monitor?.objectsInSection(safeSectionIndex: indexPath.section)![indexPath.row]
        
        var tableCell: HCChatTableViewCell?
        var isSystemMessage = false
        
        if let m = message
        {
            if m.messageType == HCSDKConstants.kMessageTypeSystem {
                
                isSystemMessage = true
                tableCell = self.tableView.dequeueReusableCellWithIdentifier("HCChatSystemMessageTableViewCell", forIndexPath: indexPath) as? HCChatTableViewCell
                
            }else if let customData = m.customData {
                
                if let attachment = HCMessageAttachment.getAttachmentFromMessage(dataString: customData) where attachment.attachmentType == HCMessageAttachmentType.Image.name()
                {
                    tableCell = self.tableView.dequeueReusableCellWithIdentifier("HCChatImageTableViewCell", forIndexPath: indexPath) as? HCChatTableViewCell
                    if let url = attachment.url {
                        tableCell?.contentImageView?.kf_setImageWithURL(NSURL(string: url))
                    }
                }

            }
        }
        
        if tableCell == nil {
            tableCell = self.tableView.dequeueReusableCellWithIdentifier("HCChatTextTableViewCell", forIndexPath: indexPath) as? HCChatTableViewCell
        }
        
        if let cell = tableCell
        {
            cell.selectionStyle = .None
            
            if let text = message?.text {
                
                if isSystemMessage {
                    let attributedText = NSAttributedString(string: text, attributes: self.systemMessagingCellAttributes())
                    cell.messageContentLabel?.attributedText = attributedText
                }
                else {
                    let attributedText = NSAttributedString(string: text, attributes: self.messagingCellAttributes())
                    cell.messageContentLabel?.attributedText = attributedText
                }
            }
            
            cell.transform = self.tableView.transform
            cell.contentView.backgroundColor = HCColorPalette.chatBackgroundColor
            
            if let senderID = message?.senderID where senderID == self.currentUserID
            {
                cell.setbubbleColor(HCColorPalette.chatOutMessageBubbleColor!)
            }else {
                cell.setbubbleColor(HCColorPalette.chatInMessageBubbleColor!)
            }
            
            cell.userNameLabel?.text = message?.senderName
            cell.userAvatarImageView?.image = nil
            cell.timeLabel?.text = message?.messageDisplayTime()?.timeAgo()
            cell.messageTime = message?.messageDisplayTime()
            cell.delegate = self
            if let messageTime = message?.messageDisplayTime()
            {
                // update read time for this dialog. Badge will clear all messages are read
                HCChatDialog.updateReadMessageAtTime(messageTime, dialogID: _dialogID)
            }
            
            if let avatar = message?.senderAvatar
            {
                cell.userAvatarImageView?.kf_setImageWithURL(NSURL(string: avatar))
            }
            
            if let failed = message?.sendingFailed() where failed == true {
                
                cell.failedButton?.alpha = 1
                cell.failedButton?.enabled = true
            }
            else {
                cell.failedButton?.alpha = 0
                cell.failedButton?.enabled = false
            }
            
            
            
            return cell
        }
        
        return HCChatTableViewCell()
        
    }
    
    func messagingCellAttributes() -> [String: AnyObject] {
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .ByWordWrapping
        paragraphStyle.alignment = .Left
        
        let pointSize = HCChatTableViewCell.defaultPointSize()
        let attributes = [NSFontAttributeName: UIFont(name: HCFont.ChatCellContentFontName, size: pointSize)!, NSParagraphStyleAttributeName: paragraphStyle, NSForegroundColorAttributeName: HCColorPalette.chatContentTextColor]
        
        return attributes
    }
    
    func systemMessagingCellAttributes() -> [String: AnyObject] {
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .ByWordWrapping
        paragraphStyle.alignment = .Center
        
        let pointSize = HCChatTableViewCell.defaultPointSize()
        let attributes = [NSFontAttributeName: UIFont(name: HCFont.ChatCellContentFontName, size: pointSize)!, NSParagraphStyleAttributeName: paragraphStyle, NSForegroundColorAttributeName: HCColorPalette.chatSystemMessageColor]
        
        return attributes
    }
    
    // MARK: UITableViewDelegate, UITableViewDataSource
    
    override public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        return self.messagingCell(atIndexPath: indexPath)
    }
    
    override public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let numberOfRows = self.monitor?.numberOfObjects() else {
            return 0
        }
        
        return numberOfRows
    }
    
    override public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if tableView == self.tableView, let message = self.monitor?.objectsInSection(safeSectionIndex: indexPath.section)![indexPath.row]
        {
            if let customData = message.customData
            {
                if let attachment = HCMessageAttachment.getAttachmentFromMessage(dataString: customData) where attachment.attachmentType == HCMessageAttachmentType.Image.name()
                {
                    return HCChatTableViewCell.kImageCellHeight
                }
            }
            
            // Text message
            
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
    
    public func listMonitorWillChange(monitor: ListMonitor<HCMessage>) {
        self.tableView.beginUpdates()
    }
    
    public func listMonitorDidChange(monitor: ListMonitor<HCMessage>) {
        self.tableView.endUpdates()
        
        // auto scroll
        let firstIndexPath = NSIndexPath(forRow: 0, inSection: 0)
        let scrollPosition = self.inverted ? UITableViewScrollPosition.Bottom : UITableViewScrollPosition.Top
        self.tableView.scrollToRowAtIndexPath(firstIndexPath, atScrollPosition: scrollPosition, animated: true)
        
        // Fixes the cell from blinking (because of the transform, when using translucent cells)
        // See https://github.com/slackhq/SlackTextViewController/issues/94#issuecomment-69929927
        self.tableView.reloadData()
    }
    
    public func listMonitorWillRefetch(monitor: ListMonitor<HCMessage>) {
    }
    
    public func listMonitorDidRefetch(monitor: ListMonitor<HCMessage>) {
        self.tableView.reloadData()
    }
    
    // MARK: ListObjectObserver
    
    public func listMonitor(monitor: ListMonitor<HCMessage>, didInsertObject object: HCMessage, toIndexPath indexPath: NSIndexPath) {
        
        
        let firstIndexPath = NSIndexPath(forRow: 0, inSection: 0)
        let rowAnimation = self.inverted ? UITableViewRowAnimation.Bottom : UITableViewRowAnimation.Top
        
        self.tableView.insertRowsAtIndexPaths([firstIndexPath], withRowAnimation: rowAnimation)
        
    }
    
    public func listMonitor(monitor: ListMonitor<HCMessage>, didDeleteObject object: HCMessage, fromIndexPath indexPath: NSIndexPath) {
        
        self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
    }
    
    public func listMonitor(monitor: ListMonitor<HCMessage>, didUpdateObject object: HCMessage, atIndexPath indexPath: NSIndexPath) {
        
        self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }
    
    
    public func listMonitor(monitor: ListMonitor<HCMessage>, didMoveObject object: HCMessage, fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
        
        self.tableView.deleteRowsAtIndexPaths([fromIndexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        self.tableView.insertRowsAtIndexPaths([toIndexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        
    }
    
    // MARK: ListSectionObserver
    
    public func listMonitor(monitor: ListMonitor<HCMessage>, didInsertSection sectionInfo: NSFetchedResultsSectionInfo, toSectionIndex sectionIndex: Int) {
        
        let sectionIndexSet = NSIndexSet(index: sectionIndex)
        self.tableView.insertSections(sectionIndexSet, withRowAnimation: UITableViewRowAnimation.Fade)
        
    }
    
    public func listMonitor(monitor: ListMonitor<HCMessage>, didDeleteSection sectionInfo: NSFetchedResultsSectionInfo, fromSectionIndex sectionIndex: Int) {
        
        let sectionIndexSet = NSIndexSet(index: sectionIndex)
        self.tableView.deleteSections(sectionIndexSet, withRowAnimation: UITableViewRowAnimation.Fade)
    }
    
    // MARK: UIImagePickerControllerDelegate
    
    public func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    public func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            let resultImage = pickedImage.resizeWithWidth(400)
            
            HCSDKCore.sharedInstance.uploadImage(resultImage, completion: { (imagePublicID, error) in
                
                let fullImageURL = HCSDKCore.sharedInstance.fullImage(imagePublicID)
                MessagingManager.sharedInstance.sendImageMessage(fullImageURL, dialogID: self._dialogID, dialogType: self._dialogType)
                
            }, progress: { (percentage) in
                
                let progress = Float(percentage)/100.0
                self.showProgress(progress, message: "Uploading ...")
            })
            
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: HCChatTableViewCellDelegate
    
    public func imageTapped(cell: HCChatTableViewCell) {
        
        if let indexPath = self.tableView.indexPathForCell(cell)
        {
            
            let message = self.monitor?.objectsInSection(safeSectionIndex: indexPath.section)![indexPath.row]
            
            
            if let m = message
            {
                if let customData = m.customData {
                    
                    if let attachment = HCMessageAttachment.getAttachmentFromMessage(dataString: customData) where attachment.attachmentType == HCMessageAttachmentType.Image.name()
                    {
                        if let url = attachment.url {
                            let imageModalVC = HCImageModalViewController(url: url)
                            imageModalVC.modalPresentationStyle = .OverCurrentContext
                            imageModalVC.modalTransitionStyle = .CrossDissolve
                            
                            self.presentVC(imageModalVC)
                        }
                    }
                    
                }
            }
            
        }
        
    }
    
    // MARK: HUD
    
    func hud() -> JGProgressHUD! {
        
        if HCBaseViewController.HUD == nil {
            HCBaseViewController.HUD = JGProgressHUD(style: .Dark)
        }
        
        return HCBaseViewController.HUD
    }
    
    func showProgress(progress: Float, message: String) {
        
        let HUD = self.hud()
        HUD.textLabel.text = message
        
        HUD.indicatorView = JGProgressHUDPieIndicatorView(HUDStyle: .Dark)
        HUD.setProgress(progress, animated: true)
        
        if progress >= 1 {
            
            HUD.dismiss()
            HCBaseViewController.HUD = nil
        }
        else {
            HUD.showInView(self.view)
        }
    }
    
    func showLoading (message: String?)
    {
        let HUD = self.hud()
        HUD.textLabel.text = message
        HUD.indicatorView = JGProgressHUDIndeterminateIndicatorView(HUDStyle: .Dark)
        HUD.showInView(self.view)
    }
    
    func showErrorWithMessage(message: String?) {
        
        let HUD = self.hud()
        
        HUD.textLabel.text = message
        HUD.indicatorView = JGProgressHUDErrorIndicatorView()
        
        HUD.showInView(self.view)
        HUD.dismissAfterDelay(2)
    }
    
    func showSuccessWithMessage(message: String?) {
        
        let HUD = self.hud()
        
        HUD.textLabel.text = message
        HUD.indicatorView = JGProgressHUDSuccessIndicatorView()
        
        HUD.showInView(self.view)
        HUD.dismissAfterDelay(2)
    }
    
    func hideHUD () {
        let HUD = self.hud()
        HUD.dismiss()
        HCBaseViewController.HUD = nil
    }
    
}
