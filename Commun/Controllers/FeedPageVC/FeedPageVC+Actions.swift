//
//  FeedPageVC+Actions.swift
//  Commun
//
//  Created by Chung Tran on 9/26/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

extension FeedPageVC {
    @IBAction func changeFeedTypeButtonDidTouch(_ sender: Any) {
        toggleFeedType()
    }
    
    @IBAction func changeFilterButtonDidTouch(_ sender: Any) {
        openFilterVC()
    }
    
    @IBAction func postButtonDidTouch(_ sender: Any) {
        openEditor()
    }
    
    @IBAction func photoButtonDidTouch(_ sender: Any) {
        openEditor { (editorVC) in
            editorVC.addImage()
        }
    }
    
    func openEditor(completion: ((BasicEditorVC)->Void)? = nil) {
        let editorVC = BasicEditorVC()
        editorVC.modalPresentationStyle = .fullScreen
        present(editorVC, animated: true, completion: {
            completion?(editorVC)
        })
    }
}
