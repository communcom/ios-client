//
//  SelectCountryVC.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 12/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import RxSwift
import CyberSwift

class SelectCountryVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var viewModel: SelectCountryViewModel?
    
    let searchController = UISearchController(searchResultsController: nil)
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Select country"
        
        tableView.register(UINib(nibName: "CountryCell", bundle: nil), forCellReuseIdentifier: "CountryCell")
        tableView.rowHeight = 56
        
        let closeButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: nil)
        self.navigationItem.leftBarButtonItem = closeButton
        closeButton.rx.tap.subscribe(onNext: { [weak self] _ in
            self?.navigationController?.dismiss(animated: true, completion: nil)
        }).disposed(by: disposeBag)
        
        self.navigationItem.searchController = searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
        
        setupActions()
        setupBindings()
    }

    func bindViewModel(_ model: SelectCountryViewModel) {
        self.viewModel = model
    }
    
    func setupBindings() {
        if let viewModel = viewModel {
            viewModel.countries.bind(to: tableView.rx.items(cellIdentifier: "CountryCell")) { (index, model, cell) in
                (cell as! CountryCell).setupCountry(model)
            }.disposed(by: disposeBag)
        }
    }
    
    func setupActions() {
        if let viewModel = viewModel {
            searchController.searchBar.rx.text.orEmpty.bind(to: viewModel.search).disposed(by: disposeBag)
            tableView.rx.modelSelected(Country.self).bind(to: viewModel.selectedCountry).disposed(by: disposeBag)
            tableView.rx.itemSelected.subscribe(onNext: { _ in
                self.navigationController?.dismiss(animated: true, completion: nil)
            }).disposed(by: disposeBag)
        }
    }
    
}
