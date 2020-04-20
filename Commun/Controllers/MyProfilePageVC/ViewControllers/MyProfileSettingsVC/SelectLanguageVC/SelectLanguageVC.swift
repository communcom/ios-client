//
//  SelectLanguageVC.swift
//  Commun
//
//  Created by Chung Tran on 11/1/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxDataSources
import RxCocoa
import Localize_Swift

class SelectLanguageVC: BaseViewController {
    // MARK: - Nested type
    struct Language: IdentifiableType, Equatable {
        let code: String
        let name: String
        let imageName: String
        var isSelected: Bool = false
        var identity: String {code}
    }
    
    // MARK: - Properties
    let supportedLanguages: [Language] = [
        Language(code: "en", name: "english", imageName: "american-flag"),
        Language(code: "ru", name: "russian", imageName: "russian-flag")
    ]
    
    // MARK: - Subviews
    let closeButton = UIButton.close()
    var tableView = UITableView(forAutoLayout: ())
    lazy var languages = BehaviorRelay<[Language]>(value: supportedLanguages)
    
    // MARK: - Methods
    override func setUp() {
        super.setUp()
        view.backgroundColor = .f3f5fa
        title = "language".localized().uppercaseFirst
        setRightNavBarButton(with: closeButton)
        closeButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        
        view.addSubview(tableView)
        tableView.autoPinEdgesToSuperviewSafeArea(with: UIEdgeInsets(top: 20, left: 10, bottom: 0, right: 10))
        tableView.register(LanguageCell.self, forCellReuseIdentifier: "LanguageCell")
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = .clear
        
        // get current language
        let langs: [Language] = languages.value.map { lang in
            var lang = lang
            if lang.code == Localize.currentLanguage() {lang.isSelected = true}
            return lang
        }
        languages.accept(langs)
    }
    
    override func bind() {
        super.bind()
        let dataSource = MyRxTableViewSectionedAnimatedDataSource<AnimatableSectionModel<String, Language>>(
            configureCell: { _, _, indexPath, item in
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
        )
        
        languages.map {[AnimatableSectionModel<String, Language>](arrayLiteral: AnimatableSectionModel<String, Language>(model: "", items: $0))}
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
}
