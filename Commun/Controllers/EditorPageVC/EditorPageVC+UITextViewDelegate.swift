//
//  EditorPageVC+UITextViewDelegate.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 08/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit

extension EditorPageVC: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        let fixedWidth = textView.frame.size.width
        textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        var newFrame = textView.frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        textView.frame = newFrame
        
        if textView == titleTextField {
            titleTextViewHeightConstraint.constant = newSize.height
            viewModel?.titleText.value = titleTextField.text
        }
        else if textView == contentTextView {
            contentTextViewHeightConstraint.constant = newSize.height
            viewModel?.contentText.value = contentTextView.text
        }
        
        textView.layoutIfNeeded()
    }

}
