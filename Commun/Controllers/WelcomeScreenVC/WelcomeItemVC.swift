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

    @IBOutlet var heightsCollection: [NSLayoutConstraint]! {
        didSet {
            self.heightsCollection.forEach({ $0.constant *= Config.heightRatio })
        }
    }

    @IBOutlet var widthsCollection: [NSLayoutConstraint]! {
        didSet {
            self.widthsCollection.forEach({ $0.constant *= Config.widthRatio })
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
        
        // set text
        var attributedString = NSMutableAttributedString()

        switch self.item {
        case 0:
            attributedString = attributedString
                .bold("Hundreds".localized(), font: UIFont(name: "SFProText-Semibold", size: 30 * Config.heightRatio)!, color: .black)
                .normal("\n")
                .bold("of thematic".localized(), font: UIFont(name: "SFProText-Semibold", size: 30 * Config.heightRatio)!, color: .appMainColor)
                .normal("\n")
                .bold("communities".localized(), font: UIFont(name: "SFProText-Semibold", size: 30 * Config.heightRatio)!, color: .appMainColor)
            
        case 1:
            attributedString = attributedString
                .bold("Subscribe to your".localized() + "\n" + "favorite communities", font: UIFont(name: "SFProText-Semibold", size: 30 * Config.heightRatio)!, color: .black)

        case 2:
            attributedString = attributedString
                .bold("Read! upvote!".localized() + "\n" + "comment!", font: UIFont(name: "SFProText-Semibold", size: 30 * Config.heightRatio)!, color: .black)

        default:
            break
        }
        
        self.textLabel.attributedText = attributedString
    }
}
