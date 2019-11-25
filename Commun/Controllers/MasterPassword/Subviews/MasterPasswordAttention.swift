//
//  MasterPasswordAttention.swift
//  Commun
//
//  Created by Sergey Monastyrskiy on 25.11.2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit

class MasterPasswordAttention: UIView {
    // MARK: - Properties
    var handlerHide: (() -> Void)?


    // MARK: - IBOutlets
    @IBOutlet var contentView: UIView!

    
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
        Bundle.main.loadNibNamed("MasterPasswordAttention", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        contentView.layer.cornerRadius = CGFloat.adaptive(width: 25.0)
        contentView.clipsToBounds = true
    }
    
    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            self.titleLabel.tune(withText:          "attention".localized().uppercaseFirst,
                                 hexColors:         blackWhiteColorPickers,
                                 font:              UIFont(name: "SFProDisplay-Bold", size: CGFloat.adaptive(width: 30.0)),
                                 alignment:         .center,
                                 isMultiLines:      false)
        }
    }
    
    @IBOutlet weak var noteLabel: UILabel! {
        didSet {
            self.noteLabel.tune(withAttributedText:         "master password attention note",
                                hexColors:                  blackWhiteColorPickers,
                                font:                       UIFont(name: "SFProDisplay-Medium", size: CGFloat.adaptive(width: 17.0)),
                                alignment:                  .center,
                                isMultiLines:               true)
        }
    }
    
    @IBOutlet weak var describeLabel: UILabel! {
        didSet {
            self.describeLabel.tune(withAttributedText:     "master password attention describe",
                                    hexColors:              grayishBluePickers,
                                    font:                   UIFont(name: "SFProDisplay-Medium", size: CGFloat.adaptive(width: 15.0)),
                                    alignment:              .center,
                                    isMultiLines:           true)
        }
    }
    
    @IBOutlet weak var backButton: UIButton! {
        didSet {
            self.backButton.backgroundColor = #colorLiteral(red: 0.4156862745, green: 0.5019607843, blue: 0.9607843137, alpha: 1)
            self.backButton.setTitleColor(.white, for: .normal)
            self.backButton.titleLabel?.font = .boldSystemFont(ofSize: 15)
            self.backButton.layer.cornerRadius = self.backButton.frame.height / 2
            self.backButton.setTitle("back".localized().uppercaseFirst, for: .normal)
            self.backButton.clipsToBounds = true
        }
    }
    
    @IBOutlet weak var continueButton: UIButton! {
        didSet {
            self.continueButton.backgroundColor = UIColor(hexString: "#F3F5FA")
            self.continueButton.setTitleColor(UIColor(hexString: "#6A80F5"), for: .normal)
            self.continueButton.titleLabel?.font = .boldSystemFont(ofSize: 15)
            self.continueButton.layer.cornerRadius = self.continueButton.frame.height / 2
            self.continueButton.setTitle("continue without backup".localized().uppercaseFirst, for: .normal)
            self.continueButton.clipsToBounds = true
        }
    }
    
    
    // MARK: - Custom Functions
    func display(_ value: Bool) {
        UIView.animateKeyframes(withDuration:   0.25,
                                delay:          0.0,
                                options:        UIView.KeyframeAnimationOptions(rawValue: 7),
                                animations: {
                                    self.frame.origin.y = value ? UIScreen.main.bounds.height - (581.0 + 54.0) * Config.heightRatio : 2000.0
            },
                                completion:     nil)
    }

    
    // MARK: - Actions
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        display(false)
        handlerHide!()
    }
    
    @IBAction func continueButtonTapped(_ sender: UIButton) {
        display(false)
        handlerHide!()
    }
}
