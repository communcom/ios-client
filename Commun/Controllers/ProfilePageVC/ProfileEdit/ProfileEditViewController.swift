//
//  ProfileEditViewController.swift
//  Commun
//
//  Created by Sergey Monastyrskiy on 11.11.2019.
//  Copyright © 2019 Commun Limited. All rights reserved.
//
import UIKit
import CyberSwift

class ProfileEditViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var avatarView: MyAvatarImageView! {
        didSet {
            self.avatarView.setToCurrentUserAvatar()
            self.avatarView.addBorder(width: 5.0, radius: 130.0 / 2, color: .white)
            
            let avatarViewGesture = UITapGestureRecognizer(target: self, action: #selector(changeAvatarBtnDidTouch))
            avatarViewGesture.numberOfTapsRequired = 1
            self.avatarView.isUserInteractionEnabled = true
            self.avatarView.addGestureRecognizer(avatarViewGesture)
        }
    }
        
    @IBOutlet weak var coverImageView: UIImageView! {
        didSet {
            self.coverImageView.contentMode = .scaleAspectFill
            self.coverImageView.setCover(urlString: UserDefaults.standard.string(forKey: Config.currentUserCoverUrlKey))
            self.coverImageView.addBorder(width: 5.0, radius: 10.0, color: .white)
            
            let coverViewGesture = UITapGestureRecognizer(target: self, action: #selector(changeCoverBtnDidTouch))
            coverViewGesture.numberOfTapsRequired = 1
            self.coverImageView.isUserInteractionEnabled = true
            self.coverImageView.addGestureRecognizer(coverViewGesture)
        }
    }
    
    @IBOutlet weak var saveButton: UIButton! {
        didSet {
            self.saveButton.tune(withTitle: "save".localized().uppercaseFirst,
                                 hexColors: [whiteColorPickers, whiteColorPickers, whiteColorPickers, whiteColorPickers],
                                 font: UIFont(name: "SFProDisplay-Bold", size: 15.0 * Config.widthRatio),
                                 alignment: .center)
            self.saveButton.backgroundColor = #colorLiteral(red: 0.4156862745, green: 0.5019607843, blue: 0.9607843137, alpha: 1)
            self.saveButton.layer.cornerRadius = self.saveButton.frame.height / 2
            self.saveButton.clipsToBounds = true
        }
    }
    
    @IBOutlet var backgroundViewsCollection: [UIView]! {
        didSet {
            self.backgroundViewsCollection.forEach {
                $0.layer.cornerRadius = 10.0
                $0.backgroundColor = .white
                $0.clipsToBounds = true
            }
        }
    }
    
    @IBOutlet var titleLabelsCollection: [UILabel]! {
        didSet {
            self.titleLabelsCollection.forEach {
                $0.tune(withText: $0.text!.localized().uppercaseFirst,
                        hexColors: grayishBluePickers,
                        font: UIFont(name: "SFProText-Semibold", size: 12.0 * Config.widthRatio),
                        alignment: .left,
                        isMultiLines: false)
            }
        }
    }
    
    @IBOutlet var textFieldsCollection: [UITextField]! {
        didSet {
            self.textFieldsCollection.forEach {
                $0.tune(withPlaceholder: $0.placeholder!.localized().uppercaseFirst,
                        textColors: blackWhiteColorPickers,
                        font: UIFont(name: "SFProDisplay-Semibold", size: 17.0 * Config.widthRatio),
                        alignment: .left)
                
                switch $0.tag {
                case 1:
                    $0.text = "@" + (Config.currentUser?.id ?? "XXX")
                    
                default:
                    $0.text = Config.currentUser?.name ?? "XXX"
                }
            }
        }
    }
    
    @IBOutlet weak var bioTextView: UITextView! {
        didSet {
            let biographyValue = UserDefaults.standard.string(forKey: Config.currentUserBiographyKey)
            
            self.bioTextView.textContainerInset = .zero
            self.bioTextView.tune(withTextColors: biographyValue == nil ? grayishBluePickers : blackWhiteColorPickers,
                                  font: UIFont(name: "SFProDisplay-Semibold", size: 17.0 * Config.widthRatio),
                                  alignment: .left)
            
            self.bioTextView.text = biographyValue ?? "enter user biography".localized().uppercaseFirst
        }
    }
    
    // MARK: - Class Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "edit profile".localized().uppercaseFirst
        self.view.backgroundColor = UIColor(hexString: "#F3F5FA")
        self.navigationController?.navigationBar.barTintColor = .white
        self.navigationController?.navigationBar.isTranslucent = false
        
        self.setNavBarBackButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Actions
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        self.navigationController?.popViewController()
    }
}
