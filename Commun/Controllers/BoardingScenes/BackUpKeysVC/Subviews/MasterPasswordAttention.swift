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
    var closeButtonTapHandler: (() -> Void)?
    var continueButtonTapHandler: (() -> Void)?

    
    // MARK: - IBOutlets
    @IBOutlet var contentView: UIView!

    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            self.titleLabel.tune(withAttributedText:        "attention",
                                 hexColors:                 blackWhiteColorPickers,
                                 font:                      UIFont.systemFont(ofSize: CGFloat.adaptive(width: 30.0), weight: .bold),
                                 alignment:                 .center,
                                 isMultiLines:              false,
                                 lineHeight:                30.0)
        }
    }
    
    @IBOutlet weak var noteLabel: UILabel! {
        didSet {
            self.noteLabel.tune(withAttributedText:         "master password attention note",
                                hexColors:                  blackWhiteColorPickers,
                                font:                       UIFont.systemFont(ofSize: CGFloat.adaptive(width: 17.0), weight: .medium),
                                alignment:                  .center,
                                isMultiLines:               true,
                                lineHeight:                 24.0,
                                lineHeightMultiple:         1.18)
        }
    }
    
    @IBOutlet weak var describeLabel: UILabel! {
        didSet {
            self.describeLabel.tune(withAttributedText:     "master password attention describe",
                                    hexColors:              grayishBluePickers,
                                    font:                   UIFont.systemFont(ofSize: CGFloat.adaptive(width: 15.0), weight: .medium),
                                    alignment:              .center,
                                    isMultiLines:           true,
                                    lineHeight:             24.0,
                                    lineHeightMultiple:     1.34)
         }
    }
    
    @IBOutlet weak var backButton: UIButton! {
        didSet {
            self.backButton.backgroundColor = #colorLiteral(red: 0.4156862745, green: 0.5019607843, blue: 0.9607843137, alpha: 1)
            self.backButton.setTitleColor(.white, for: .normal)
            self.backButton.titleLabel?.font = .boldSystemFont(ofSize: CGFloat.adaptive(width: 15.0))
            self.backButton.setTitle("back".localized().uppercaseFirst, for: .normal)
        }
    }
    
    @IBOutlet weak var continueButton: UIButton! {
        didSet {
            self.continueButton.backgroundColor = UIColor(hexString: "#F3F5FA")
            self.continueButton.setTitleColor(UIColor(hexString: "#6A80F5"), for: .normal)
            self.continueButton.titleLabel?.font = .boldSystemFont(ofSize: CGFloat.adaptive(width: 15.0))
            self.continueButton.setTitle("continue without backup".localized().uppercaseFirst, for: .normal)
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
    
    
    // MARK: - Custom Functions
    private func commonInit() {
        Bundle.main.loadNibNamed("MasterPasswordAttention", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        contentView.layer.cornerRadius = CGFloat.adaptive(width: 25.0)
        contentView.clipsToBounds = true
        
        self.backButton.layer.cornerRadius = CGFloat.adaptive(height: 50.0) / 2
        self.backButton.clipsToBounds = true
        
        self.continueButton.layer.cornerRadius = CGFloat.adaptive(height: 50.0) / 2
        self.continueButton.clipsToBounds = true
    }
        
    
    // MARK: - Custom Functions
    func display(_ value: Bool) {
        UIView.animateKeyframes(withDuration:   0.25,
                                delay:          0.0,
                                options:        UIView.KeyframeAnimationOptions(rawValue: 7),
                                animations: {
                                    let bottomOffset = CGFloat.adaptive(width: (20.0 + (UIDevice.hasNotch ? UIDevice.safeAreaInsets.bottom : 0.0)))
                                    self.frame.origin.y = value ? UIScreen.main.bounds.height - (581.0 + bottomOffset) * Config.heightRatio : 2000.0
            },
                                completion:     nil)
    }

    
    // MARK: - Actions
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        self.display(false)
        self.closeButtonTapHandler!()
    }
    
    @IBAction func continueButtonTapped(_ sender: UIButton) {
        self.display(false)
        self.continueButtonTapHandler!()
    }
}
