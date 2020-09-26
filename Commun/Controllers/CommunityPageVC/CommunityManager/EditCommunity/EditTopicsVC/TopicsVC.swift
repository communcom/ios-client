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
    
    lazy var saveButton = UIBarButtonItem(title: "save".localized().uppercaseFirst, style: .done, target: self, action: #selector(saveButtonDidTouch))
    
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
        
        setLeftBarButton(imageName: "icon-back-bar-button-black-default", tintColor: .appBlackColor, action: #selector(askForSavingAndGoBack))
        
        saveButton.tintColor = .appBlackColor
        navigationItem.rightBarButtonItem = saveButton
        
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
        
        itemsRelay.map {_ in self.dataHasChanged()}
            .asDriver(onErrorJustReturn: false)
            .drive(saveButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
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
                
                self.openEditor(originalTopic: item) { (newItem) in
                    items[indexPath.row] = newItem
                    self.itemsRelay.accept(items)
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func dataHasChanged() -> Bool {
        itemsRelay.value != originalItems
    }
    
    override func configureCell(item: String, indexPath: IndexPath) -> UITableViewCell {
        let cell = super.configureCell(item: item, indexPath: indexPath) as! TopicCell
        cell.label.text = item
        return cell
    }
    
    @objc func addTopicButtonDidTouch() {
        openEditor { (newTopic) in
            var items = self.itemsRelay.value
            items.append(newTopic)
            self.itemsRelay.accept(items)
        }
    }
    
    private func openEditor(originalTopic: String? = nil, completion: @escaping ((String) -> Void)) {
        //1. Create the alert controller.
        let alert = UIAlertController(title: "edit topic".localized().uppercaseFirst, message: "enter topic name".localized().uppercaseFirst, preferredStyle: .alert)

        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.text = originalTopic
        }

        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            guard let text = alert?.textFields?[0].text?.trimmed, !text.isEmpty else {return}
            completion(text)
        }))

        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func saveButtonDidTouch() {
        self.showIndetermineHudWithMessage("creating proposal".localized().uppercaseFirst)
        BlockchainManager.instance.editCommunnity(
            communityCode: self.communityCode,
            commnityIssuer: self.communityIssuer,
            subject: itemsRelay.value.convertToJSON()
        )
            .flatMapCompletable {RestAPIManager.instance.waitForTransactionWith(id: $0)}
            .subscribe(onCompleted: {
                self.hideHud()
                self.showAlert(title: "proposal created".localized().uppercaseFirst, message: "proposal for topics changing has been created".localized().uppercaseFirst) { (_) in
                    self.back()
                }
            }) { (error) in
                self.hideHud()
                self.showError(error)
            }
            .disposed(by: self.disposeBag)
    }
    
    @objc func askForSavingAndGoBack() {
        if dataHasChanged() {
            showAlert(title: "save".localized().uppercaseFirst, message: "do you want to save the changes you've made?".localized().uppercaseFirst, buttonTitles: ["yes".localized().uppercaseFirst, "no".localized().uppercaseFirst], highlightedButtonIndex: 0) { (index) in
                if index == 0 {
                    self.saveButtonDidTouch()
                    return
                }
                self.back()
            }
        } else {
            back()
        }
    }
    
//    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
//        .none
//    }
//
//    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
//        false
//    }
}
