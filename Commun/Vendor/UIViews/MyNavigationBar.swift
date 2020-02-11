////
////  MyNavigationBar.swift
////  Commun
////
////  Created by Chung Tran on 10/28/19.
////  Copyright © 2019 Commun Limited. All rights reserved.
////
//
//import Foundation
//
//class MyNavigationBar: MyView {
//    // MARK: - Properties
//    var leftButton: UIButton?
//    var rightButton: UIButton?
//    var titleLabel: UILabel = UILabel.with(textSize: CGFloat.adaptive(width: 15.0), weight: .semibold)
//    
//    
//    // MARK: - Class Initialization
//    init(title: String = "", leftButton: UIButton? = nil, rightButton: UIButton? = nil) {
//        super.init(frame: .zero)
//        
//        self.titleLabel.text = title
//        self.leftButton = leftButton
//        self.rightButton = rightButton
//        
//        commonInit()
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    
//    // MARK: - Custom Functions
//    override func commonInit() {
//        super.commonInit()
//        
//        // Title label
//        addSubview(titleLabel)
//        titleLabel.textAlignment = .center
//        titleLabel.autoAlignAxis(toSuperviewAxis: .horizontal)
//        titleLabel.autoAlignAxis(toSuperviewAxis: .vertical)
//        titleLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: CGFloat.adaptive(height: 60.0))
//        titleLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: CGFloat.adaptive(height: 60.0))
//
//        // Left button
//        if let leftButtonValue = self.leftButton {
//            addSubview(leftButtonValue)
//            leftButtonValue.autoPinEdge(toSuperviewEdge: .leading, withInset: CGFloat.adaptive(width: 15.0))
//            leftButtonValue.autoAlignAxis(toSuperviewAxis: .horizontal)
//            
//            leftButtonValue.addTarget(self, action: #selector(leftButtonTapped), for: .touchUpInside)
//        }
//        
//        // Right button
//        if let rightButtonValue = self.rightButton {
//            addSubview(rightButtonValue)
//            rightButtonValue.autoPinEdge(toSuperviewEdge: .trailing, withInset: CGFloat.adaptive(width: 15.0))
//            rightButtonValue.autoAlignAxis(toSuperviewAxis: .horizontal)
//            
//            rightButtonValue.addTarget(self, action: #selector(rightButtonTapped), for: .touchUpInside)
//        }
//    }
//    
//    
//    // MARK: - Actions
//    @objc func leftButtonTapped() {
//        parentViewController?.navigationController?.popViewController()
//    }
//
//    @objc func rightButtonTapped() {
//        parentViewController?.dismiss(animated: true, completion: nil)
//    }
//}
