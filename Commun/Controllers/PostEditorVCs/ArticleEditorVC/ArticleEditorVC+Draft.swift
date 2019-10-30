//
//  ArticleEditorVC+Draft.swift
//  Commun
//
//  Created by Chung Tran on 10/15/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

extension ArticleEditorVC {
    // MARK: - Draft
    override var hasDraft: Bool {
       return super.hasDraft || UserDefaults.standard.dictionaryRepresentation().keys.contains(titleDraft)
    }
    
    override func getDraft() {
       // get title
       titleTextView.text = UserDefaults.standard.string(forKey: titleDraft)
       super.getDraft()
    }

    override func saveDraft(completion: (()->Void)? = nil) {
       // save title
       UserDefaults.standard.set(titleTextView.text, forKey: titleDraft)
       super.saveDraft(completion: completion)
    }
    
    override func removeDraft() {
       UserDefaults.standard.removeObject(forKey: titleDraft)
       super.removeDraft()
    }
}
