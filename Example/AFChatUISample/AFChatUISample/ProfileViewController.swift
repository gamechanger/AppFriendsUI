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
import CoreStore
import Kingfisher
import Google_Material_Design_Icons_Swift
import FontAwesome_swift

class ProfileViewController: UITableViewController {
    
    var _chatButton: UIButton?
    
    var _userAvatarUR: String?
    var _userName: String?
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.title = "Profile"
        
        let tabBarImage = UIImage.fontAwesomeIconWithName(.User, textColor: UIColor.blackColor(), size: CGSizeMake(30, 30))
        let customTabBarItem:UITabBarItem = UITabBarItem(title: "Profile", image: tabBarImage.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal), selectedImage: tabBarImage)
        self.tabBarItem = customTabBarItem
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(r: 13, g: 14, b: 40)
        
        self.tableView.registerNib(UINib(nibName: "UserProfileTableViewCell", bundle: nil), forCellReuseIdentifier: "UserProfileTableViewCell")
            
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
                    HCSDKConstants.kUserID: "1000",
                    HCSDKConstants.kUserName: "Hacknocraft"
                    ])
                { (response, error) in
                    
                    if let err = error {
                        NSLog("login error:\(err)")
                    }
                    else {
                        
                        MessagingManager.startReceivingMessage()
                        
                        
                        AppFriendsUserManager.sharedInstance.updateUserInfo("1000", userInfo: ["avatar": "http://findicons.com/files/icons/178/popo_emotions/128/hell_boy.png"], completion: { (response, error) in
                            
                            
                            
                            AppFriendsUserManager.sharedInstance.fetchUserInfo("1000") { (response, error) in
                                
                                if let json = response as? [String: AnyObject] {
                                    
                                    if let avatar = json["avatar"] as? String {
                                        self._userAvatarUR = avatar
                                    }
                                    
                                    if let userName = json["user_name"] as? String {
                                        self._userName = userName
                                    }
                                    
                                    self.tableView.reloadData()
                                }
                                
                            }
                            
                        })
                        
                        AppFriendsUserManager.sharedInstance.fetchUserFriends("1000", completion: { (response, error) in
                            
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
        _chatButton?.addTarget(self, action: #selector(ProfileViewController.chat(_:)), forControlEvents: .TouchUpInside)
        
        let chatBarItem = UIBarButtonItem(customView: _chatButton!)
        self.navigationItem.rightBarButtonItem = chatBarItem
    }
    
    // MARK: - Actions
    
    func chat(sender: AnyObject) {
        
        let chatContainer = HCChatContainerViewController(tabs: [HCTitles.dialogsTabTitle, HCTitles.contactsTabTitle])
        let nav = UINavigationController(rootViewController: chatContainer)
        nav.navigationBar.tintColor = UIColor.whiteColor()
        self.presentVC(nav)
    }
    
    // MARK: - Table View
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if HCSDKCore.sharedInstance.isLogin() {
            
            return 1
        }
        
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let userProfileCell = tableView.dequeueReusableCellWithIdentifier("UserProfileTableViewCell", forIndexPath: indexPath) as! UserProfileTableViewCell
        
        userProfileCell.usernameLabel.text = _userName
        if let avatar = _userAvatarUR {
            userProfileCell.userAvatarView.kf_setImageWithURL(NSURL(string: avatar))
        }
        
        return userProfileCell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath.row == 0 {
            return 200
        }
        
        return 40
    }
}

