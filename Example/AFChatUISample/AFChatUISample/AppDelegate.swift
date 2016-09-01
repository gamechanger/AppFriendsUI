//
//  AppDelegate.swift
//  AFChatUISample
//
//  Created by HAO WANG on 8/22/16.
//  Copyright © 2016 hacknocraft. All rights reserved.
//

import UIKit
import AppFriendsCore
import AppFriendsUI
import EZSwiftExtensions

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        styleApp ()
        
        let appFriendsCore = HCSDKCore.sharedInstance
        appFriendsCore.setValue(true, forKey: "useSandbox")
        
        // Handle notification
        if (launchOptions != nil) {
            
            // For remote Notification
            if let remoteNotification = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] as! [NSObject : AnyObject]? {
                
                self.processRemoteNotification(remoteNotification)
            }
        }
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    // example of handling remote notification
//    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject])
//    {
//        self.processRemoteNotification(userInfo)
//    }

    // MARK: process notification
    
    func processRemoteNotification(userInfo: [NSObject : AnyObject])
    {
        // Received remote notification.
        // You can navigate app or process data here
        
    }
    
    // MARK: style the app
    
    func styleApp () {
        
        // style navigation bar
        
        let navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        navigationBarAppearace.translucent = true
        navigationBarAppearace.shadowImage = UIImage()
        navigationBarAppearace.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        UINavigationBar.appearance().tintColor = UIColor(r: 151, g: 160, b: 188)
        
        
        // style AppFriends UI components
        
        HCColorPalette.chatBackgroundColor = UIColor(hexString: "0d0e28")
        HCColorPalette.SegmentSelectorOnBgColor = UIColor(hexString: "3c3a60")
    }

}

