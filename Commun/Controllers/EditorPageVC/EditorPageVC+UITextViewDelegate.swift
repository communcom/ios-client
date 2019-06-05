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
        if textView == titleTextField {
            let fixedWidth = textView.frame.size.width
            textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
            let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
            var newFrame = textView.frame
            newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
            textView.frame = newFrame
            
            titleTextViewHeightConstraint.constant = newSize.height
            viewModel?.titleText.accept(titleTextField.text)
            
            textView.layoutIfNeeded()
        }
        
        else if textView == contentTextView {
            viewModel?.contentText.accept(contentTextView.text)
        }
    }

}
