//
//  PostEditorVC+Draft.swift
//  Commun
//
//  Created by Chung Tran on 10/15/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

extension PostEditorVC {
    // MARK: - draft
    func retrieveDraft() {
        showAlert(
            title: "retrieve draft".localized().uppercaseFirst,
            message: "you have a draft version on your device".localized().uppercaseFirst + ". " + "continue editing it".localized().uppercaseFirst + "?",
            buttonTitles: ["OK".localized(), "cancel".localized().uppercaseFirst],
            highlightedButtonIndex: 0) { (index) in
                if index == 0 {
                    self.getDraft()
                } else if index == 1 {
                    self.removeDraft()
                }
        }
    }
    
    @objc var hasDraft: Bool {
        return contentTextView.hasDraft || UserDefaults.standard.dictionaryRepresentation().keys.contains(communityDraftKey)
    }
    
    @objc func getDraft() {
        // retrieve community
        if let savedCommunity = UserDefaults.standard.object(forKey: communityDraftKey) as? Data,
            let loadedCommunity = try? JSONDecoder().decode(ResponseAPIContentGetCommunity.self, from: savedCommunity) {
            viewModel.community.accept(loadedCommunity)
        }
        
        // retrieve content
        contentTextView.getDraft {
            self.showExplanationViewIfNeeded()
            
            // remove draft
            self.removeDraft()
        }
    }
    
    @objc func shouldSaveDraft() -> Bool {
        viewModel.postForEdit == nil && !contentTextView.text.trimmed.isEmpty
    }
    
    @objc func saveDraft() {
        var shouldSave = true
        DispatchQueue.main.sync {
            shouldSave = self.shouldSaveDraft()
        }
        guard let community = viewModel.community.value,
            shouldSave else {return}
        
        // save community
        if let encoded = try? JSONEncoder().encode(community) {
            UserDefaults.standard.set(encoded, forKey: communityDraftKey)
        }
        
        // save content
        contentTextView.saveDraft()
    }
    
    @objc func removeDraft() {
        contentTextView.removeDraft()
        UserDefaults.standard.removeObject(forKey: communityDraftKey)
        UserDefaults.appGroups.removeObject(forKey: appShareExtensionKey)
    }
}
