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
import Action
import RxSwift
import RxMediaPicker

extension ProfilePageVC {
    enum ImageType {
        case cover, avatar
    }
    
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
        
        // Bind items
        viewModel.items.skip(1)
            .bind(to: tableView.rx.items) {table, index, element in
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
        
        // Image selectors
        mediaPicker = RxMediaPicker(delegate: self)
        coverSelectButton.rx.action = onUpdate(.cover)
        avatarSelectButton.rx.action = onUpdate(.avatar)
        
        // Bind image
        viewModel.avatarImage
            .asDriver(onErrorJustReturn: nil)
            .filter {$0 != nil}
            .drive(userAvatarImage.rx.image)
            .disposed(by: bag)
        
        viewModel.coverImage
            .asDriver(onErrorJustReturn: nil)
            .filter {$0 != nil}
            .drive(userCoverImage.rx.image)
            .disposed(by: bag)
    }
    
    // MARK: - Actions
    // Image selection
    func onUpdate(_ imageType: ImageType) -> CocoaAction {
        return Action {_ in
            return self.mediaPicker.selectImage(source: .photoLibrary, editable: false)
                .flatMap({ (image, _) -> Observable<Void> in
                    switch imageType {
                    case .avatar:
                        self.viewModel.avatarImage.accept(image)
                        break
                    case .cover:
                        self.viewModel.coverImage.accept(image)
                        break
                    }
                    #warning("Send image change request to server")
                    return .just(())
                })
        }
    }
}

extension ProfilePageVC: RxMediaPickerDelegate {
    func present(picker: UIImagePickerController) {
        present(picker, animated: true, completion: nil)
    }
    
    func dismiss(picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
