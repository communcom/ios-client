//
//  CommunPageControll.swift
//  Commun
//
//  Created by Chung Tran on 11/26/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

final class CMPageControll: MyView {
    // MARK: - Constants
    let itemHeight: CGFloat = 5
    let selectedItemWidth: CGFloat = 20
    let spaceBetweenItems: CGFloat = 6
    let unselectedColor = UIColor(hexString: "#E2E6E8")
    let selectedColor = UIColor.appMainColor
    
    // MARK: - Properties
    let numberOfPages: Int
    var selectedIndex: Int {
        didSet {
            update()
        }
    }
    
    // MARK: - Subviews
    lazy var stackView: UIStackView = {
        let stackView = UIStackView(forAutoLayout: ())
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = spaceBetweenItems
        return stackView
    }()
    
    // MARK: - Initializers
    init(numberOfPages: Int, selectedIndex: Int = 0) {
        self.numberOfPages = numberOfPages
        self.selectedIndex = selectedIndex
        super.init(frame: .zero)
        defer {
            update()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    override func commonInit() {
        super.commonInit()
        
        addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges()
        
        for _ in 0..<numberOfPages {
            let itemView = UIView(width: itemHeight, height: itemHeight, backgroundColor: unselectedColor, cornerRadius: itemHeight / 2)
            stackView.addArrangedSubview(itemView)
        }
    }
    
    func update() {
        if selectedIndex >= numberOfPages {return}
        guard let view = stackView.arrangedSubviews[safe: selectedIndex] else {return}
        let anotherViews = stackView.arrangedSubviews.filter {$0 != view}
        UIView.animate(withDuration: 0.3) {
            anotherViews.forEach { (view) in
                view.widthConstraint?.constant = self.itemHeight
                view.backgroundColor = self.unselectedColor
            }
            view.widthConstraint?.constant = self.selectedItemWidth
            view.backgroundColor = self.selectedColor
        }
    }
}
