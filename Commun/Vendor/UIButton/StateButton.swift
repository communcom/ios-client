//
//  EditorPageButton.swift
//  Commun
//
//  Created by Chung Tran on 9/3/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit

class StateButton: UIButton {
    override var isSelected: Bool {
        didSet {
            tintColor = self.isSelected ? .appMainColor: .lightGray
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        isSelected = false
    }
}
