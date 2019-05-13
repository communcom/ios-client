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
    var router: (NSObjectProtocol & SignUpRoutingLogic)?
    
    
    // MARK: - IBOutlets
    @IBOutlet weak var textLabel1: UILabel!
    @IBOutlet weak var textLabel2: UILabel!
    @IBOutlet weak var textLabel3: UILabel!
    @IBOutlet weak var imageView: UIImageView!

    @IBOutlet weak var signUpButton: UIButton! {
        didSet {
            self.signUpButton.tune(withTitle:     "Sign up".localized(),
                                   hexColors:     [whiteColorPickers, lightGrayWhiteColorPickers, lightGrayWhiteColorPickers, lightGrayWhiteColorPickers],
                                   font:          UIFont(name: "SFProText-Semibold", size: 17.0 * Config.heightRatio),
                                   alignment:     .center)
            
            self.signUpButton.layer.cornerRadius = 12.0 * Config.heightRatio
            self.signUpButton.clipsToBounds = true
        }
    }
    
    @IBOutlet weak var signInButton: UIButton! {
        didSet {
            self.signInButton.tune(withTitle:     "Sign in".localized(),
                                   hexColors:     [softBlueColorPickers, verySoftBlueColorPickers, verySoftBlueColorPickers, verySoftBlueColorPickers],
                                   font:          UIFont(name: "SFProText-Semibold", size: 17.0 * Config.heightRatio),
                                   alignment:     .center)
        }
    }
    
    @IBOutlet var textLabelsCollection: [UILabel]! {
        didSet {
            self.textLabelsCollection.forEach({
                $0.tune(withText:      "",
                        hexColors:     blackWhiteColorPickers,
                        font:          UIFont(name: "SFProDisplay-Bold", size: 34.0 * Config.heightRatio),
                        alignment:     .center,
                        isMultiLines:  false)
            })
        }
    }
    
    @IBOutlet var heightsCollection: [NSLayoutConstraint]! {
        didSet {
            self.heightsCollection.forEach({ $0.constant *= Config.heightRatio })
        }
    }

    
    // MARK: - Class Initialization
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    deinit {
        Logger.log(message: "Success", event: .severe)
    }
    
    
    // MARK: - Setup
    private func setup() {
        let router                  =   SignUpRouter()
        router.viewController       =   self
        self.router                 =   router
    }

    
    // MARK: - Class Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupItem()
    }
    
    
    // MARK: - Custom Functions
    func setupItem() {
        switch self.item {
        case 0:
            self.imageView.image = UIImage(named: "image-welcome-item-0")
            
            self.textLabel1.tune(withText:      "Hundreds".localized(),
                                 hexColors:     blackWhiteColorPickers)
            
            self.textLabel2.tune(withText:      "of thematic".localized(),
                                 hexColors:     softBlueColorPickers)
            
            self.textLabel3.tune(withText:      "communities".localized(),
                                 hexColors:     softBlueColorPickers)
            
        case 1:
            self.imageView.image = UIImage(named: "image-welcome-item-1")
            
            self.textLabel1.tune(withText:      "Subscribe to your".localized(),
                                 hexColors:     blackWhiteColorPickers)
            
            self.textLabel2.tune(withText:      "favorite communities".localized(),
                                 hexColors:     blackWhiteColorPickers)
            
            self.textLabel3.tune(withText:      "",
                                 hexColors:     blackWhiteColorPickers)

        case 2:
            self.imageView.image = UIImage(named: "image-welcome-item-2")
            
            self.textLabel1.tune(withText:      "Read! upvote!".localized(),
                                 hexColors:     blackWhiteColorPickers)
            
            self.textLabel2.tune(withText:      "comment!".localized(),
                                 hexColors:     blackWhiteColorPickers)
            
            self.textLabel3.tune(withText:      "".localized(),
                                 hexColors:     blackWhiteColorPickers)

        default:
            break
        }
    }
    
    
    // MARK: - Actions
    @IBAction func signInButtonTap(_ sender: Any) {
        self.router?.routeToSignInScene()
    }
    
    @IBAction func signUpButtonTap(_ sender: Any) {
        self.router?.routeToSignUpNextScene()
    }
}
