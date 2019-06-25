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
import DZNEmptyDataSet

class NotificationsPageVC: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var viewModel: NotificationsPageViewModel!
    let bag = DisposeBag()
    
    var dataSource: MyRxTableViewSectionedAnimatedDataSource<NotificationSection>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // configure tableView
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: "NotificationCell", bundle: nil), forCellReuseIdentifier: "NotificationCell")
        
        // tableView dataSource
        dataSource = MyRxTableViewSectionedAnimatedDataSource<NotificationSection>(configureCell: {_, _, indexPath, item in
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "NotificationCell") as! NotificationCell
            cell.configure(with: item)
            if indexPath.row >= self.viewModel.list.value.count - 5 {
                self.viewModel.fetchNext()
            }
            return cell
        })
        
        // tableView emptyDataSet
        tableView.emptyDataSetDelegate = self
        tableView.emptyDataSetSource = self
        
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
            if self?.viewModel.fetcher.reachedTheEnd == true {return}
            self?.tableView.addNotificationsLoadingFooterView()
        }
        
        viewModel.listEndedHandler = { [weak self] in
            self?.tableView.tableFooterView = UIView()
        }
        
        viewModel.fetchNextErrorHandler = {[weak self] error in
            guard let strongSelf = self else {return}
            strongSelf.tableView.addListErrorFooterView(with: #selector(strongSelf.didTapTryAgain(gesture:)), on: strongSelf)
        }
        
        // fetchNext
        viewModel.fetchNext()
        
        // bind view model to vc
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.setTitleFont(.boldSystemFont(ofSize: 17), color:
            .black)
    }
    
    @objc func refresh() {
        viewModel.reload()
    }
    
    @objc func didTapTryAgain(gesture: UITapGestureRecognizer) {
        guard let label = gesture.view as? UILabel,
            let text = label.text else {return}
        
        let tryAgainRange = (text as NSString).range(of: "Try again".localized())
        if gesture.didTapAttributedTextInLabel(label: label, inRange: tryAgainRange) {
            self.viewModel.fetchNext()
        }
    }
}
