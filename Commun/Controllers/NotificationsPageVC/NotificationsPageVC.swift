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
        viewModel.list.bind(to: tableView.rx.items(
            cellIdentifier: "NotificationCell",
            cellType: NotificationCell.self)
            ) {index, model, cell in
                print(index)
                cell.configure(with: model)
                
                // fetchNext when reach last 5 items
                if index >= self.viewModel.list.value.count - 5 {
                    self.viewModel.fetchNext()
                }
            }
            .disposed(by: bag)
    }
}
