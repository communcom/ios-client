//
//  CMHorizontalTabBar.swift
//  Commun
//
//  Created by Chung Tran on 8/11/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class CMHorizontalTabBar: MyView {
    // MARK: - Properties
    var tabBarHeight: CGFloat {
        didSet { autoSetDimension(.height, toSize: tabBarHeight)}
    }
    
    var contentInset: UIEdgeInsets = .zero {
        didSet { scrollView.contentInset = contentInset }
    }
    
    var spacing: CGFloat = 10 {
        didSet { stackView.spacing = spacing }
    }
    
    var labels: [String] = [] {
        didSet { setUpButtons() }
    }
    
    private var buttons: [CommunButton] {
        stackView.arrangedSubviews.compactMap {$0 as? CommunButton}
    }
    
    var selectedIndexes: [Int] = [Int]() {
        didSet { updateSelectedIndexes() }
    }
    
    var isMultipleSelectionEnabled: Bool
    var canChooseNone: Bool = false
    
    // MARK: - handler
    var selectedIndexesDidChange: (([Int]) -> Void)?
    
    // MARK: - Computed properties
    /// for single selection
    var selectedIndex: Int? {
        get { selectedIndexes.first }
        set { selectedIndexes = newValue == nil ? [] : [newValue!]}
    }
    
    // MARK: - Subviews
    private lazy var scrollView: ContentHuggingScrollView = {
        let scrollView = ContentHuggingScrollView(scrollableAxis: .horizontal, contentInset: contentInset)
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    private lazy var stackView = UIStackView(axis: .horizontal, spacing: spacing, alignment: .fill, distribution: .fill)
    
    // MARK: - Initializers
    init(height: CGFloat, isMultipleSelectionEnabled: Bool = false) {
        self.tabBarHeight = height
        self.isMultipleSelectionEnabled = isMultipleSelectionEnabled
        super.init(frame: .zero)
        configureForAutoLayout()
        autoSetDimension(.height, toSize: height)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    override func commonInit() {
        super.commonInit()
        addSubview(scrollView)
        scrollView.autoPinEdgesToSuperviewEdges()
        
        scrollView.contentView.addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges()
    }
    
    private func setUpButtons() {
        // clean
        stackView.removeArrangedSubviews()
        
        // create buttons
        let buttons = labels.map {CommunButton.default(height: tabBarHeight, label: $0)}
        for (index, button) in buttons.enumerated() {
            button.tag = index
            button.addTarget(self, action: #selector(selectionDidChange(_:)), for: .touchUpInside)
            
            button.backgroundColor = .appLightGrayColor
            button.setTitleColor(.appBlackColor, for: .normal)
        }
        
        // add buttons
        stackView.addArrangedSubviews(buttons)
    }
    
    private func updateSelectedIndexes() {
        UIView.animate(withDuration: 0.3) {
            for i in 0..<self.buttons.count {
                self.buttons[i].backgroundColor = self.selectedIndexes.contains(i) ? .appMainColor : .appLightGrayColor
                self.buttons[i].setTitleColor(self.selectedIndexes.contains(i) ? .white : .appBlackColor, for: .normal)
            }
        }
        
    }
    
    @objc private func selectionDidChange(_ button: CommunButton) {
        let index = button.tag
        
        // remove selection
        if selectedIndexes.contains(index) {
            if isMultipleSelectionEnabled || selectedIndexes.count > 1 || canChooseNone {
                selectedIndexes = selectedIndexes.removeAll(index)
            }
            return
        }
        
        // add selection
        var selectedIndexes = self.selectedIndexes
        
        // if user can choose only 1 option
        if !isMultipleSelectionEnabled {
            selectedIndexes.removeAll()
        }
        
        // modify array
        selectedIndexes.append(index)
        self.selectedIndexes = selectedIndexes
    }
}
