//
//  CMTopTabBar.swift
//  Commun
//
//  Created by Chung Tran on 11/6/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class CMTopTabBar: MyView {
    // MARK: - Properties
    var tabBarHeight: CGFloat
    var spacing: CGFloat
    let bag = DisposeBag()
    var labels: [String] {
        didSet {
            didSetLabels()
        }
    }
    var buttons: [CommunButton]!
    var selectedIndex: BehaviorRelay<Int>
    
    // MARK: - Subviews
    lazy var scrollView = ContentHuggingScrollView(axis: .vertical, contentInset: .zero)
    
    // MARK: - Init
    init(height: CGFloat, labels: [String], selectedIndex: Int = 0, spacing: CGFloat = 5) {
        self.labels = labels
        self.selectedIndex = BehaviorRelay<Int>(value: selectedIndex)
        self.tabBarHeight = height
        self.spacing = spacing
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func commonInit() {
        super.commonInit()
        configureForAutoLayout()
        autoSetDimension(.height, toSize: tabBarHeight)
        
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        
        addSubview(scrollView)
        scrollView.autoPinEdgesToSuperviewEdges()
        didSetLabels()
        setUp()
        bind()
    }
    
    func bind() {
        selectedIndex
            .subscribe(onNext: {[weak self] _ in self?.setUp()})
            .disposed(by: bag)
    }
    
    func didSetLabels() {
        if buttons != nil {
            buttons.forEach {$0.removeFromSuperview()}
        }
        buttons = [CommunButton]()
        
        for i in 0..<labels.count {
            let button = CommunButton.default(height: tabBarHeight, label: labels[i])
            button.tag = i
            button.addTarget(self, action: #selector(changeSelection(_:)), for: .touchUpInside)
            
            scrollView.contentView.addSubview(button)
            button.autoPinEdge(toSuperviewEdge: .top)
            button.autoPinEdge(toSuperviewEdge: .bottom)
            
            if i == 0 {
                scrollView.contentView.heightAnchor.constraint(equalTo: button.heightAnchor)
                    .isActive = true
                button.autoPinEdge(toSuperviewEdge: .leading)
            } else {
                button.autoPinEdge(.leading, to: .trailing, of: buttons[i-1], withOffset: spacing)
            }
            
            if i == buttons.count - 1 {
                button.autoPinEdge(toSuperviewEdge: .trailing)
            }
            
            buttons.append(button)
        }
    }
    
    func setUp() {
        if selectedIndex.value >= labels.count {return}
        
        for i in 0..<buttons.count {
            buttons[i].backgroundColor = (selectedIndex.value == i) ? .appMainColor : .f3f5fa
            buttons[i].setTitleColor((selectedIndex.value == i) ? .white: .black, for: .normal)
        }
        
        UIView.animate(withDuration: 0.2) {
            self.layoutIfNeeded()
        }
    }
    
    @objc private func changeSelection(_ sender: UIButton) {
        changeSelectedIndex(sender.tag)
    }
    
    func changeSelectedIndex(_ index: Int) {
        if index == selectedIndex.value {return}
        selectedIndex.accept(index)
    }
}
