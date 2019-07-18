//
//  LanguageVC.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 22/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
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

protocol LanguageVCDelegate {
    func didSelectLanguage(_ language: Language)
}

class LanguageVC: UIViewController {
    // MARK: - Properties
    var searchController = UISearchController(searchResultsController: nil) // С поиском будут доработки
    
    var delegate: LanguageVCDelegate?
    var didSelectLanguage = PublishSubject<Language>()
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!

    
    // MARK: - Class Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Interface language"
        
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
        
        if (cell == nil) {
            cell = UITableViewCell(style: .default, reuseIdentifier: "LangCell")
        }
        
        cell?.textLabel?.text = Language.supportedLanguages[indexPath.row].name
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didSelectLanguage(Language.supportedLanguages[indexPath.row])
        didSelectLanguage.onNext(Language.supportedLanguages[indexPath.row])
        didSelectLanguage.onCompleted()
        cancelScreen()
    }
}
