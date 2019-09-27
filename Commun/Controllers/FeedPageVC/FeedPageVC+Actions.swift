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
        
        if viewModel.filter.value.feedTypeMode != .community {
            options.removeAll(where: {$0 == .popular})
        }
        
        showActionSheet(actions: options.map { mode in
            UIAlertAction(title: mode.toString(), style: .default, handler: { (_) in
                self.viewModel.changeFilter(feedType: mode)
            })
        })

    }
    
    @IBAction func sortByTimeButtonDidTouch(_ sender: Any) {
        showActionSheet(actions: FeedTimeFrameMode.allCases.map { mode in
            UIAlertAction(title: mode.toString(), style: .default, handler: { (_) in
                self.viewModel.changeFilter(sortType: mode)
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
        if viewModel.filter.value.feedTypeMode == .subscriptions {
            viewModel.changeFilter(feedTypeMode: .community)
        }
        
        else {
            viewModel.changeFilter(feedTypeMode: .subscriptions, feedType: .timeDesc)
        }
    }
    
    func toggleSearchMode() {
        filterContainerView
            .removeConstraintToSuperView(
                withAttribute: .trailing)
        
        searchBar
            .removeConstraintToSuperView(
                withAttribute: .leading)
        
        if isSearchMode {
            self.searchBackgroundView.backgroundColor = .appMainColor
            
            self.headerLabel.textColor = .white
            self.changeFeedTypeButton.setTitleColor(.white, for: .normal)
            
            self.changeFeedTypeButton.alpha = 0.5
            
            self.changeModeButton.setImage(#imageLiteral(resourceName: "feed-icon-settings"), for: .normal)
            firstSeparatorView.backgroundColor = .appMainColor
            filterContainerView.trailingAnchor
                .constraint(equalTo: filterContainerView.leadingAnchor)
                .isActive = true
            searchBar.leadingAnchor
                .constraint(equalTo: searchBar.superview!.leadingAnchor, constant: 8)
                .isActive = true
            searchBar.becomeFirstResponder()
        }
        else {
            self.searchBackgroundView.backgroundColor = .clear
            
            self.headerLabel.textColor = .black
            
            self.changeFeedTypeButton.setTitleColor(.lightGray, for: .normal)
            self.changeFeedTypeButton.alpha = 1
            self.changeModeButton.setImage(#imageLiteral(resourceName: "search"), for: .normal)
            
            firstSeparatorView.backgroundColor = .groupTableViewBackground
            searchBar.leadingAnchor
                .constraint(equalTo: searchBar.trailingAnchor).isActive = true
            filterContainerView.trailingAnchor
                .constraint(equalTo: filterContainerView.superview!.trailingAnchor, constant: -16)
                .isActive = true
            searchBar.resignFirstResponder()
        }
        
        UIView.animate(withDuration: 0.3) {
            self.tableView.tableHeaderView?.layoutIfNeeded()
        }
    }
    
    @IBAction func changeModeButtonDidTouch(_ sender: Any) {
        // toggle mode
        isSearchMode = !isSearchMode
    }
}
