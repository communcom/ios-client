//
//  StepButton.swift
//  Commun
//
//  Created by Chung Tran on 08/07/2019.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import UIKit
import SwiftTheme

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
    func commonInit(hexColors: [ThemeColorPicker]? = [softBlueColorPickers, softBlueColorPickers, softBlueColorPickers, communGrayColorPickers],
                    font: UIFont? = UIFont.systemFont(ofSize: CGFloat.adaptive(width: 15.0), weight: .semibold),
                    alignment: NSTextAlignment? = .center) {
        if let text = self.titleLabel?.text {
            self.tune(withTitle: text.localized().uppercaseFirst,
                      hexColors: hexColors!,
                      font: font,
                      alignment: alignment!)
        }
    }
}
