//
//  StepButton.swift
//  Commun
//
//  Created by Chung Tran on 08/07/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit

@IBDesignable class StepButton: UIButton {
    // MARK: - Class Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }

    
    // MARK: - Class Functions
    override var isEnabled: Bool {
        didSet {
            self.backgroundColor = self.isEnabled ? #colorLiteral(red: 0.4235294118, green: 0.5137254902, blue: 0.9294117647, alpha: 1) : #colorLiteral(red: 0.4156862745, green: 0.5019607843, blue: 0.9607843137, alpha: 0.3834813784)
        }
    }

    
    // MARK: - Custom Functions
    func commonInit(backgroundColor:    UIColor? = #colorLiteral(red: 0.4235294118, green: 0.5137254902, blue: 0.9294117647, alpha: 1),
                    font:               UIFont? = .boldSystemFont(ofSize: CGFloat.adaptive(width: 17.0)),
                    cornerRadius:       CGFloat? = CGFloat.adaptive(width: 8.0)) {
        self.backgroundColor        =   backgroundColor!
        self.titleLabel?.font       =   font
        self.layer.cornerRadius     =   cornerRadius!
        self.clipsToBounds          =   true
        
        // Localize label
        if let text = titleLabel?.text {
            setTitleColor(.white, for: .normal)
            setTitle(text.localized().uppercaseFirst, for: .normal)
        }
    }
}
