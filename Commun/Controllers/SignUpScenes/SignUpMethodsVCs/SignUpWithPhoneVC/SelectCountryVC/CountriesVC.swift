//
//  CountriesVC.swift
//  Commun
//
//  Created by Chung Tran on 3/24/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxCocoa

class CountriesVC: BaseViewController {
    // MARK: - Properties
    lazy var countries = BehaviorRelay<[Country]>(value: Country.getAll())
    lazy var searchController = UISearchController(searchResultsController: nil)
    
    // MARK: - Subviews
    lazy var tableView = UITableView(forAutoLayout: ())
    
    // MARK: - Methods
    override func setUp() {
        super.setUp()
        title = "select country".localized().uppercaseFirst
        AnalyticsManger.shared.registrationOpenScreen(1)
        
        // Set up navigation bar
        let closeButton = UIBarButtonItem(title: "close".localized().uppercaseFirst, style: .plain, target: nil, action: nil)
        
        closeButton.rx
            .tap
            .subscribe(onNext: { [weak self] _ in
                self?.navigationController?.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        navigationItem.leftBarButtonItem = closeButton
        
        self.navigationItem.searchController = searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.definesPresentationContext = true
        searchController.obscuresBackgroundDuringPresentation = false
        
        // Set up tableView
        view.addSubview(tableView)
        tableView.autoPinEdgesToSuperviewSafeArea()
        
        tableView.register(UINib(nibName: "CountryCell", bundle: nil), forCellReuseIdentifier: "CountryCell")
        tableView.rowHeight = 56.0 * Config.heightRatio
        
    }
    
    override func bind() {
        super.bind()
        countries
            .bind(to: tableView.rx.items(cellIdentifier: "CountryCell")) { (_, model, cell) in
                (cell as! CountryCell).setupCountry(model)
            }
            .disposed(by: disposeBag)
    }
}
