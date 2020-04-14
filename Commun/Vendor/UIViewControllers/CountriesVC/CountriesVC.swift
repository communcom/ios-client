//
//  CountriesVC.swift
//  Commun
//
//  Created by Chung Tran on 3/24/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxCocoa

class CountriesVC: BaseViewController, UISearchResultsUpdating {
    // MARK: - Properties
    var selectionHandler: ((Country) -> Void)?
    let allCountries = Country.getAll()
    lazy var countries = BehaviorRelay<[Country]>(value: allCountries)
    lazy var searchController = UISearchController(searchResultsController: nil)
    
    // MARK: - Subviews
    lazy var tableView = UITableView(forAutoLayout: ())
    
    // MARK: - Methods
    override func setUp() {
        super.setUp()
        title = "select country".localized().uppercaseFirst
        
        // Set up navigation bar
        let closeButton = UIBarButtonItem(title: "close".localized().uppercaseFirst, style: .plain, target: nil, action: nil)
        
        closeButton.rx
            .tap
            .subscribe(onNext: { [weak self] _ in
                self?.navigationController?.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        navigationItem.leftBarButtonItem = closeButton
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        
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
        
        tableView.rx.modelSelected(Country.self)
            .subscribe(onNext: selectionHandler)
            .disposed(by: disposeBag)
    }
    
    // MARK: - SearchResultUpdating
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else {
            countries.accept(allCountries)
            return
        }
        
        if text.trimmed.isEmpty {
            countries.accept(allCountries)
        } else {
            countries.accept(allCountries.filter {$0.name.lowercased().contains(text.lowercased())})
        }
    }
}
