//
//  ProfilePageVC+Binding.swift
//  Commun
//
//  Created by Chung Tran on 19/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import UIKit
import CyberSwift
import RxSwift
import RxCocoa

extension ProfilePageVC: CommentCellDelegate {
    
    func bindViewModel() {
        // Scroll view
        if !viewModel.isMyProfile {
            tableView.rx.didScroll
                .map {_ in self.tableView.contentOffset.y >= -425}
                .subscribe(onNext: {self.showTitle($0, animated: true)})
                .disposed(by: disposeBag)
        }
        
        // Profile
        viewModel.profile.filter {$0 != nil}.subscribe(onNext: { [weak self] _ in
            self?.segmentio.selectedSegmentioIndex = 0
        }).disposed(by: disposeBag)
        
        let profile = viewModel.profile.asDriver()
        
        // End refreshing
        profile.map {_ in false}
            .drive(tableView.refreshControl!.rx.isRefreshing)
            .disposed(by: disposeBag)
        
        // Bind state
        let isProfileMissing = profile.map {$0 == nil}
        
        isProfileMissing
            .drive(tableView.rx.isHidden)
            .disposed(by: disposeBag)
        
        // Got profile
        let nonNilProfile = profile.filter {$0 != nil}.map {$0!}
        
        nonNilProfile
            .drive(self.rx.profile)
            .disposed(by: disposeBag)
        
        // Bind bios
        let bioText = bioLabel.rx.observe(String.self, "text")
        
        bioText.map{$0 == nil}.bind(to: bioLabel.rx.isHidden).disposed(by: disposeBag)
        
        if viewModel.isMyProfile {
            bioText.map{$0 != nil}.bind(to: addBioButton.rx.isHidden).disposed(by: disposeBag)
        }
        
        // Bind items
        let items = viewModel.items.share()
        
        items
            .bind(to: tableView.rx.items) {table, index, element in
                guard let element = element else {
                    let cell = self.tableView.dequeueReusableCell(withIdentifier: "EmptyCell") as! EmptyCell
                    cell.setUp(with: self.viewModel.segmentedItem.value)
                    return cell
                }
                
                if index == self.tableView.numberOfRows(inSection: 0) - 2 {
                    self.viewModel.fetchNext()
                }
                
                if let post = element as? ResponseAPIContentGetPost {
                    switch post.document.attributes?.type {
                    case "article":
                        let cell = self.tableView.dequeueReusableCell(withIdentifier: "ArticlePostCell") as! ArticlePostCell
                        cell.setUp(with: post)
                        return cell
                    case "basic":
                        let cell = self.tableView.dequeueReusableCell(withIdentifier: "BasicPostCell") as! BasicPostCell
                        cell.setUp(with: post)
                        return cell
                    default:
                        return UITableViewCell()
                    }
                }
                
                if let comment = element as? ResponseAPIContentGetComment {
                    let cell = self.tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
                    cell.delegate = self
                    cell.setupFromComment(comment, expanded: self.expandedIndexes.contains(index))
                    return cell
                }
                
                fatalError("Unknown cell type")
            }
            .disposed(by: disposeBag)
        
        // Reset expandable
        items
            .subscribe(onNext: {_ in
                self.expandedIndexes = []
            })
            .disposed(by: disposeBag)
        
        // OnItemSelected
        tableView.rx.itemSelected
            .subscribe(onNext: {indexPath in
                let cell = self.tableView.cellForRow(at: indexPath)
                switch cell {
                case is PostCell:
                    if let postPageVC = controllerContainer.resolve(PostPageVC.self)
                    {
                        let post = self.viewModel.postsVM.items.value[indexPath.row]
                        postPageVC.viewModel.postForRequest = post
                        self.show(postPageVC, sender: nil)
                    } else {
                        self.showAlert(title: "error".localized().uppercaseFirst, message: "something went wrong".localized().uppercaseFirst)
                    }
                    break
                case is CommentCell:
                    #warning("Tap a comment")
                    break
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
        
        // Copy referral button
        #warning("Action for copy referral button")
    }
}
