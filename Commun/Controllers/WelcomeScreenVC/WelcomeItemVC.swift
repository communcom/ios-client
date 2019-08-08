//
//  WelcomeItemVC.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 25/03/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import CyberSwift

class WelcomeItemVC: UIViewController {
    // MARK: - Properties
    var item: Int = 0
    
    // MARK: - IBOutlets
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!

    
    // MARK: - Class Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupItem()
    }
    
    
    // MARK: - Custom Functions
    func setupItem() {
        // set images
        self.imageView.image = UIImage(named: "image-welcome-item-\(item)")
        
        // set text
        var attributedString = NSMutableAttributedString()

        switch self.item {
        case 0:
            attributedString = attributedString
                .bold("hundreds".localized().uppercaseFirst, font: UIFont(name: "SFProText-Semibold", size: 30.0 * Config.widthRatio)!, color: .black)
                .normal("\n")
                .bold("of thematic".localized(), font: UIFont(name: "SFProText-Semibold", size: 30.0 * Config.widthRatio)!, color: .appMainColor)
                .normal("\n")
                .bold("communities".localized(), font: UIFont(name: "SFProText-Semibold", size: 30.0 * Config.widthRatio)!, color: .appMainColor)
            
        case 1:
            attributedString = attributedString
                .bold("subscribe to your".localized().uppercaseFirst + "\n" + "favorite communities".localized(), font: UIFont(name: "SFProText-Semibold", size: 30.0 * Config.widthRatio)!, color: .black)

        case 2:
            attributedString = attributedString
                .bold("read! upvote!".localized().uppercaseFirst + "\n" + "comment!".localized(), font: UIFont(name: "SFProText-Semibold", size: 30.0 * Config.widthRatio)!, color: .black)

        default:
            break
        }
        
        self.textLabel.attributedText = attributedString
    }
}
