//
//  NotificationPageVC+Binding.swift
//  Commun
//
//  Created by Chung Tran on 03/06/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxDataSources
import RxSwift

public typealias NotificationSection = AnimatableSectionModel<String, ResponseAPIOnlineNotificationData>

extension NotificationsPageVC {
    func bindViewModel() {
        let list = viewModel.list
        
        // Mark all as viewed
        list.take(1)
            .flatMap {_ in
                return NetworkService.shared.markAllAsViewed()
            }
            .map {_ in nil}
            .catchErrorJustReturn(nil)
            .bind(to: tabBarItem!.rx.badgeValue)
            .disposed(by: bag)
        
        // Bind value to tableView
        let dataSource = RxTableViewSectionedAnimatedDataSource<NotificationSection>(configureCell: {_, _, indexPath, item in
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "NotificationCell") as! NotificationCell
            cell.configure(with: item)
            if indexPath.row >= self.viewModel.list.value.count - 5 {
                self.viewModel.fetchNext()
            }
            return cell
        })
        
        list
            .do(onNext: {[weak self] items in
                self?.tableView.refreshControl?.endRefreshing()
            })
            .map {[NotificationSection(model: "", items: $0)]}
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: bag)
        
        // tableView
        Observable.zip(
            tableView.rx.itemSelected,
            tableView.rx.modelSelected(ResponseAPIOnlineNotificationData.self)
            )
            .do(onNext: {[weak self] indexPath, _ in
                self?.tableView.deselectRow(at: indexPath, animated: false)
            })
            .subscribe(onNext: {[weak self] _, notification in
                // mark as read
                self?.viewModel.markAsRead(notification).execute()
                
                // navigate to post page
                if let post = notification.post,
                    let postPageVC = controllerContainer.resolve(PostPageVC.self) {
                    postPageVC.viewModel.permlink = post.contentId.permlink
                    postPageVC.viewModel.userId = post.contentId.userId
                    self?.show(postPageVC, sender: nil)
                }
            })
            .disposed(by: bag)
    }
}
