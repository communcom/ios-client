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


class NotificationsPageVC: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var viewModel: NotificationsPageViewModel!
    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // configure tableView
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: "NotificationCell", bundle: nil), forCellReuseIdentifier: "NotificationCell")
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        // configure navigation bar
        title = "Notifications".localized()
        let navigationBar = navigationController?.navigationBar
        navigationBar?.barTintColor = UIColor.white
        navigationBar?.isTranslucent = false
        navigationBar?.setBackgroundImage(UIImage(), for: .default)
        navigationBar?.shadowImage = UIImage()
        
        // fix bug wit title in tabBarItem
        navigationController?.tabBarItem.title = nil
        
        // initialize viewModel
        viewModel = NotificationsPageViewModel()
        
        // fetchNext
        viewModel.fetchNext()
        
        // bind view model to vc
        bindViewModel()
    }
    
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
        list
            .do(onNext: {[weak self] items in
                items.count > 0 ? self?.hideLoading(): self?.showLoading()
                self?.tableView.refreshControl?.endRefreshing()
            })
            .bind(to: tableView.rx.items(
                cellIdentifier: "NotificationCell",
                cellType: NotificationCell.self)
            ) {index, model, cell in
                cell.configure(with: model)
                
                // fetchNext when reach last 5 items
                if index >= self.viewModel.list.value.count - 5 {
                    self.viewModel.fetchNext()
                }
            }
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
    
    @objc func refresh() {
        viewModel.reload()
    }
}
