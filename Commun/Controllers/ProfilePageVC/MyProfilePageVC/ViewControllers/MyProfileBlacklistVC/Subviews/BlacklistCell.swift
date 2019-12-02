//
//  BlacklistUserCell.swift
//  Commun
//
//  Created by Chung Tran on 11/13/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxSwift

protocol BlacklistCellDelegate: class {
    func blockButtonDidTouch(item: ResponseAPIContentGetBlacklistItem)
}

extension BlacklistCellDelegate where Self: BaseViewController {
    func blockButtonDidTouch(item: ResponseAPIContentGetBlacklistItem) {
        guard let id = item.userValue?.userId ?? item.communityValue?.communityId
            else {return}
        
        // Apply changes immediately, if error occurs, reverse these changes
        var originIsBlocked: Bool
        switch item {
        case .user(var user):
            originIsBlocked = user.isBlocked ?? true
            user.isBeingUnblocked = true
            user.isBlocked = !originIsBlocked
            user.notifyChanged()
        case .community(var community):
            originIsBlocked = community.isBlocked ?? true
            community.isBeingUnblocked = true
            community.isBlocked = !originIsBlocked
            community.notifyChanged()
        }
        
        // Prepare request
        var request: Single<String>
        if originIsBlocked {
            switch item {
            case .user(_):
                request = RestAPIManager.instance.unblock(id)
            case .community(_):
                request = RestAPIManager.instance.unhideCommunity(id)
            }
            
        }
        else {
            switch item {
            case .user(_):
                request = RestAPIManager.instance.block(id)
            case .community(_):
                request = RestAPIManager.instance.hideCommunity(id)
            }
        }
        
        // Send request
        request
            .flatMapCompletable {RestAPIManager.instance.waitForTransactionWith(id: $0)}
            .subscribe(onCompleted: {
                // reset loading to false
                switch item {
                case .user(var user):
                    user.isBlocked = !originIsBlocked
                    user.isBeingUnblocked = false
                    user.notifyChanged()
                case .community(var community):
                    community.isBlocked = !originIsBlocked
                    community.isBeingUnblocked = false
                    community.notifyChanged()
                }
            }) { [weak self] (error) in
                guard let strongSelf = self else {return}
                strongSelf.showError(error)
                
                // reverse, reset loading to false
                switch item {
                case .user(var user):
                    user.isBeingUnblocked = false
                    user.isBeingUnblocked = originIsBlocked
                    user.notifyChanged()
                case .community(var community):
                    community.isBeingUnblocked = false
                    community.isBeingUnblocked = originIsBlocked
                    community.notifyChanged()
                }
            }
            .disposed(by: disposeBag)
    }
}

class BlacklistCell: SubsItemCell, ListItemCellType {
    // MARK: - Properties
    var item: ResponseAPIContentGetBlacklistItem?
    weak var delegate: BlacklistCellDelegate?
    
    func setUp(with item: ResponseAPIContentGetBlacklistItem) {
        self.item = item
        switch item {
        case .user(let user):
            avatarImageView.setAvatar(urlString: user.avatarUrl, namePlaceHolder: user.username)
            nameLabel.text = user.username
            actionButton.isEnabled = !(user.isBeingUnblocked ?? false)
            actionButton.setTitle((user.isBlocked ?? true) ? "unblock".localized().uppercaseFirst : "reblock".localized().uppercaseFirst, for: .normal)
            actionButton.backgroundColor = !(user.isBlocked ?? true) ? #colorLiteral(red: 0.9525656104, green: 0.9605062604, blue: 0.9811610579, alpha: 1) : .appMainColor
            actionButton.setTitleColor(!(user.isBlocked ?? true) ? .appMainColor : .white , for: .normal)
        case .community(let community):
            avatarImageView.setAvatar(urlString: nil, namePlaceHolder: community.name)
            nameLabel.text = community.name
            actionButton.isEnabled = !(community.isBeingUnblocked ?? false)
            actionButton.setTitle((community.isBlocked ?? true) ? "unhide".localized().uppercaseFirst : "hide".localized().uppercaseFirst, for: .normal)
            actionButton.backgroundColor = !(community.isBlocked ?? true) ? #colorLiteral(red: 0.9525656104, green: 0.9605062604, blue: 0.9811610579, alpha: 1) : .appMainColor
            actionButton.setTitleColor(!(community.isBlocked ?? true) ? .appMainColor : .white , for: .normal)
        }
        statsLabel.text = nil
    }
    
    override func actionButtonDidTouch() {
        guard let item = item else {return}
        delegate?.blockButtonDidTouch(item: item)
    }
}
