//
//  CreateCommunitySencondStepVC.swift
//  Commun
//
//  Created by Chung Tran on 9/26/20.
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
    
    override func setUpViews() {
        super.setUpViews()
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
        
        bind()
    }
    
    func bind() {
        textField.rx.controlEvent([.editingDidEnd])
            .asObservable()
            .subscribe(onNext: {[weak self] _ in
                guard let newText = self?.textField.text else {return}
                self?.editingAction?.execute(newText)
            })
            .disposed(by: disposeBag)
    }
    
    func setUp(topic: String, clearAction: CocoaAction, editingAction: Action<String, Void>) {
        textField.text = topic
        clearButton.rx.action = clearAction
        self.editingAction = editingAction
    }
}

class CMTopicsVC: CMTableViewController<String, CMTopicCell> {
    let newTopicCellHeight: CGFloat = 60.5 + 16
    var showNewTopicCell: Bool = false { didSet { updateFooterView() } }
    
    lazy var newTopicCell = CMTopicCell(height: newTopicCellHeight)
        .configureToUseAsNormalView()
    
    override func setUp() {
        super.setUp()
        setUpFooterView()
    }
    
    override func configureCell(item: String, indexPath: IndexPath) -> UITableViewCell {
        let cell = super.configureCell(item: item, indexPath: indexPath) as! CMTopicCell
        cell.setUp(
            topic: item,
            clearAction: CocoaAction {
                var items = self.itemsRelay.value
                items.removeAll(item)
                self.itemsRelay.accept(items)
                return .just(())
            },
            editingAction: Action<String, Void> { input in
                if input == item {return .just(())}
                
                var items = self.itemsRelay.value
                if let index = items.firstIndex(where: {$0 == item}) {
                    items[index] = input
                    self.itemsRelay.accept(items)
                }
                return .just(())
            }
        )
        return cell
    }
    
    @objc func addTopicButtonDidTouch() {
        showNewTopicCell.toggle()
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
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: newTopicCellHeight+55))
        
        let stackView = UIStackView(axis: .vertical, spacing: 0, alignment: .fill, distribution: .fill)
        view.addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges()
        
        stackView.addArrangedSubviews([newTopicCell, addNewTopicButton])
        tableView.tableFooterView = view
    }
    
    private func updateFooterView(animated: Bool = true) {
        let showNewTopicCell = self.showNewTopicCell || itemsRelay.value.count == 0
        var frame = tableView.tableFooterView!.frame
        var height: CGFloat = 55
        if showNewTopicCell {
            height += newTopicCellHeight
        }
        if height != frame.size.height {
            UIView.animate(withDuration: animated ? 0.3 : 0) {
                frame.size.height = height
                let view = self.tableView.tableFooterView!
                view.frame = frame
                self.tableView.tableFooterView = view
                self.newTopicCell.isHidden = !showNewTopicCell
            }
        }
    }
}

class CreateTopicsVC: CMTopicsVC, CreateCommunityVCType {
    let isDataValid = BehaviorRelay<Bool>(value: false)
    
    override var contentInsets: UIEdgeInsets {UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)}
    
    override func setUp() {
        super.setUp()
        setUpHeaderView()
    }
    
    override func bind() {
        super.bind()
        
    }
    
    private func setUpHeaderView() {
        let headerView = MyTableHeaderView(tableView: tableView)
        let stackView = UIStackView(axis: .vertical, spacing: 30, alignment: .center, distribution: .fill)
        headerView.addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 0, bottom: 30, right: 0))
        
        let label = UILabel.with(text: "topics are needed for recomendation service. In that way, for users, interested in your community will by much easier to find itin a list.".localized().uppercaseFirst, textSize: 15, numberOfLines: 0, textAlignment: .center)
        stackView.addArrangedSubviews([
            UIImageView(width: 120, height: 120, cornerRadius: 60, imageNamed: "topic-explaination"),
            label
        ])
        label.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
    }
}
