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

extension ProfilePageVC: PostCardCellDelegate, CommentCellDelegate {
    
    func bindViewModel() {
        let profile = viewModel.profile.asDriver()
        
        // End refreshing
        profile.map {_ in false}
            .drive(tableView.refreshControl!.rx.isRefreshing)
            .disposed(by: bag)
        
        // Bind state
        let isProfileMissing = profile.map {$0 == nil}
        
        isProfileMissing
            .drive(tableView.rx.isHidden)
            .disposed(by: bag)
        
        isProfileMissing
            .drive(activityIndicator.rx.isAnimating)
            .disposed(by: bag)
        
        // Got profile
        let nonNilProfile = profile.filter {$0 != nil}.map {$0!}
        
        nonNilProfile
            .drive(self.rx.profile)
            .disposed(by: bag)
        
        // Bind bios
        let bioText = bioLabel.rx.observe(String.self, "text")
        
        bioText.map{$0 == nil}.bind(to: bioLabel.rx.isHidden).disposed(by: bag)
        bioText.map{$0 != nil}.bind(to: addBioButton.rx.isHidden).disposed(by: bag)
        
        // Bind items
        viewModel.items.skip(1)
            .map { items -> [AnyObject?] in
                if items.count == 0 {
                    return [nil]
                }
                return items as [AnyObject?]
            }
            .bind(to: tableView.rx.items) {table, index, element in
                if index >= self.viewModel.items.value.count - 5 {
                    self.viewModel.fetchNext()
                }
                
                if element == nil {
                    let cell = self.tableView.dequeueReusableCell(withIdentifier: "ProfilePageEmptyCell") as! ProfilePageEmptyCell
                    cell.setUp(with: self.viewModel.segmentedItem.value)
                    return cell
                }
                
                if let post = element as? ResponseAPIContentGetPost {
                    let cell = self.tableView.dequeueReusableCell(withIdentifier: "PostCardCell") as! PostCardCell
                    cell.delegate = self
                    cell.post = post
                    cell.setupFromPost(post)
                    return cell
                }
                
                if let comment = element as? ResponseAPIContentGetComment {
                    let cell = self.tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
                    cell.delegate = self
                    cell.setupFromComment(comment)
                    return cell
                }
                
                fatalError("Unknown cell type")
            }
            .disposed(by: bag)
        
        // OnItemSelected
        tableView.rx.itemSelected
            .subscribe(onNext: {indexPath in
                let cell = self.tableView.cellForRow(at: indexPath)
                switch cell {
                case is PostCardCell:
                    if let postPageVC = controllerContainer.resolve(PostPageVC.self),
                        let post = self.viewModel.items.value[indexPath.row] as? ResponseAPIContentGetPost{
                        postPageVC.viewModel.postForRequest = post
                        self.present(postPageVC, animated: true, completion: nil)
                    } else {
                        self.showAlert(title: "Error", message: "Something went wrong")
                    }
                    break
                case is CommentCell:
                    #warning("Tap a comment")
                    break
                default:
                    break
                }
            })
            .disposed(by: bag)
        
        // Copy referral button
        #warning("Action for copy referral button")
    }
}
