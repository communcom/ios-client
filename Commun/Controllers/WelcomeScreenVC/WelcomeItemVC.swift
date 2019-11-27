//
//  WelcomeItemVC.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 25/03/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import CyberSwift
import SwiftTheme

class WelcomeItemVC: UIViewController {
    // MARK: - Properties
    var item: Int = 0
    
    
    // MARK: - IBOutlets
    @IBOutlet weak var titleLabel1: UILabel!
    @IBOutlet weak var titleLabel2: UILabel!
    @IBOutlet weak var titleLabel3: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTopConstraint: ScalableLayoutConstraint!
    
    @IBOutlet weak var describeLabel: UILabel! {
        didSet {
            self.describeLabel.tune(withText:       "",
                                    hexColors:      grayishBluePickers,
                                    font:           UIFont(name: "SFProDisplay-Medium", size: CGFloat.adaptive(width: 17.0)),
                                    alignment:      .center,
                                    isMultiLines:   true)
        }
    }
    
    
    // MARK: - Class Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupItem()
    }
    
    
    // MARK: - Custom Functions
    func setupItem() {        
        // set images
        self.imageView.image = UIImage(named: "image-welcome-item-\(item)")
        self.imageViewWidthConstraint.constant = CGFloat.adaptive(width: 310.0)
        self.imageViewTopConstraint.constant = CGFloat.adaptive(height: -70.0)
        self.describeLabel.text = "welcome-item-\(item)".localized()

        switch self.item {
        // All-in-One
        case 1:
            self.titleLabel1.tune(withText:         "all-in-one".localized(),
                                  hexColors:        blackWhiteColorPickers,
                                  font:             UIFont(name: "SFProDisplay-Bold", size: CGFloat.adaptive(width: 36.0)),
                                  alignment:        .center,
                                  isMultiLines:     false)
            
            self.titleLabel2.tune(withText:         "social network".localized(),
                                  hexColors:        blackWhiteColorPickers,
                                  font:             UIFont(name: "SFProDisplay-Regular", size: CGFloat.adaptive(width: 36.0)),
                                  alignment:        .center,
                                  isMultiLines:     false)
            
            self.titleLabel3.isHidden = true
            
        // Monetize
        case 2:
            self.titleLabel1.tune(withText:         "monetize".localized().uppercaseFirst,
                                  hexColors:        blackWhiteColorPickers,
                                  font:             UIFont(name: "SFProDisplay-Bold", size: CGFloat.adaptive(width: 36.0)),
                                  alignment:        .center,
                                  isMultiLines:     false)
            
            self.titleLabel2.tune(withText:         "your socializing".localized(),
                                  hexColors:        blackWhiteColorPickers,
                                  font:             UIFont(name: "SFProDisplay-Regular", size: CGFloat.adaptive(width: 36.0)),
                                  alignment:        .center,
                                  isMultiLines:     false)
            
            self.titleLabel3.isHidden = true
            
        // Owned by users
        case 3:
            self.titleLabel2.tune(withText:         "owned".localized().uppercaseFirst,
                                  hexColors:        blackWhiteColorPickers,
                                  font:             UIFont(name: "SFProDisplay-Bold", size: CGFloat.adaptive(width: 36.0)),
                                  alignment:        .center,
                                  isMultiLines:     false)
            
            self.titleLabel3.tune(withText:         "by users".localized(),
                                  hexColors:        blackWhiteColorPickers,
                                  font:             UIFont(name: "SFProDisplay-Regular", size: CGFloat.adaptive(width: 36.0)),
                                  alignment:        .center,
                                  isMultiLines:     false)
            
            self.titleLabel1.isHidden = true
            
        // Welcome
        default:
            self.titleLabel1.tune(withText:         "welcome".localized().uppercaseFirst,
                                  hexColors:        blackWhiteColorPickers,
                                  font:             UIFont(name: "SFProDisplay-Regular", size: CGFloat.adaptive(width: 36.0)),
                                  alignment:        .center,
                                  isMultiLines:     false)
            
            self.titleLabel2.tune(withText:         "to".localized(),
                                  hexColors:        blackWhiteColorPickers,
                                  font:             UIFont(name: "SFProDisplay-Regular", size: CGFloat.adaptive(width: 36.0)),
                                  alignment:        .center,
                                  isMultiLines:     false)
            
            self.titleLabel3.tune(withText:         "Commun /",
                                  hexColors:        softBlueColorPickers,
                                  font:             UIFont(name: "SFProDisplay-Bold", size: CGFloat.adaptive(width: 36.0)),
                                  alignment:        .center,
                                  isMultiLines:     false)
            
            self.imageViewWidthConstraint.constant = UIScreen.main.bounds.width
            self.imageViewTopConstraint.constant = -20.0
        }
    }
}
