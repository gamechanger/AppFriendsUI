//
//  HCContactsViewController.swift
//  AppFriendsCore
//
//  Created by HAO WANG on 8/11/16.
//  Copyright © 2016 Hacknocraft. All rights reserved.
//

import UIKit
import CoreStore
import FontAwesome_swift
import AppFriendsCore
import Kingfisher

public class HCContactsViewController: HCBaseViewController, ListObjectObserver {
    
    var monitor: ListMonitor<HCUser>?
    
    @IBOutlet weak var tableView: UITableView!
    var currentUserID: String?
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        currentUserID = HCSDKCore.sharedInstance.currentUserID()
        
        self.tableView.separatorStyle = .SingleLine
        self.tableView.separatorColor = HCColorPalette.contactsTableSeparatorColor
        self.tableView.backgroundColor = HCColorPalette.chatBackgroundColor
        self.view.backgroundColor = HCColorPalette.chatBackgroundColor
        self.tableView.tableFooterView = UIView()
        HCUtils.registerNib(self.tableView, nibName: "HCContactTableViewCell", forCellReuseIdentifier: "HCContactTableViewCell")
        
        let user = CoreStoreManager.store()?.fetchOne(From(HCUser),
                                                      Where("userID", isEqualTo: currentUserID!))
        
        if let friends = user?.friends as? [String]
        {
            
            let monitor = CoreStoreManager.store()!.monitorList(
                From(HCUser),
                Where("userID IN %@", friends),
                OrderBy(.Ascending("userName")),
                Tweak { (fetchRequest) -> Void in
                    fetchRequest.fetchBatchSize = 20
                }
            )
            
            monitor.addObserver(self)
            self.monitor = monitor
        }
        
        if let userID = currentUserID {
            AppFriendsUserManager.sharedInstance.fetchUserFriends(userID)
        }
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UITableViewDelegate, UITableViewDataSource
    
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
        
        return 50
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let contact = self.monitor?.objectsInSection(safeSectionIndex: indexPath.section)![indexPath.row]
        if let userID = contact?.userID
        {
            
            // find the existing or create an individual chat dialog
            CoreStoreManager.store()?.beginAsynchronous({ (transaction) in
                
                HCChatDialog.findOrCreateDialog(userID, members: [userID], dialogTitle: contact?.userName, dialogType: HCSDKConstants.kDialogTypeIndividual, transaction: transaction)
                
                transaction.commit({ (result) in
                    
                    if result.boolValue
                    {
                        let chatView = HCDialogChatViewController(dialog: userID)
                        self.navigationController?.pushViewController(chatView, animated: true)
                    }
                })
            })
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("HCContactTableViewCell", forIndexPath: indexPath) as! HCContactTableViewCell
        
        let contact = self.monitor?.objectsInSection(safeSectionIndex: indexPath.section)![indexPath.row]
        cell.userNameLabel.text = contact?.userName
        if let avatar = contact?.avatar {
            cell.userAvatar.kf_setImageWithURL(NSURL(string: avatar))
        }
        cell.selectionStyle = .None
        cell.rightImageView.image = nil
        
        return cell
    }
    
    // MARK: ListObserver
    
    public func listMonitorWillChange(monitor: ListMonitor<HCUser>) {
        self.tableView.beginUpdates()
    }
    
    public func listMonitorDidChange(monitor: ListMonitor<HCUser>) {
        self.tableView.endUpdates()
    }
    
    public func listMonitorWillRefetch(monitor: ListMonitor<HCUser>) {
    }
    
    public func listMonitorDidRefetch(monitor: ListMonitor<HCUser>) {
        self.tableView.reloadData()
    }
    
    // MARK: ListObjectObserver
    
    public func listMonitor(monitor: ListMonitor<HCUser>, didInsertObject object: HCUser, toIndexPath indexPath: NSIndexPath) {
        
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
    }
    
    public func listMonitor(monitor: ListMonitor<HCUser>, didDeleteObject object: HCUser, fromIndexPath indexPath: NSIndexPath) {
        
        self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
    }
    
    public func listMonitor(monitor: ListMonitor<HCUser>, didUpdateObject object: HCUser, atIndexPath indexPath: NSIndexPath) {
        
        self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }
    
    
    public func listMonitor(monitor: ListMonitor<HCUser>, didMoveObject object: HCUser, fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
        
        self.tableView.deleteRowsAtIndexPaths([fromIndexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        self.tableView.insertRowsAtIndexPaths([toIndexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        
    }
    
    // MARK: ListSectionObserver
    
    public func listMonitor(monitor: ListMonitor<HCUser>, didInsertSection sectionInfo: NSFetchedResultsSectionInfo, toSectionIndex sectionIndex: Int) {
        
        let sectionIndexSet = NSIndexSet(index: sectionIndex)
        self.tableView.insertSections(sectionIndexSet, withRowAnimation: UITableViewRowAnimation.Fade)
        
    }
    
    public func listMonitor(monitor: ListMonitor<HCUser>, didDeleteSection sectionInfo: NSFetchedResultsSectionInfo, fromSectionIndex sectionIndex: Int) {
        
        let sectionIndexSet = NSIndexSet(index: sectionIndex)
        self.tableView.deleteSections(sectionIndexSet, withRowAnimation: UITableViewRowAnimation.Fade)
    }

}
