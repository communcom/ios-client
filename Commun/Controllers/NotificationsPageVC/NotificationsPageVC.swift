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
        
        // initialize viewModel
        viewModel = NotificationsPageViewModel()
        
        // fetchNext
        viewModel.fetchNext()
        
        // bind view model to vc
        bindViewModel()
    }
    
    func bindViewModel() {
        
        // Bind value to tableView
        viewModel.list
            .do(onNext: {[weak self]_ in
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
        tableView.rx.modelSelected(ResponseAPIOnlineNotificationData.self)
            .subscribe(onNext: {[weak self] notification in
                // mark as read
                self?.viewModel.markAsRead(notification).execute()
                
                // navigate to post page
                if let _ = notification.post,
                    let postPageVC = controllerContainer.resolve(PostPageVC.self) {
                    self?.present(postPageVC, animated: true, completion: nil)
                } else {
                    self?.showAlert(title: "Error".localized(), message: "Something went wrong".localized())
                }
            })
            .disposed(by: bag)
    }
    
    @objc func refresh() {
        viewModel.reload()
    }
}
