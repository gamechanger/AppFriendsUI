//
//  BaseViewController.swift
//  AFChatUISample
//
//  Created by HAO WANG on 9/2/16.
//  Copyright © 2016 hacknocraft. All rights reserved.
//

import UIKit
import JGProgressHUD

class BaseViewController: UIViewController {

    static var HUD: JGProgressHUD?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: overlay message
    func hud() -> JGProgressHUD! {
        
        if BaseViewController.HUD == nil {
            BaseViewController.HUD = JGProgressHUD(style: .Dark)
        }
        
        return BaseViewController.HUD
    }
    
    func showProgress(progress: Float, message: String) {
        
        let HUD = self.hud()
        HUD.textLabel.text = message
        
        HUD.indicatorView = JGProgressHUDPieIndicatorView(HUDStyle: .Dark)
        HUD.setProgress(progress, animated: true)
        
        if progress >= 1 {
            
            HUD.dismiss()
            BaseViewController.HUD = nil
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
        BaseViewController.HUD = nil
    }
}
