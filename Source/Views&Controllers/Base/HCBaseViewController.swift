//
//  HCBaseViewController.swift
//  AppFriendsCore
//
//  Created by HAO WANG on 8/8/16.
//  Copyright © 2016 Hacknocraft. All rights reserved.
//

import UIKit
import JGProgressHUD

public class HCBaseViewController: UIViewController {
    
    static var HUD: JGProgressHUD?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        
        
        let bundle = HCUtils.xibBundle()
        super.init(nibName: nibNameOrNil, bundle: bundle)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        self.automaticallyAdjustsScrollViewInsets = false
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: overlay message
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
