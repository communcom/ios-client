//
//  PostEditorVC+Draft.swift
//  Commun
//
//  Created by Chung Tran on 10/15/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

extension PostEditorVC {
    // MARK: - draft
    @objc var hasDraft: Bool {
        return contentTextView.hasDraft
    }
    
    @objc func getDraft() {
        // retrieve content
        contentTextView.getDraft {
            // remove draft
            self.removeDraft()
        }
    }
    
    @objc func saveDraft(completion: (()->Void)? = nil) {
        // save content
        contentTextView.saveDraft(completion: completion)
    }
    
    @objc func removeDraft() {
        contentTextView.removeDraft()
    }
}
