//
//  LoginViewController.swift
//  AFChatUISample
//
//  Created by HAO WANG on 8/29/16.
//  Copyright © 2016 hacknocraft. All rights reserved.
//

import UIKit
import AppFriendsUI
import AppFriendsCore
import Kingfisher
import Alamofire
import FontAwesome_swift

class LoginViewController: HCBaseViewController {

    @IBOutlet weak var userAvatarImage: UIImageView!
    @IBOutlet weak var userIDTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    
    var currentUserInfo = [String: String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userAvatarImage.layer.cornerRadius = userAvatarImage.w/2
        userAvatarImage.layer.masksToBounds = true
        
        // initialize AppFriendsCore
        let appFriendsCore = HCSDKCore.sharedInstance
        appFriendsCore.enableDebug()
        appFriendsCore.initialize(key: "U9x5pl32dZ7u87Nr75Wx0wtt", secret: "CSegECsEOz0E7PrR2SJ78wtt") { (success, error) in
            
            if !success {
                NSLog("AppFriends initialization error:\(error?.localizedDescription)")
            }
            else {
                
                if appFriendsCore.isLogin() {
                    self.fetchCurrentUserInfo()
                }
                else {
                    self.layoutViews()
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchCurrentUserInfo() {
        
        dispatch_async(dispatch_get_main_queue()) { 
            
            // need to initialize Coredata for AppFriendsUI first
            CoreStoreManager.sharedInstance.initialize({ (success, error) in
                
                if success {
                    
                    let appFriendsCore = HCSDKCore.sharedInstance
                    if appFriendsCore.isLogin(), let currentUserID = appFriendsCore.currentUserID() {
                        
                        self.showLoading("loading user info")
                        AppFriendsUserManager.sharedInstance.fetchUserInfo(currentUserID, completion: { (response, error) in
                            
                            if let err = error {
                                self.showErrorWithMessage(err.localizedDescription)
                            }
                            else
                            {
                                self.hideHUD()
                                if let json = response as? [String: AnyObject]
                                {
                                    self.currentUserInfo[HCSDKConstants.kUserName] = json[HCSDKConstants.kUserName] as? String
                                    self.currentUserInfo[HCSDKConstants.kUserAvatar] = json[HCSDKConstants.kUserAvatar] as? String
                                    self.currentUserInfo[HCSDKConstants.kUserID] = json[HCSDKConstants.kUserID] as? String
                                    self.layoutViews()
                                }
                            }
                        })
                    }
                }
                else {
                    self.showErrorWithMessage(error?.localizedDescription)
                }
            })
        }
    }
    
    func layoutViews() {
        
        let appFriendsCore = HCSDKCore.sharedInstance
        if appFriendsCore.isLogin() {
            self.leftButton.setTitle("Log Out", forState: .Normal)
            self.rightButton.setTitle("Continue", forState: .Normal)
        }
        else {
            self.leftButton.setTitle("Random User", forState: .Normal)
            self.rightButton.setTitle("Log In", forState: .Normal)
        }
        
        self.userIDTextField.text = self.currentUserInfo[HCSDKConstants.kUserID]
        self.userNameTextField.text = self.currentUserInfo[HCSDKConstants.kUserName]
        
        if let avatar = self.currentUserInfo[HCSDKConstants.kUserAvatar]
        {
            let placeholder = UIImage.fontAwesomeIconWithName(FontAwesome.User, textColor: UIColor.grayColor(), size: CGSizeMake(60, 60))
            self.userAvatarImage.kf_setImageWithURL(NSURL(string: avatar), placeholderImage: placeholder, optionsInfo: nil, progressBlock: nil, completionHandler: nil)
        }
        else {
            self.userAvatarImage.image = nil
        }
    }

    func goToMainView() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainVC = storyboard.instantiateViewControllerWithIdentifier("TabbarController") as? UITabBarController
        let profileNav = mainVC?.viewControllers![0] as? UINavigationController
        let profileVC = ProfileViewController(userID: HCSDKCore.sharedInstance.currentUserID())
        profileNav?.setViewControllers([profileVC], animated: true)
        
        if let app = UIApplication.sharedApplication().delegate as? AppDelegate, let window = app.window {
            
            UIView.transitionWithView(window, duration: 0.3, options: .TransitionFlipFromLeft, animations: {

                window.rootViewController = mainVC
                
            },completion: { (finished) in
                                        
                                        
            })
        }
    }
    
    // MARK: - Actions

    @IBAction func leftButtonTapped(sender: AnyObject) {
        
        let appFriendsCore = HCSDKCore.sharedInstance
        if appFriendsCore.isLogin() {
            appFriendsCore.logout()
            
            // reset the view after logout
            currentUserInfo.removeAll()
            self.layoutViews()
        }
        else {
            
            // generate a random user from randomuser.me
            self.showLoading("Generating random user")
            
            Alamofire.request(.GET, "https://randomuser.me/api/", parameters: nil, headers:nil)
                .responseJSON { response in
                    
                    if let requestError = response.result.error {
                        self.showErrorWithMessage(requestError.localizedDescription)
                        
                    }
                    else if let json = response.result.value as? [String: AnyObject]
                    {
                        self.hideHUD()
                        if let results = json["results"] as? [[String: AnyObject]]
                        {
                            let data = results[0]
                            let nameInfo = data["name"] as! [String: String]
                            let userName = "\(nameInfo["first"]!) \(nameInfo["last"]!)"
                            let loginInfo = data["login"] as! [String: String]
                            let userID = loginInfo["md5"]
                            let pictureInfo = data["picture"] as! [String: String]
                            let userAvatar = pictureInfo["medium"]
                            
                            self.currentUserInfo[HCSDKConstants.kUserName] = userName
                            self.currentUserInfo[HCSDKConstants.kUserID] = userID
                            self.currentUserInfo[HCSDKConstants.kUserAvatar] = userAvatar
                            
                            self.layoutViews()
                        }
                    }
            }
        }
    }
    
    @IBAction func rightButtonTapped(sender: AnyObject) {
        
        let appFriendsCore = HCSDKCore.sharedInstance
        if appFriendsCore.isLogin() {
            self.goToMainView()
        }
        else {
            
            self.showLoading("logging in ...")
            appFriendsCore.loginWithUserInfo(self.currentUserInfo)
            { (response, error) in
                
                if let err = error {
                    self.showErrorWithMessage(err.localizedDescription)
                }
                else {
                    
                    if let currentUserID = HCSDKCore.sharedInstance.currentUserID(),
                        let avatar = self.currentUserInfo[HCSDKConstants.kUserAvatar]
                    {
                        AppFriendsUserManager.sharedInstance.updateUserInfo(currentUserID, userInfo: [HCSDKConstants.kUserAvatar: avatar], completion: { (response, error) in
                            
                            self.hideHUD()
                            MessagingManager.startReceivingMessage()
                            self.goToMainView()
                        })
                    }
                    else {
                        self.hideHUD()
                        MessagingManager.startReceivingMessage()
                        self.goToMainView()
                    }
                }
            }
        }
    }
}
