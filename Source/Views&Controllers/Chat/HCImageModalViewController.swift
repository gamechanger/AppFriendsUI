//
//  HCImageModalViewController.swift
//  Pods
//
//  Created by HAO WANG on 8/23/16.
//
//

import UIKit
import Google_Material_Design_Icons_Swift
import Kingfisher

class HCImageModalViewController: HCBaseViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var closeButton: UIButton!
    
    var imageURL: String!
    
    
    init(url: String) {

        imageURL = url
        super.init(nibName: "HCImageModalViewController", bundle: HCUtils.xibBundle())
    }
    
    required public init(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.opaque = false
        
        closeButton.layer.cornerRadius = closeButton.w/2
        closeButton.layer.borderColor = HCColorPalette.closeButtonIconColor.CGColor
        closeButton.layer.borderWidth = 1
        closeButton.layer.masksToBounds = true
        closeButton.backgroundColor = HCColorPalette.closeButtonBgColor
        closeButton.setGMDIcon(.GMDClose, forState: .Normal)
        closeButton.setTitleColor(HCColorPalette.closeButtonIconColor, forState: .Normal)
        
        imageView.layer.borderColor = UIColor.whiteColor().CGColor
        imageView.layer.borderWidth = 1
        imageView.layer.cornerRadius = 3
        imageView.layer.masksToBounds = true
        
        imageView.kf_setImageWithURL(NSURL(string: imageURL))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeButtonTapped(sender: AnyObject) {
    
        self.dismissVC(completion: nil)
    }
    
}
