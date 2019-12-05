//
//  UserProfilePageVC+Binding.swift
//  Commun
//
//  Created by Chung Tran on 10/29/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import CyberSwift
import RxSwift

extension UserProfilePageVC: UICollectionViewDelegateFlowLayout, CommunityCellDelegate {
    func bindSegmentedControl() {
        headerView.selectedIndex
            .map { index -> UserProfilePageViewModel.SegmentioItem in
                switch index {
                case 0:
                    return .posts
                case 1:
                    return .comments
                default:
                    fatalError("not found selected index")
                }
            }
            .bind(to: (viewModel as! UserProfilePageViewModel).segmentedItem)
            .disposed(by: disposeBag)
    }
    
    @objc func bindCommunities() {
        let highlightCommunities = (viewModel as! UserProfilePageViewModel).highlightCommunities
        
        highlightCommunities
            .skip(1)
            .bind(to: communitiesCollectionView.rx.items(cellIdentifier: "CommunityCollectionCell", cellType: CommunityCollectionCell.self)) { index, model, cell in
                cell.setUp(with: model)
                cell.delegate = self
            }
            .disposed(by: disposeBag)
        
        ResponseAPIContentGetCommunity.observeItemChanged()
            .subscribe(onNext: { (community) in
                var newItems = highlightCommunities.value
                guard let index = newItems.firstIndex(where: {$0.identity == community.identity}) else {return}
                guard let newUpdatedItem = newItems[index].newUpdatedItem(from: community) else {return}
                newItems[index] = newUpdatedItem
                highlightCommunities.accept(newItems)
            })
            .disposed(by: disposeBag)
    }
    
    func forwardDelegate() {
        communitiesCollectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        // select
        communitiesCollectionView.rx
            .modelSelected(ResponseAPIContentGetCommunity.self)
            .subscribe(onNext: { (community) in
                self.showCommunityWithCommunityId(community.communityId)
            })
            .disposed(by: disposeBag)
        
        // tableView
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    }
    
    func bindProfileBlocked() {
        ResponseAPIContentGetProfile.observeEvent(eventName: ResponseAPIContentGetProfile.blockedEventName)
            .subscribe(onNext: { (blockedProfile) in
                guard blockedProfile.userId == self.viewModel.profile.value?.userId else {return}
                self.back()
            })
            .disposed(by: disposeBag)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 140, height: 187)
    }
}

extension UserProfilePageVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let item = viewModel.items.value[safe: indexPath.row] else {
            return UITableView.automaticDimension
        }
        
        switch item {
        case let post as ResponseAPIContentGetPost:
            return post.tableViewCellHeight ?? UITableView.automaticDimension
        case let comment as ResponseAPIContentGetComment:
            return comment.tableViewCellHeight ?? UITableView.automaticDimension
        default:
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let item = viewModel.items.value[safe: indexPath.row] else {
            return UITableView.automaticDimension
        }
        
        switch item {
        case let post as ResponseAPIContentGetPost:
            return post.tableViewCellHeight ?? post.estimatedTableViewCellHeight!
        case let comment as ResponseAPIContentGetComment:
            return comment.tableViewCellHeight ?? comment.estimatedTableViewCellHeight!
        default:
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let item = viewModel.items.value[safe: indexPath.row] else {
            return
        }
        
        switch item {
        case var post as ResponseAPIContentGetPost:
            post.tableViewCellHeight = cell.bounds.height
            (viewModel as! UserProfilePageViewModel).postsVM.updateItem(post)
        case var comment as ResponseAPIContentGetComment:
            comment.tableViewCellHeight = cell.bounds.height
            (viewModel as! UserProfilePageViewModel).commentsVM.updateItem(comment)
        default:
            break
        }
    }
}

