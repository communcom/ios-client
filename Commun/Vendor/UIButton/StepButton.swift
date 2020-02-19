//
//  StepButton.swift
//  Commun
//
//  Created by Chung Tran on 08/07/2019.
//  Copyright © 2019 Commun Limited. All rights reserved.
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
            self.alpha = 1.0
            self.backgroundColor = self.isEnabled ? .appMainColor : .appGrayColor
        }
    }
    
    // MARK: - Custom Functions
    func commonInit(backgroundColor: UIColor? = .appMainColor,
                    font: UIFont? = .boldSystemFont(ofSize: 17.0),
                    cornerRadius: CGFloat? = 8.0) {
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
