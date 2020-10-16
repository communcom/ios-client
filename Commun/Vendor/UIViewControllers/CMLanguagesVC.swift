//
//  CMLanguagesVC.swift
//  Commun
//
//  Created by Chung Tran on 9/18/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxDataSources
import RxCocoa

class CMLanguagesVC: BaseViewController {
    var languageDidSelect: ((Language) -> Void)?
    var supportedLanguages: [Language] { Language.supported }
    
    // MARK: - Subviews
    let closeButton = UIButton.close()
    var tableView = UITableView(forAutoLayout: ())
    lazy var languages = BehaviorRelay<[Language]>(value: supportedLanguages)
    
    // MARK: - Methods
    override func setUp() {
        super.setUp()
        view.backgroundColor = .appLightGrayColor
        title = "language".localized().uppercaseFirst
        setRightNavBarButton(with: closeButton)
        closeButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        
        view.addSubview(tableView)
        tableView.autoPinEdgesToSuperviewSafeArea(with: UIEdgeInsets(top: 20, left: 10, bottom: 0, right: 10))
        tableView.register(LanguageCell.self, forCellReuseIdentifier: "LanguageCell")
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = .clear
    }
    
    override func bind() {
        super.bind()
        let dataSource = MyRxTableViewSectionedAnimatedDataSource<AnimatableSectionModel<String, Language>>(
            configureCell: { _, _, indexPath, item in
                self.configureCell(indexPath: indexPath, item: item)
            }
        )
        
        languages.map {[AnimatableSectionModel<String, Language>](arrayLiteral: AnimatableSectionModel<String, Language>(model: "", items: $0))}
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        tableView.rx.modelSelected(Language.self)
            .subscribe(onNext: { (language) in
                self.modelSelected(item: language)
            })
            .disposed(by: disposeBag)
    }
    
    func configureCell(indexPath: IndexPath, item: Language) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "LanguageCell", for: indexPath) as! LanguageCell
        cell.setUp(with: item)
        
        cell.roundedCorner = []
        
        if indexPath.row == 0 {
            cell.roundedCorner.insert([.topLeft, .topRight])
        }
        
        if indexPath.row == self.languages.value.count - 1 {
            cell.separator.isHidden = true
            cell.roundedCorner.insert([.bottomLeft, .bottomRight])
        }
        return cell
    }
    
    func modelSelected(item: Language) {
        languageDidSelect?(item)
    }
}
