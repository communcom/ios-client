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

class CMTopicCell: MyTableViewCell, UITextFieldDelegate {
    lazy var clearButton = UIButton.clearButton.huggingContent(axis: .horizontal)
    lazy var textField = UITextField.noBorder()
    var editingAction: Action<String, Void>?
    let disposeBag = DisposeBag()

    lazy var view = UIView(backgroundColor: .appWhiteColor, cornerRadius: 10)
    lazy var cancelButton = UIButton(height: 35, label: "cancel".localized().uppercaseFirst, labelFont: .boldSystemFont(ofSize: 15.0), backgroundColor: .appLightGrayColor, textColor: .appGrayColor, cornerRadius: 35 / 2, contentInsets: UIEdgeInsets(top: 10.0, left: 15.0, bottom: 10.0, right: 15.0))
    lazy var doneButton = CommunButton.default(height: 35, label: "done".localized().uppercaseFirst, cornerRadius: 35/2, isHuggingContent: true)
        .onTap(self, action: #selector(doneButtonDidTouch))
    
    lazy var toolbar: CMBottomToolbar = {
        let toolbar = CMBottomToolbar(height: 55, cornerRadius: 16, contentInset: UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16))
        toolbar.stackView.distribution = .equalSpacing
        toolbar.stackView.alignment = .fill
        toolbar.stackView.addArrangedSubviews([cancelButton, doneButton])
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
        textField.rx.controlEvent([.editingDidBegin])
            .asObservable()
            .subscribe(onNext: {[weak self] (_) in
                self?.view.borderColor = .appMainColor
            })
            .disposed(by: disposeBag)
        
        textField.rx.controlEvent([.editingDidEnd])
            .asObservable()
            .subscribe(onNext: {[weak self] _ in
                self?.view.borderColor = .appLightGrayColor
                self?.commitChange()
            })
            .disposed(by: disposeBag)
        
        textField.rx.text.orEmpty
            .map {!$0.isEmpty}
            .asDriver(onErrorJustReturn: false)
            .distinctUntilChanged()
            .drive(doneButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        textField.delegate = self
    }
    
    func setUp(topic: String, clearAction: CocoaAction, editingAction: Action<String, Void>, cancelAction: CocoaAction, placeholder: String = "Ex: Game") {
        textField.text = topic
        textField.placeholder = placeholder
        clearButton.rx.action = clearAction
        cancelButton.rx.action = cancelAction
        self.editingAction = editingAction
    }
    
    @objc func commitChange() {
        guard let newText = textField.text?.removingTrailingSpaces() else {return}
        editingAction?.execute(newText)
        textField.placeholder = "Ex: Game"
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
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let newText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) else {
            return false
        }
        var trimmedNewText = newText.removingLeadingSpaces()
        while trimmedNewText.contains("  ") {
            trimmedNewText = trimmedNewText.replacingOccurrences(of: "  ", with: " ")
        }
        
        // Get invalid characters
        var validChars = NSCharacterSet.alphanumerics
        validChars.insert(charactersIn: " ")
        let invalidChars = validChars.inverted

        // Make new string with invalid characters trimmed
        let newString = trimmedNewText.trimmingCharacters(in: invalidChars)

        if newString.count < trimmedNewText.count {
            textField.changeTextNotify(newString)
            return false
        }
        
        if trimmedNewText != newText {
            textField.changeTextNotify(trimmedNewText)
            return false
        }
        return true
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
            placeholder: indexPath.row == 0 ? "your first topic here".localized().uppercaseFirst : "Ex: Game"
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
