//
//  HCUserSearchViewController.swift
//  Pods
//
//  Created by HAO WANG on 8/28/16.
//
//

import UIKit
import CoreStore
import Kingfisher
import AppFriendsCore

public class HCUserSearchViewController: HCBaseViewController, UITableViewDelegate, UITableViewDataSource, ListObjectObserver, UISearchBarDelegate {

    @IBOutlet public weak var searchBar: UISearchBar!
    @IBOutlet public weak var tableView: UITableView!
    
    var currentUserID: String?
    
    var listMonitor: ListMonitor<HCUser>?
    
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        self.searchBar.placeholder = "Search for Users"
        self.searchBar.delegate = self
        self.searchBar.barTintColor = HCColorPalette.searchBarBgColor
        
        currentUserID = HCSDKCore.sharedInstance.currentUserID()
        
        self.tableView.separatorStyle = .SingleLine
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorColor = HCColorPalette.contactsTableSeparatorColor
        self.tableView.backgroundColor = HCColorPalette.chatBackgroundColor
        self.view.backgroundColor = HCColorPalette.chatBackgroundColor
        self.tableView.tableFooterView = UIView()
        
        HCUtils.registerNib(self.tableView, nibName: "HCUserTableViewCell", forCellReuseIdentifier: "HCUserTableViewCell")
        
        if let userID = currentUserID
        {
            let monitor = CoreStoreManager.store()!.monitorList(
                From(HCUser),
                Where("userID != %@", userID),
                OrderBy(.Ascending("userName")),
                Tweak { (fetchRequest) -> Void in
                    fetchRequest.fetchBatchSize = 20
                }
            )
            monitor.addObserver(self)
            self.listMonitor = monitor
        }
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Convenient Method
    
    public func userAtIndexPath(indexPath: NSIndexPath) -> HCUser?
    {
        return self.listMonitor?.objectsInSection(safeSectionIndex: indexPath.section)![indexPath.row]
    }
    
    // MARK: - UITableViewDelegate, UITableViewDataSource
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let numberOfRows = self.listMonitor?.numberOfObjectsInSection(safeSectionIndex: section) else {
            return 0
        }
        
        return numberOfRows
    }
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 44
    }
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("HCUserTableViewCell", forIndexPath: indexPath) as! HCUserTableViewCell
        cell.selectionStyle = .None
        
        if let user = self.userAtIndexPath(indexPath)
        {
            cell.userNameLabel.text = user.userName
            if let avatar = user.avatar {
                cell.userAvatarView.kf_setImageWithURL(NSURL(string: avatar))
            }
        }
        
        return cell
    }
    
    // MARK: UISearchBarDelegate
    public func searchBarSearchButtonClicked(searchBar: UISearchBar) {
     
        if let text = searchBar.text where !text.isEmpty, let selfUserID = self.currentUserID, let listMonitor = self.listMonitor
        {
            AppFriendsUserManager.sharedInstance.searchUser(text)
            
            listMonitor.refetch(
                Where("userName CONTAINS[c] %@ && userID != %@", text, selfUserID),
                OrderBy(.Ascending("userName")),
                Tweak { (fetchRequest) -> Void in
                    fetchRequest.fetchBatchSize = 20
                }
            )
        }
        
        self.dismissKeyboard()
    }
    
    public func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        
        self.dismissKeyboard()
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
    
    func listMonitor(monitor: ListMonitor<HCUser>, didInsertSection sectionInfo: NSFetchedResultsSectionInfo, toSectionIndex sectionIndex: Int) {
        
        let sectionIndexSet = NSIndexSet(index: sectionIndex)
        self.tableView.insertSections(sectionIndexSet, withRowAnimation: UITableViewRowAnimation.Fade)
        
    }
    
    func listMonitor(monitor: ListMonitor<HCUser>, didDeleteSection sectionInfo: NSFetchedResultsSectionInfo, fromSectionIndex sectionIndex: Int) {
        
        let sectionIndexSet = NSIndexSet(index: sectionIndex)
        self.tableView.deleteSections(sectionIndexSet, withRowAnimation: UITableViewRowAnimation.Fade)
    }
}
