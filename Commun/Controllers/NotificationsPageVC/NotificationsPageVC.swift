//
//  NotificationsPageViewController.swift
//  Commun
//
//  Created by Chung Tran on 10/04/2019.
//  Copyright (c) 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import CyberSwift
import RxDataSources

class NotificationsPageVC: ListViewController<ResponseAPIOnlineNotificationData> {
    
    override func setUp() {
        super.setUp()
        // initialize viewModel
        viewModel = NotificationsViewModel()
        
        // configure navigation bar
        title = "notifications".localized().uppercaseFirst
        
        // configure tableView
        tableView.estimatedRowHeight = 80
        tableView.tableFooterView = UIView()
        
        tableView.register(UINib(nibName: "NotificationCell", bundle: nil), forCellReuseIdentifier: "NotificationCell")
        
        dataSource = MyRxTableViewSectionedAnimatedDataSource<ListSection>(configureCell: {_, _, indexPath, item in
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "NotificationCell") as! NotificationCell
            cell.configure(with: item)
            if indexPath.row >= self.viewModel.items.value.count - 5 {
                self.viewModel.fetchNext()
            }
            return cell
        })
    }
    
    override func bind() {
        super.bind()
        let list = viewModel.items
        
        // Mark all as viewed
        list.take(1)
            .flatMap {_ in
                return NetworkService.shared.markAllAsViewed()
            }
            .map {_ in nil}
            .catchErrorJustReturn(nil)
            .bind(to: tabBarItem!.rx.badgeValue)
            .disposed(by: disposeBag)
        
        // tableView
        Observable.zip(
            tableView.rx.itemSelected,
            tableView.rx.modelSelected(ResponseAPIOnlineNotificationData.self)
            )
            .do(onNext: {[weak self] indexPath, _ in
                self?.tableView.deselectRow(at: indexPath, animated: false)
            })
            .subscribe(onNext: {[weak self] _, notification in
                if let strongSelf = self, notification.unread == true {
                    (strongSelf.viewModel as! NotificationsViewModel).markAsRead(notification)
                        .subscribe(onCompleted: {
                            if let index = strongSelf.viewModel.items.value.firstIndex(of: notification) {
                                var newNotification = notification
                                newNotification.unread = false
                                var newList = strongSelf.viewModel.items.value
                                newList[index] = newNotification
                                strongSelf.viewModel.items.accept(newList)
                            }
                        })
                        .disposed(by: strongSelf.disposeBag)
                }
                
                // navigate to post page
                if let post = notification.post {
                    let postPageVC = PostPageVC(userId: post.contentId.userId, permlink: post.contentId.permlink, communityId: post.contentId.communityId ?? "")
                    self?.show(postPageVC, sender: nil)
                    return
                }
                
                // navigate to profile page
                if let userId = notification.actor?.userId {
                    self?.showProfileWithUserId(userId)
                    return
                }
            })
            .disposed(by: disposeBag)
        
        tableView.rx.contentOffset
            .map {$0.y > 3}
            .distinctUntilChanged()
            .subscribe(onNext: { (showShadow) in
                if showShadow {
                    self.navigationController?.navigationBar.addShadow(ofColor: .shadow, offset: CGSize(width: 0, height: 2), opacity: 0.1)
                }
                else {
                    self.navigationController?.navigationBar.shadowOpacity = 0
                }
            })
            .disposed(by: disposeBag)
    }
    
    override func showLoadingFooter() {
        tableView.addNotificationsLoadingFooterView()
    }
    
    override func handleListEmpty() {
        let title = "no notification"
        let description = "notifications not found"
        tableView.addEmptyPlaceholderFooterView(title: title.localized().uppercaseFirst, description: description.localized().uppercaseFirst, buttonLabel: "reload".localized().uppercaseFirst)
        {
            self.viewModel.reload()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.setTitleFont(.boldSystemFont(ofSize: 17), color:
            .black)
        self.setStatusBarStyle(.default)
    }
}
