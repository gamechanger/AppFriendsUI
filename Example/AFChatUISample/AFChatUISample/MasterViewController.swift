//
//  MasterViewController.swift
//  AppFriendsUIDev
//
//  Created by HAO WANG on 8/18/16.
//  Copyright © 2016 Hacknocraft. All rights reserved.
//

import UIKit
import AppFriendsUI
import AppFriendsCore
import Google_Material_Design_Icons_Swift

class MasterViewController: UITableViewController {
    
    var detailViewController: DetailViewController? = nil
    var objects = [AnyObject]()
    var _chatButton: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "AppFriends UI"
        
        // create chat button
        layoutNavigationBarItem()
        
        // observe new message
        startObservingNewMessagesAndUpdateBadge()
        
        // initialize AppFriends and layout info
        _chatButton?.enabled = false
        CoreStoreManager.sharedInstance.initialize { (success, error) in
            
            if success {
                
                let appFriendsCore = HCSDKCore.sharedInstance
                
                // Hard code user info
                appFriendsCore.loginWithUserInfo([
                    HCSDKConstants.kUserID: "2000",
                    HCSDKConstants.kUserName: "wshucn"
                    ])
                { (response, error) in
                    
                    if let err = error {
                        NSLog("login error:\(err)")
                    }
                    else {
                        
                        MessagingManager.startReceivingMessage()
                        
                        AppFriendsUserManager.sharedInstance.fetchUserInfo("2000") { (response, error) in
                            
                        }
                        
                        AppFriendsUserManager.sharedInstance.updateUserInfo("2000", userInfo: ["avatar": "https://robohash.org/1"], completion: { (response, error) in
                            
                            
                        })
                        
                        AppFriendsUserManager.sharedInstance.fetchUserFriends("2000", completion: { (response, error) in
                            
                        })
                        
                        self._chatButton?.enabled = true
                        DialogsManager.sharedInstance.getTotalUnreadMessageCount({ (count) in
                            self._chatButton?.badge = "\(count)"
                        })
                    }
                }
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        DialogsManager.sharedInstance.getTotalUnreadMessageCount({ (count) in
            self._chatButton?.badge = "\(count)"
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        DialogsManager.sharedInstance.removeObserver(self, forKeyPath: "totalUnreadMessages")
    }
    
    // MARK: - Observe Messages
    
    func startObservingNewMessagesAndUpdateBadge()
    {
        DialogsManager.sharedInstance.addObserver(self, forKeyPath: "totalUnreadMessages", options: [.New], context: nil)
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        if let k = keyPath where k == "totalUnreadMessages"
        {
            dispatch_async(dispatch_get_main_queue(), {
                self._chatButton?.badge = "\(DialogsManager.sharedInstance.totalUnreadMessages)"
            })
        }
        
    }
    
    // MARK: - UI
    
    func layoutNavigationBarItem() {
        _chatButton = UIButton(type: .Custom)
        _chatButton?.frame = CGRectMake(0, 0, 30, 30)
        _chatButton?.setImage(UIImage(named: "chat"), forState: .Normal)
        _chatButton?.addTarget(self, action: #selector(MasterViewController.chat(_:)), forControlEvents: .TouchUpInside)
        
        let chatBarItem = UIBarButtonItem(customView: _chatButton!)
        self.navigationItem.rightBarButtonItem = chatBarItem
    }
    
    // MARK: - Actions
    
    func chat(sender: AnyObject) {
        
        let chatContainer = HCChatContainerViewController(tabs: [HCChatContainerViewController.dialogsTabTitle, HCChatContainerViewController.contactsTabTitle])
        let nav = UINavigationController(rootViewController: chatContainer)
        nav.navigationBar.tintColor = UIColor.whiteColor()
        self.presentVC(nav)
    }
    
    // MARK: - Table View
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        let object = objects[indexPath.row] as! NSDate
        cell.textLabel!.text = object.description
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            objects.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    
}

