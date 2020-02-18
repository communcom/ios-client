//
//  WelcomeItemVC.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 25/03/2019.
//  Copyright © 2019 Commun Limited. All rights reserved.
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
    @IBOutlet weak var imageViewTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var describeLabel: UILabel! {
        didSet {
            describeLabel.numberOfLines = 0
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

        switch DeviceScreen.getFamily() {
        case .iPhone5:
            self.imageViewWidthConstraint.constant = 240
            self.imageViewTopConstraint.constant = -35
        case .iPhone6to8:
            self.imageViewWidthConstraint.constant = 300
            self.imageViewTopConstraint.constant = -35
        default:
            self.imageViewWidthConstraint.constant = 375
            self.imageViewTopConstraint.constant = -65
        }

        let descriptionColor = UIColor.init(hexString: "#626371")!

        switch self.item {
        // All-in-One
        case 1:
            self.titleLabel1.tune(withText: "all-in-one".localized(),
                                  hexColors: blackWhiteColorPickers,
                                  font: UIFont.systemFont(ofSize: 36, weight: .bold),
                                  alignment: .center,
                                  isMultiLines: false)
            
            self.titleLabel2.tune(withText: "social network".localized(),
                                  hexColors: blackWhiteColorPickers,
                                  font: UIFont.systemFont(ofSize: 36, weight: .regular),
                                  alignment: .center,
                                  isMultiLines: false)
            
            self.titleLabel3.isHidden = true

            self.describeLabel.attributedString = NSMutableAttributedString()
                .semibold("Choose communities of interest and\n be ", color: descriptionColor)
                .bold("rewarded ", color: .appMainColor)
                .semibold("for your actions", color: descriptionColor)
                .withParagraphSpacing(26, alignment: .center)
        // Owned by users
        case 2:
            self.titleLabel2.tune(withText: "owned".localized().uppercaseFirst,
                                  hexColors: blackWhiteColorPickers,
                                  font: UIFont.systemFont(ofSize: 36, weight: .bold),
                                  alignment: .center,
                                  isMultiLines: false)
            
            self.titleLabel3.tune(withText: "by users".localized(),
                                  hexColors: blackWhiteColorPickers,
                                  font: UIFont.systemFont(ofSize: 36, weight: .regular),
                                  alignment: .center,
                                  isMultiLines: false)
            
            self.titleLabel1.isHidden = true
            self.describeLabel.attributedString = NSMutableAttributedString()
            .semibold("Communities has no single owner\nand fully belongs to its members", color: descriptionColor)
            .withParagraphSpacing(26, alignment: .center)

        // Welcome
        default:
            self.titleLabel1.tune(withText: "welcome".localized().uppercaseFirst,
                                  hexColors: blackWhiteColorPickers,
                                  font: UIFont.systemFont(ofSize: 36.0, weight: .regular),
                                  alignment: .center,
                                  isMultiLines: false)
            
            self.titleLabel2.tune(withText: "to".localized(),
                                  hexColors: blackWhiteColorPickers,
                                  font: UIFont.systemFont(ofSize: 36.0, weight: .regular),
                                  alignment: .center,
                                  isMultiLines: false)
            
            self.titleLabel3.tune(withText: "Commun /",
                                  hexColors: softBlueColorPickers,
                                  font: UIFont.systemFont(ofSize: 36.0, weight: .bold),
                                  alignment: .center,
                                  isMultiLines: false)

            self.describeLabel.attributedString = NSMutableAttributedString()
                .semibold("Blockchain-based social network\nwhere you get ", color: descriptionColor)
                .bold("rewards ", color: .appMainColor)
                .semibold("for posts,\ncomments and likes", color: descriptionColor)
                .withParagraphSpacing(26, alignment: .center)
        }
    }
}
