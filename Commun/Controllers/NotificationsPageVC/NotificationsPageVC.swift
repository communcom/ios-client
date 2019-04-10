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
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var viewModel: NotificationsPageViewModel!
    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // configure tableView
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        tableView.tableFooterView = UIView()
        
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    func bindViewModel() {
        // Search by keyword
        searchBar.rx.searchButtonClicked
            .withLatestFrom(searchBar.rx.text.orEmpty)
            .filter {$0.count > 0}
//            .flatMapLatest(<#T##selector: (String?) throws -> ObservableConvertibleType##(String?) throws -> ObservableConvertibleType#>)
            .subscribe(onNext: { (string) in
                print(string)
            })
            .disposed(by: bag)
        
        // Discard keyboard
        Observable.merge(tableView.rx.didScroll.asObservable(), searchBar.rx.searchButtonClicked.asObservable())
            .bind(to: resignFirstResponder)
            .disposed(by: bag)
        
    }
    
    private var resignFirstResponder: AnyObserver<Void> {
        return Binder(self) { me, _ in
            me.searchBar.resignFirstResponder()
            }.asObserver()
    }
    
}
