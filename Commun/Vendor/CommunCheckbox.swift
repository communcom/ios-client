//
//  CommunCheckbox.swift
//  Commun
//
//  Created by Chung Tran on 9/30/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit

class CommunCheckbox: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() {
        // text
        setTitle(nil, for: .normal)
        setTitle(nil, for: .selected)
        
        // edge inset
        
    }
    
    func setSelected(_ isSelected: Bool) {
        self.isSelected = isSelected
        if isSelected {
            backgroundColor = .appMainColor
            borderWidth = 0
            setImage(UIImage(named: "checkmark"), for: .selected)
            imageView?.tintColor = .white
            imageEdgeInsets = UIEdgeInsets(top: 8, left: 6, bottom: 8, right: 6)
        }
        else {
            backgroundColor = .white
            borderWidth = 1
            borderColor = .lightGray
            setImage(nil, for: .normal)
            imageEdgeInsets = UIEdgeInsets.zero
        }
    }
}
