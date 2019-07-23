//
//  StepButton.swift
//  Commun
//
//  Created by Chung Tran on 08/07/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit

@IBDesignable class BlankButton: UIButton {
    // MARK: - Class Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }

    
    // MARK: - Custom Functions
    func commonInit() {
        if let text = self.titleLabel?.text {
            self.tune(withTitle:        text.localized(),
                      hexColors:        [softBlueColorPickers, verySoftBlueColorPickers, verySoftBlueColorPickers, verySoftBlueColorPickers],
                      font:             UIFont(name: "SFProText-Semibold", size: 17.0 * Config.widthRatio),
                      alignment:        .center)
        }
    }
}
