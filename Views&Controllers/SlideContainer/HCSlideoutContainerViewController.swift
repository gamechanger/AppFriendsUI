//
//  HCBaseContainerViewController.swift
//  AppFriendsCore
//
//  Created by HAO WANG on 8/9/16.
//  Copyright © 2016 Hacknocraft. All rights reserved.
//

import UIKit

class HCSlideoutContainerViewController: HCBaseViewController {

    private var _containerWidth: CGFloat = 0
    
    init(width: CGFloat) {
        
        super.init(nibName: nil, bundle: nil)
        
        _containerWidth = width
        self.modalPresentationStyle = .OverCurrentContext
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func displayContentController(contentVC: UIViewController) {
        if isViewLoaded() {
            addChildViewController(contentVC)
            contentVC.view.frame = self.view.bounds
            self.view.addSubview(contentVC.view)
            contentVC.didMoveToParentViewController(self)
        }
    }
}
