//
//  SignUpVC+UITextFieldDelegate.swift
//  Commun
//
//  Created by Chung Tran on 05/07/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

extension SignUpVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == phoneNumberTextField {
            if (viewModel.selectedCountry.value == nil) {return false}
            
            let phone = viewModel.phone
            let oldPhoneValue = phone.value
            
            if string == "" {
                phone.accept(String(oldPhoneValue.dropLast()))
                return false
            }
            
            let aSet = NSCharacterSet(charactersIn:"0123456789").inverted
            let compSepByCharInSet = string.components(separatedBy: aSet)
            let numberFiltered = compSepByCharInSet.joined(separator: "")
            
            if (string != numberFiltered) {
                return false
            }
            
            if viewModel.phone.value.count == 10 {
                return false
            }
            
            viewModel.phone.accept(viewModel.phone.value + string)
            return false
        }
        return true
    }
}
