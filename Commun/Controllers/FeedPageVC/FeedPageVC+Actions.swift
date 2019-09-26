//
//  FeedPageVC+Actions.swift
//  Commun
//
//  Created by Chung Tran on 9/26/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

extension FeedPageVC {
    @IBAction func postButtonDidTouch(_ sender: Any) {
        openEditor()
    }
    
    @IBAction func photoButtonDidTouch(_ sender: Any) {
        openEditor { (editorVC) in
            editorVC.cameraButtonTap()
        }
    }
    
    func openEditor(completion: ((EditorPageVC)->Void)? = nil) {
        let editorVC = controllerContainer.resolve(EditorPageVC.self)
        let nav = UINavigationController(rootViewController: editorVC!)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: {
            completion?(editorVC!)
        })
    }
    
    @IBAction func sortByTypeButtonDidTouch(_ sender: Any) {
        var options = FeedSortMode.allCases
        
        if viewModel.feedTypeMode.value != .community {
            options.removeAll(where: {$0 == .popular})
        }
        
        showActionSheet(actions: options.map { mode in
            UIAlertAction(title: mode.toString(), style: .default, handler: { (_) in
                self.viewModel.feedType.accept(mode)
            })
        })

    }
    
    @IBAction func sortByTimeButtonDidTouch(_ sender: Any) {
        showActionSheet(actions: FeedTimeFrameMode.allCases.map { mode in
            UIAlertAction(title: mode.toString(), style: .default, handler: { (_) in
                self.viewModel.sortType.accept(mode)
            })
        })
    }
    
    @objc func didTapTryAgain(gesture: UITapGestureRecognizer) {
        guard let label = gesture.view as? UILabel,
            let text = label.text else {return}
        
        let tryAgainRange = (text as NSString).range(of: "try again".localized().uppercaseFirst)
        if gesture.didTapAttributedTextInLabel(label: label, inRange: tryAgainRange) {
            self.viewModel.fetchNext()
        }
    }
    
    @objc func refresh() {
        viewModel.reload()
    }
    
    @IBAction func changeFeedTypeButtonDidTouch(_ sender: Any) {
        if viewModel.feedTypeMode.value == .subscriptions {
            viewModel.feedTypeMode.accept(.community)
        }
        
        else {
            viewModel.feedTypeMode.accept(.subscriptions)
            viewModel.feedType.accept(.timeDesc)
        }
    }
}
