//
//  EditorPageVC+UITextViewDelegate.swift
//  Commun
//
//  Created by Chung Tran on 9/4/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

extension EditorPageVC: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        print(range, text)
        return true
    }
}
