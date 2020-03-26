//
//  LanguageVC.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 22/04/2019.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import UIKit
import Localize_Swift
import RxSwift

struct Language {
    var name: String
    var code: String
    let shortCode: String
    
    static var supportedLanguages: [Language] {
        return [
            Language(name: "English (UK)", code: "UK", shortCode: "en"),
            Language(name: "Russian (RUS)", code: "Ru", shortCode: "ru")
        ]
    }
    
    static var currentLanguage: Language {
        return supportedLanguages.first(where: { (lang) -> Bool in
            return lang.shortCode == Localize.currentLanguage()
        }) ?? Language(name: "English (UK)", code: "UK", shortCode: "en")
    }
}

protocol LanguageVCDelegate: class {
    func didSelectLanguage(_ language: Language)
}

class LanguageVC: BaseViewController {
    // MARK: - Properties
    var searchController = UISearchController(searchResultsController: nil) // С поиском будут доработки
    
    weak var delegate: LanguageVCDelegate?
    var didChangeLanguage = PublishSubject<Language>()
    
    // MARK: - IBOutlets
    lazy var tableView = UITableView(forAutoLayout: ())
    
    // MARK: - Class Functions
    override func setUp() {
        super.setUp()
        view.addSubview(tableView)
        tableView.autoPinEdgesToSuperviewSafeArea()
        title = "Interface language"
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        let cancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelScreen))
        self.navigationItem.leftBarButtonItem = cancel
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    // MARK: - Custom Functions
    @objc func cancelScreen() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension LanguageVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Language.supportedLanguages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "LangCell")
        
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "LangCell")
        }
        
        cell?.textLabel?.text = Language.supportedLanguages[indexPath.row].name
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let newLanguage = Language.supportedLanguages[indexPath.row]
        if Localize.currentLanguage() != newLanguage.shortCode {
            delegate?.didSelectLanguage(newLanguage)
            didChangeLanguage.onNext(Language.supportedLanguages[indexPath.row])
            didChangeLanguage.onCompleted()
        }
        cancelScreen()
    }
}
