//
//  StepButton.swift
//  Commun
//
//  Created by Chung Tran on 08/07/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit

@IBDesignable class StepButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        backgroundColor = #colorLiteral(red: 0.4235294118, green: 0.5137254902, blue: 0.9294117647, alpha: 1)
        setTitleColor(.white, for: .normal)
        titleLabel?.font = .boldSystemFont(ofSize: 17)
        layer.cornerRadius = 8
        clipsToBounds = true
        
        // localize label
        if let text = titleLabel?.text {
            setTitle(text.localized(), for: .normal)
        }
    }
    
    override var isEnabled: Bool {
        didSet {
            self.backgroundColor = self.isEnabled ? #colorLiteral(red: 0.4235294118, green: 0.5137254902, blue: 0.9294117647, alpha: 1) :#colorLiteral(red: 0.4156862745, green: 0.5019607843, blue: 0.9607843137, alpha: 0.3834813784)
        }
    }
}
