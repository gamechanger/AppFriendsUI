//
//  GamesListViewController.swift
//  AFChatUISample
//
//  Created by HAO WANG on 9/2/16.
//  Copyright © 2016 hacknocraft. All rights reserved.
//

import UIKit
import CoreStore
import DZNEmptyDataSet
import AppFriendsCore
import AppFriendsUI

class GamesListViewController: HCDialogsListViewController {
    
    var currentUserID: String?    
    
    override func viewDidLoad() {
        
        currentUserID = HCSDKCore.sharedInstance.currentUserID()
        
        super.viewDidLoad()
        
        self.title = "Scheduled Games"
        
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        self.edgesForExtendedLayout = .None
        
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "TableViewDetailCell")
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func dialogMonitor() -> ListMonitor<HCChatDialog>
    {
        let monitor = CoreStoreManager.store()!.monitorList(
            From(HCChatDialog),
            Where("ANY members.userID == %@", currentUserID!) && Where("customData != nil && customData != %@", ""),
            OrderBy(.Descending("lastMessageTime"), .Descending("createTime")),
            Tweak { (fetchRequest) -> Void in
                fetchRequest.fetchBatchSize = 20
            }
        )
        return monitor
    }
    
    // MARK: - DZNEmptyDataSetSource, DZNEmptyDataSetDelegate
    
    override func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        
        let title = NSAttributedString(string: "No Scheduled Games", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont.systemFontOfSize(17)])
        return title
    }
    

    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let numberOfRows = self.monitor?.numberOfObjectsInSection(safeSectionIndex: section) else {
            return 0
        }
        
        return numberOfRows
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cellIdentifier = "Cell"
        
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: cellIdentifier)
        }
        
        cell!.textLabel?.text = nil
        
        if let dialog = self.monitor?.objectsInSection(safeSectionIndex: indexPath.section)![indexPath.row]
        {
            if let customData = dialog.customData {
                
                if let gameData = HCUtils.dictionaryFromJsonString(customData) {
                    
                    if let gameTitle = gameData[Keys.gameTitleKey] as? String,
                    let gameDescription = gameData[Keys.gameDescriptionKey] as? String
                    {
                        cell!.textLabel?.text = gameTitle
                        cell!.detailTextLabel?.text = gameDescription
                    }
                }
            }
        }
        
        cell!.accessoryType = .DisclosureIndicator
        
        return cell!
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if let dialog = self.monitor?.objectsInSection(safeSectionIndex: indexPath.section)![indexPath.row]
        {
            selectedDialogID = dialog.dialogID
        }
        
        self.performSegueWithIdentifier("GameAttendanceSegue", sender: self)
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    var selectedDialogID: String?
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "GameAttendanceSegue" {
            
            if let gameAttendanceVC = segue.destinationViewController as? GameAttendanceViewController {
                
                gameAttendanceVC.gameAttendanceDialogID = selectedDialogID
            }
            
        }
    }
}
