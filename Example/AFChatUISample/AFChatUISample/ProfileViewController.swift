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
import RNLoadingButton_Swift

class ProfileViewController: UITableViewController {
    
    var _chatButton: UIButton?
    var _followButton: RNLoadingButton?
    
    var _userAvatarUR: String?
    var _userName: String?
    
    var _userID: String?
    
    init(userID: String?) {
        
        super.init(style: .Plain)
        
        _userID = userID
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.title = "Profile"
        
        let tabBarImage = UIImage.fontAwesomeIconWithName(.User, textColor: UIColor.blackColor(), size: CGSizeMake(30, 30))
        let customTabBarItem:UITabBarItem = UITabBarItem(title: "Profile", image: tabBarImage.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal), selectedImage: tabBarImage)
        self.tabBarItem = customTabBarItem
        
        self.tableView.separatorColor = HCColorPalette.contactsTableSeparatorColor
        
        self.view.backgroundColor = UIColor(r: 13, g: 14, b: 40)
        
        self.tableView.registerNib(UINib(nibName: "UserProfileTableViewCell", bundle: nil), forCellReuseIdentifier: "UserProfileTableViewCell")
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "TableViewCell")
            
        // create chat button
        layoutNavigationBarItem()
        
        // observe new message
        startObservingNewMessagesAndUpdateBadge()
        
        DialogsManager.sharedInstance.getTotalUnreadMessageCount({ (count) in
            self._chatButton?.badge = "\(count)"
        })
        
        if _userID == nil
        {
            _userID = HCSDKCore.sharedInstance.currentUserID()
        }
        
        if let currentUserID = _userID
        {
            AppFriendsUserManager.sharedInstance.fetchUserInfo(currentUserID) { (response, error) in
                
                if let json = response as? [String: AnyObject] {
                    
                    if let avatar = json[HCSDKConstants.kUserAvatar] as? String {
                        self._userAvatarUR = avatar
                    }
                    
                    if let userName = json[HCSDKConstants.kUserName] as? String {
                        self._userName = userName
                    }
                    
                    self.tableView.reloadData()
                }
            }
            
            if _userID == HCSDKCore.sharedInstance.currentUserID()
            {
                
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
    
    func isCurrentUsr() -> Bool {
        return _userID == HCSDKCore.sharedInstance.currentUserID()
    }
    
    // MARK: - UI
    
    func layoutNavigationBarItem() {
        
        if isCurrentUsr()
        {
            // if it's the current user, we show the chat button
            
            _chatButton = UIButton(type: .Custom)
            _chatButton?.frame = CGRectMake(0, 0, 30, 30)
            _chatButton?.setImage(UIImage(named: "chat"), forState: .Normal)
            _chatButton?.addTarget(self, action: #selector(ProfileViewController.chat(_:)), forControlEvents: .TouchUpInside)
            
            let chatBarItem = UIBarButtonItem(customView: _chatButton!)
            self.navigationItem.rightBarButtonItem = chatBarItem
            
            
            let logoutButton = UIButton(type: .Custom)
            logoutButton.frame = CGRectMake(0, 0, 30, 30)
            logoutButton.setImage(UIImage(named: "ic_logout"), forState: .Normal)
            logoutButton.addTarget(self, action: #selector(ProfileViewController.logout(_:)), forControlEvents: .TouchUpInside)
            
            let logoutItem = UIBarButtonItem(customView: logoutButton)
            self.navigationItem.leftBarButtonItem = logoutItem
        }
        else
        {
            // if it's not the current user, we show the follow button
            
            if let currentUser = HCUser.currentUser() {
                
                _followButton = RNLoadingButton(type: .Custom)
                _followButton?.frame = CGRectMake(0, 0, 30, 30)
                _followButton?.activityIndicatorAlignment = .Center
                _followButton?.hideImageWhenLoading = true
                _followButton?.addTarget(self, action: #selector(ProfileViewController.followButtonTapped(_:)), forControlEvents: .TouchUpInside)
                
                if let followingUsers = currentUser.following as? [String], let userID = _userID
                {
                    if followingUsers.contains(userID)
                    {
                        _followButton?.setImage(UIImage(named: "unfollow"), forState: .Normal)
                        
                    }
                    else {
                        
                        _followButton?.setImage(UIImage(named: "follow"), forState: .Normal)
                        
                    }
                }
                else {
                    
                    _followButton?.setImage(UIImage(named: "follow"), forState: .Normal)
                }
                let followBarItem = UIBarButtonItem(customView: _followButton!)
                self.navigationItem.rightBarButtonItem = followBarItem
            }
        }
    }
    
    // MARK: - Actions
    
    func logout(sender: AnyObject) {
        
        HCSDKCore.sharedInstance.logout()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyboard.instantiateViewControllerWithIdentifier("LoginViewController")
        
        if let app = UIApplication.sharedApplication().delegate as? AppDelegate, let window = app.window {
            
            UIView.transitionWithView(window, duration: 0.3, options: .TransitionFlipFromLeft, animations: {
                
                window.rootViewController = loginVC
                
                },completion: { (finished) in
                    
            })
        }
    }
    
    func chat(sender: AnyObject) {
        
        let chatContainer = HCChatContainerViewController(tabs: [HCTitles.dialogsTabTitle, HCTitles.contactsTabTitle])
        let nav = UINavigationController(rootViewController: chatContainer)
        nav.navigationBar.tintColor = UIColor.whiteColor()
        self.presentVC(nav)
    }
    
    func followButtonTapped(sender: AnyObject) {
        
        if let currentUser = HCUser.currentUser() {
            
            if let followingUsers = currentUser.following as? [String], let userID = _userID
            {
                if followingUsers.contains(userID)
                {
                    self.unfollow(sender)
                }
                else {
                    self.follow(sender)
                }
            }
            else {
                
                self.follow(sender)
            }
        }
    }
    
    func follow(sender: AnyObject) {
        
        if let userID = _userID {
            
            _followButton?.loading = true
            AppFriendsUserManager.sharedInstance.followUser(userID, completion: { (response, error) in
                
                self._followButton?.loading = false
                if let err = error
                {
                    self.showAlert("follow user failed", message: err.localizedDescription)
                }
                else {
                    self.showAlert("", message: "You are now following this user")
                    self._followButton?.setImage(UIImage(named: "unfollow"), forState: .Normal)
                }
            })
        }
    }
    
    func unfollow(sender: AnyObject) {
        
        if let userID = _userID {
            
            _followButton?.loading = true
            AppFriendsUserManager.sharedInstance.unfollowUser(userID, completion: { (response, error) in
                
                self._followButton?.loading = false
                if let err = error
                {
                    self.showAlert("Unfollow user failed", message: err.localizedDescription)
                }
                else {
                    self.showAlert("", message: "You unfollowed this user")
                    self._followButton?.setImage(UIImage(named: "follow"), forState: .Normal)
                }
            })
        }
    }
    
    // MARK: show alert
    
    func showAlert(title: String, message: String)
    {
        let popup = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        popup.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: { (action) in
            
        }))
        self.presentVC(popup)
    }
    
    
    // MARK: - Table View
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if HCSDKCore.sharedInstance.isLogin() {
            
            if self.isCurrentUsr() {
                return 1
            }
            else {
                return 2
            }
        }
        
        return 0
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
        // start a chat with this user
        if indexPath.row == 1, let userID = _userID {
            
            let chatView = HCDialogChatViewController(dialog: userID)
            chatView.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(chatView, animated: true)
        }
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        if indexPath.row == 0 {
            
            let userProfileCell = tableView.dequeueReusableCellWithIdentifier("UserProfileTableViewCell", forIndexPath: indexPath) as! UserProfileTableViewCell
            
            userProfileCell.selectionStyle = .None
            userProfileCell.usernameLabel.text = _userName
            if let avatar = _userAvatarUR {
                userProfileCell.userAvatarView.kf_setImageWithURL(NSURL(string: avatar))
            }
            
            return userProfileCell
        }
        else
        {
            let chatCell = tableView.dequeueReusableCellWithIdentifier("TableViewCell", forIndexPath: indexPath)
            chatCell.accessoryType = .DisclosureIndicator
            chatCell.textLabel!.text = "Chat"
            return chatCell
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath.row == 0 {
            return 170
        }
        
        return 40
    }
}

