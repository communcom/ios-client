//
//  ArticleEditorVC.swift
//  Commun
//
//  Created by Chung Tran on 10/7/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

//class ArticleEditorVC: EditorVC {
//    // MARK: - Constant
//    let titleMinLettersLimit = 2
//    let titleBytesLimit = 240
//    let titleDraft = "EditorPageVC.titleDraft"
//    
//    // MARK: - Draft
//    override var hasDraft: Bool {
//       return super.hasDraft && titleTextView.hasDraft
//    }
//
//    override func saveDraft(completion: (()->Void)? = nil) {
//       // save title
//       UserDefaults.standard.set(titleTextView.text, forKey: titleDraft)
//       super.saveDraft()
//    }
//
//    override func getDraft() {
//       // get title
//       titleTextView.text = UserDefaults.standard.string(forKey: titleDraft)
//       super.getDraft()
//    }
//
//    override func removeDraft() {
//       UserDefaults.standard.removeObject(forKey: titleDraft)
//       super.removeDraft()
//    }
//}
