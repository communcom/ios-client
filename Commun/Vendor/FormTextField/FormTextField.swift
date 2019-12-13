//
//  FormTextField.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 12/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit

@IBDesignable
class FormTextField: UITextField {
    // MARK: - Properties
    @IBInspectable var inset: CGFloat = 0
    var insetRight: CGFloat? = nil
    
    
    // MARK: - Class Functions
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIEdgeInsets(top: inset, left: inset, bottom: inset, right: insetRight ?? inset))
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }
}
