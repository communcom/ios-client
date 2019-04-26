//
//  LanguageVC.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 22/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit

struct Language {
    var name: String
    var code: String
}

protocol LanguageVCDelegate {
    func didSelectLanguage(_ language: Language)
}

class LanguageVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var searchController = UISearchController(searchResultsController: nil) // С поиском будут доработки
    
    var languages = [Language(name: "English (UK)", code: "UK")]
    
    var delegate: LanguageVCDelegate?
    
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
    
    @objc func cancelScreen() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
}

extension LanguageVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return languages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "LangCell")
        if (cell == nil) {
            cell = UITableViewCell(style: .default, reuseIdentifier: "LangCell")
        }
        cell?.textLabel?.text = languages[indexPath.row].name
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didSelectLanguage(languages[indexPath.row])
        cancelScreen()
    }
}
