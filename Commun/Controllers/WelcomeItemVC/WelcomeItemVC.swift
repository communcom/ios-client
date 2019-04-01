//
//  WelcomeItemVC.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 25/03/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit

protocol WelcomeItemDelegate {
    func welcomeItemDidTapSignIn()
    func welcomeItemDidTapSignUp()
}

class WelcomeItemVC: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textLabel: UILabel!
    
    var image: UIImage?
    var text: String?
    var attrString: NSAttributedString?
    
    var delegate: WelcomeItemDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.image = image
        textLabel.text = text
        if attrString != nil {
            textLabel.attributedText = attrString
        }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func signInButtonTap(_ sender: Any) {
        delegate?.welcomeItemDidTapSignIn()
    }
    
    @IBAction func signUpButtonTap(_ sender: Any) {
        delegate?.welcomeItemDidTapSignUp()
    }
    
}
