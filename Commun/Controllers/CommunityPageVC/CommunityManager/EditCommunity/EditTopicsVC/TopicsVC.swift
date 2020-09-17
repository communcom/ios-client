//
//  TopicsVC.swift
//  Commun
//
//  Created by Chung Tran on 9/17/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxDataSources

extension String: ListItemType {
    public func newUpdatedItem(from item: String) -> String? {item}
}

class TopicsVC: CMTableViewController<String, TopicCell>, UITableViewDelegate {
    // MARK: - Properties
    let communityCode: String
    let communityIssuer: String
    
    // MARK: - Initializers
    init(communityCode: String, communityIssuer: String, topics: [String]) {
        self.communityCode = communityCode
        self.communityIssuer = communityIssuer
        var topics = topics
        topics.removeDuplicates()
        super.init(originalItems: topics)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    override func setUp() {
        super.setUp()
        title = "topics".localized().uppercaseFirst
        
        // footerView
        let footerView: UIView = {
            let view = UIView(height: 57, backgroundColor: .appWhiteColor, cornerRadius: 10)
            let label = UILabel.with(text: "+ " + "add new topic".localized().uppercaseFirst, textSize: 17, weight: .medium, textColor: .appMainColor)
            view.addSubview(label)
            label.autoCenterInSuperview()
            
            view.isUserInteractionEnabled = true
            view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addTopicButtonDidTouch)))
            return view
        }()
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 67))
        view.addSubview(footerView)
        footerView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 10, bottom: 10, right: 10))
        tableView.tableFooterView = view
        
        dataSource.canEditRowAtIndexPath = {_, _ in
            true
        }
        
        dataSource.canMoveRowAtIndexPath = {_, _ in
            true
        }
        
        tableView.setEditing(true, animated: true)
        tableView.allowsSelectionDuringEditing = true
        
    }
    
    override func bind() {
        super.bind()
//        tableView.rx.setDelegate(self)
//            .disposed(by: disposeBag)
        
        tableView.rx.itemDeleted
            .subscribe(onNext: { (indexPath) in
                var items = self.itemsRelay.value
                items.remove(at: indexPath.row)
                self.itemsRelay.accept(items)
            })
            .disposed(by: disposeBag)
        
        tableView.rx.itemMoved
            .subscribe(onNext: { event in
                var items = self.itemsRelay.value
                let item = items[event.sourceIndex.row]
                items.remove(at: event.sourceIndex.row)
                items.insert(item, at: event.destinationIndex.row)
                self.itemsRelay.accept(items)
            })
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .subscribe(onNext: { (indexPath) in
                var items = self.itemsRelay.value
                guard let item = items[safe: indexPath.row]
                    else {
                        return
                }
                
                //1. Create the alert controller.
                let alert = UIAlertController(title: "edit topic".localized().uppercaseFirst, message: "enter topic name".localized().uppercaseFirst, preferredStyle: .alert)

                //2. Add the text field. You can configure it however you need.
                alert.addTextField { (textField) in
                    textField.text = item
                }

                // 3. Grab the value from the text field, and print it when the user clicks OK.
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                    guard let text = alert?.textFields?[0].text else {return} // Force unwrapping because we know it exists.
                    items[indexPath.row] = text
                    self.itemsRelay.accept(items)
                }))

                // 4. Present the alert.
                self.present(alert, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
    }
    
    override func configureCell(item: String, indexPath: IndexPath) -> UITableViewCell {
        let cell = super.configureCell(item: item, indexPath: indexPath) as! TopicCell
        cell.label.text = item
        return cell
    }
    
    @objc func addTopicButtonDidTouch() {
        
    }
    
//    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
//        .none
//    }
//
//    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
//        false
//    }
}
