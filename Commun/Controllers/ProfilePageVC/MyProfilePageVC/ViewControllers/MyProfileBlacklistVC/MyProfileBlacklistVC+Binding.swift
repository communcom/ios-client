//
//  MyProfileBlacklistVC+Binding.swift
//  Commun
//
//  Created by Chung Tran on 11/13/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxDataSources
import CyberSwift

extension MyProfileBlacklistVC {
    func bindSegmentedControl() {
        topTabBar.selectedIndex
            .map { index -> MyProfileBlacklistViewModel.SegmentedItem in
                switch index {
                case 0:
                    return .users
                case 1:
                    return .communities
                default:
                    fatalError("not found selected index")
                }
            }
            .bind(to: viewModel.segmentedItem)
            .disposed(by: disposeBag)
    }
    
    func bindState() {
        viewModel.listLoadingState
            .subscribe(onNext: { [weak self] (state) in
                switch state {
                case .loading(let isLoading):
                    self?.handleListLoading(isLoading: isLoading)
                case .listEnded:
                    self?.handleListEnded()
                case .listEmpty:
                    self?.handleListEmpty()
                case .error(_):
                    self?.handleListError()
                }
            })
            .disposed(by: disposeBag)
    }
    
    func bindList() {
        // bind items
        let dataSource = MyRxTableViewSectionedAnimatedDataSource<AnimatableSectionModel<String, ResponseAPIContentGetBlacklistItem>>(
            configureCell: { (dataSource, tableView, indexPath, element) -> UITableViewCell in
                let cell = self.tableView.dequeueReusableCell(withIdentifier: "BlacklistCell") as! BlacklistCell
                cell.setUp(with: element)
                return cell
            }
        )
        
        viewModel.items
            .map {[AnimatableSectionModel<String, ResponseAPIContentGetBlacklistItem>(model: "", items: $0)]}
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        // OnItemSelected
        tableView.rx.modelSelected(ResponseAPIContentGetBlacklistItem.self)
            .subscribe(onNext: { (element) in
                switch element {
                case .user(let profile):
                    self.showProfileWithUserId(profile.userId)
                case .community(let community):
                    self.showCommunityWithCommunityId(community.communityId)
                }
            })
            .disposed(by: disposeBag)
    }
}
