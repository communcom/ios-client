//
//  UserNameRules.swift
//  Commun
//
//  Created by Sergey Monastyrskiy on 07.11.2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit

class UserNameRulesView: UIView {
    // MARK: - Properties
    var handlerHide: (() -> Void)?

    
    // MARK: - IBOutlets
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            self.titleLabel.tune(withText:          "username must be".localized().uppercaseFirst,
                                 hexColors:         blackWhiteColorPickers,
                                 font:              UIFont(name: "SFProDisplay-Semibold", size: CGFloat.adaptive(width: 17.0)),
                                 alignment:         .left,
                                 isMultiLines:      false)
        }
    }
    
    @IBOutlet var rulesCollection: [UILabel]! {
        didSet {
            self.rulesCollection.forEach { label in
                label.tune(withText:          "•  " + label.text!.localized().uppercaseFirst,
                           hexColors:         grayishBluePickers,
                           font:              UIFont(name: "SFProDisplay-Medium", size: CGFloat.adaptive(width: 15.0)),
                           alignment:         .left,
                           isMultiLines:      true)
            }
        }
    }

    @IBOutlet weak var understoodButton: UIButton! {
        didSet {
            self.understoodButton.backgroundColor = #colorLiteral(red: 0.4156862745, green: 0.5019607843, blue: 0.9607843137, alpha: 1)
            self.understoodButton.setTitleColor(.white, for: .normal)
            self.understoodButton.titleLabel?.font = .boldSystemFont(ofSize: 15)
            self.understoodButton.layer.cornerRadius = self.understoodButton.frame.height / 2
            self.understoodButton.clipsToBounds = true
            self.understoodButton.setTitle("understood".localized().uppercaseFirst, for: .normal)
        }
    }
    
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("UserNameRulesView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        contentView.layer.cornerRadius = CGFloat.adaptive(width: 25.0)
        contentView.clipsToBounds = true
    }
    
    
    // MARK: - Custom Functions
    func display(_ value: Bool) {
        UIView.animateKeyframes(withDuration:   0.25,
                                delay:          0.0,
                                options:        UIView.KeyframeAnimationOptions(rawValue: 7),
                                animations: {
                                    self.frame.origin.y = value ? UIScreen.main.bounds.height - (355.0 + 54.0) * Config.heightRatio : 2000.0
            },
                                completion:     nil)
    }

    
    // MARK: - Actions
    @IBAction func actionButtonTapped(_ sender: UIButton) {
        display(false)
        handlerHide!()
    }
}
