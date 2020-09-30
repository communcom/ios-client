//
//  CMTopicsVC.swift
//  Commun
//
//  Created by Chung Tran on 9/28/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxCocoa
import Action
import RxSwift

class CMTopicCell: MyTableViewCell {
    lazy var clearButton = UIButton.clearButton.huggingContent(axis: .horizontal)
    lazy var textField = UITextField.noBorder()
    var editingAction: Action<String, Void>?
    let disposeBag = DisposeBag()
    
    lazy var cancelButton = UIButton(height: 35, label: "cancel".localized().uppercaseFirst, labelFont: .boldSystemFont(ofSize: 15.0), backgroundColor: .appLightGrayColor, textColor: .appGrayColor, cornerRadius: 35 / 2, contentInsets: UIEdgeInsets(top: 10.0, left: 15.0, bottom: 10.0, right: 15.0))
    lazy var doneButton = CommunButton.default(height: 35, label: "done".localized().uppercaseFirst, cornerRadius: 35/2, isHuggingContent: true)
        .onTap(self, action: #selector(doneButtonDidTouch))
    
    lazy var toolbar: CMBottomToolBar = {
        let mainView: UIView = {
            let view = UIView(height: 55, backgroundColor: .appWhiteColor)
            let stackView = UIStackView(axis: .horizontal, spacing: 10, alignment: .fill, distribution: .equalSpacing)
            view.addSubview(stackView)
            stackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16))
            stackView.addArrangedSubviews([cancelButton, doneButton])
            return view
        }()
        let toolbar = CMBottomToolBar(mainView: mainView, cornerRadius: 16)
        return toolbar
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        toolbar.layoutIfNeeded()
    }
    
    override func setUpViews() {
        super.setUpViews()
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        let view = UIView(backgroundColor: .appWhiteColor, cornerRadius: 10)
        view.borderColor = .appLightGrayColor
        view.borderWidth = 1
        contentView.addSubview(view)
        view.autoPinEdgesToSuperviewEdges(with: .only(.bottom, inset: 16))
        
        let hStackView = UIStackView(axis: .horizontal, spacing: 10, alignment: .center, distribution: .fill)
        view.addSubview(hStackView)
        hStackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16))
        
        let vStackView: UIStackView = {
            let stackView = UIStackView(axis: .vertical, spacing: 5, alignment: .fill, distribution: .fill)
            stackView.addArrangedSubview(UILabel.with(text: "topic name".localized().uppercaseFirst, textSize: 13, weight: .medium, textColor: .appGrayColor))
            stackView.addArrangedSubview(textField)
            return stackView
        }()
        
        hStackView.addArrangedSubviews([vStackView, clearButton])
        
        // toolbar
        textField.inputAccessoryView = toolbar
        
        bind()
    }
    
    func bind() {
        textField.rx.controlEvent([.editingDidEnd])
            .asObservable()
            .subscribe(onNext: {[weak self] _ in
                self?.commitChange()
            })
            .disposed(by: disposeBag)
        
        textField.rx.text.orEmpty
            .map {!$0.isEmpty}
            .asDriver(onErrorJustReturn: false)
            .drive(doneButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }
    
    func setUp(topic: String, clearAction: CocoaAction, editingAction: Action<String, Void>, cancelAction: CocoaAction, placeholder: String = "Ex: Game") {
        textField.text = topic
        textField.placeholder = placeholder
        clearButton.rx.action = clearAction
        cancelButton.rx.action = cancelAction
        self.editingAction = editingAction
    }
    
    @objc func commitChange() {
        guard let newText = textField.text else {return}
        editingAction?.execute(newText)
    }
    
    @objc func doneButtonDidTouch() {
        commitChange()
        guard let tableView = (parentViewController as? CMTopicsVC)?.tableView else {return}
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let lastRow = tableView.numberOfRows(inSection: 0) - 1
            let indexPath = IndexPath(row: lastRow, section: 0)
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
}

class CMTopicsVC: CMTableViewController<String, CMTopicCell> {
    
    override func setUp() {
        super.setUp()
        setUpFooterView()
    }
    
    override func mapItemsToSections(_ items: [String]) -> [SectionModel] {
        let items = items + [""]
        return super.mapItemsToSections(items)
    }
    
    override func configureCell(item: String, indexPath: IndexPath) -> UITableViewCell {
        let cell = super.configureCell(item: item, indexPath: indexPath) as! CMTopicCell
        cell.setUp(
            topic: item,
            clearAction: CocoaAction {
                if cell.textField.isFirstResponder {
                    cell.textField.changeTextNotify(nil)
                    return .just(())
                }
                self.remove(item)
                return .just(())
            },
            editingAction: Action<String, Void> { input in
                // remove
                guard !input.isEmpty else {
                    self.remove(item)
                    return .just(())
                }
                
                // adding
                if item == "" {
                    self.add(input)
                    return .just(())
                }
                
                // editing
                self.update(item, with: input)
                return .just(())
            },
            cancelAction: CocoaAction {
                cell.textField.text = item
                cell.textField.resignFirstResponder()
                return .just(())
            },
            placeholder: itemsRelay.value.count == 0 ? "your first topic here".localized().uppercaseFirst : "Ex: Game"
        )
        return cell
    }
    
    @objc func addTopicButtonDidTouch() {
        guard let cell = tableView.cellForRow(at: IndexPath(row: itemsRelay.value.count, section: 0)) as? CMTopicCell else {return}
        cell.textField.changeTextNotify(nil)
        cell.textField.becomeFirstResponder()
    }
    
    private func clearNewTopic() {
        guard let cell = tableView.cellForRow(at: IndexPath(row: itemsRelay.value.count, section: 0)) as? CMTopicCell else {return}
        cell.textField.changeTextNotify(nil)
    }
    
    // MARK: - View modifiers
    private func setUpFooterView() {
        // footerView
        let addNewTopicButton: UIView = {
            let view = UIView(height: 55, backgroundColor: .appWhiteColor, cornerRadius: 10)
            let label = UILabel.with(text: "+ " + "add new topic".localized().uppercaseFirst, textSize: 17, weight: .medium, textColor: .appMainColor)
            view.addSubview(label)
            label.autoCenterInSuperview()
            return view
                .onTap(self, action: #selector(addTopicButtonDidTouch))
        }()
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 55))
        view.addSubview(addNewTopicButton)
        addNewTopicButton.autoPinEdgesToSuperviewEdges()
        tableView.tableFooterView = view
    }
    
    // MARK: - View models
    override func add(_ item: String) {
        clearNewTopic()
        super.add(item)
    }
}
