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
    let bag = DisposeBag()
    
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
        viewModel.loadingHandler = {[weak self] in
            self?.tableView.addNotificationsLoadingFooterView()
        }
        
        // fetchNext
        viewModel.fetchNext()
        
        // bind view model to vc
        bindViewModel()
    }
    
    @objc func refresh() {
        viewModel.reload()
    }
}
