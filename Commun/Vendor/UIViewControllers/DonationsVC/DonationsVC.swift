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
    let donations: ResponseAPIWalletGetDonationsBulkItem
    var modelSelected: ((ResponseAPIWalletDonation) -> Void)?
    
    // MARK: - Subviews
    lazy var stackView = UIStackView(axis: .vertical, spacing: 0, alignment: .fill, distribution: .fill)
    lazy var tableView: UITableView = {
        let tableView = UITableView(forAutoLayout: ())
        tableView.register(DonatorCell.self, forCellReuseIdentifier: "DonatorCell")
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        return tableView
    }()
    lazy var closeButton: UIButton = {
        let button = UIButton.close(size: 30)
        button.addTarget(self, action: #selector(back), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Initializers
    init(donations: ResponseAPIWalletGetDonationsBulkItem) {
        self.donations = donations
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    override func setUp() {
        super.setUp()
        view.backgroundColor = .appLightGrayColor
        
        view.addSubview(stackView)
        stackView.autoPinEdgesToSuperviewSafeArea()
        
        stackView.addArrangedSubview(tableView.padding(UIEdgeInsets(top: 16, left: 10, bottom: 0, right: 10)))
    }
    
    override func bind() {
        super.bind()
        
        Observable.just(donations.donations)
            .bind(to: tableView.rx.items(cellIdentifier: "DonatorCell"))
                { row, model, cell in
                    let cell = cell as! DonatorCell
                    cell.setUp(with: model, pointType: self.donations.contentId.communityId ?? "")
                    cell.roundedCorner = []
                    
                    if row == 0 {
                        cell.roundedCorner.insert([.topLeft, .topRight])
                    }
                    
                    if row == self.donations.donations.count - 1 {
                        cell.roundedCorner.insert([.bottomLeft, .bottomRight])
                    }
                }
            .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(ResponseAPIWalletDonation.self)
            .subscribe(onNext: { donation in
                self.modelSelected?(donation)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - UIViewControllerTransitioningDelegate
extension DonationsVC: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return HalfSizePresentationController(presentedViewController: presented, presenting: presenting)
    }
}
