//
//  DonatorsViewController.swift
//  Commun
//
//  Created by Chung Tran on 6/11/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

class DonationsVC: BaseViewController {
    // MARK: - Properties
    let donations: [ResponseAPIWalletDonation]
    
    // MARK: - Subviews
    lazy var tableView = UITableView(forAutoLayout: ())
    
    // MARK: - Initializers
    init(donations: [ResponseAPIWalletDonation]) {
        self.donations = donations
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appLightGrayColor
        
        title = "donations".localized().uppercaseFirst
    }
    
    override func setUp() {
        super.setUp()
        
        tableView.backgroundColor = .clear
        view.addSubview(tableView)
        tableView.autoPinEdgesToSuperviewSafeArea(with: UIEdgeInsets(inset: 16))
        
        tableView.register(DonatorCell.self, forCellReuseIdentifier: "DonatorCell")
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
    }
    
    override func bind() {
        super.bind()
        
        Observable.just(donations)
            .bind(to: tableView.rx.items(cellIdentifier: "DonatorCell"))
                { _, model, cell in
                    let cell = cell as! DonatorCell
                    cell.setUp(with: model)
                }
            .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(ResponseAPIWalletDonation.self)
            .subscribe(onNext: { donation in
                self.showProfileWithUserId(donation.sender.userId)
            })
            .disposed(by: disposeBag)
    }
}
