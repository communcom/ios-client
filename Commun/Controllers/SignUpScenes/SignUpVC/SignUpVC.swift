//
//  SignUpVC.swift
//  Commun
//
//  Created by Chung Tran on 3/11/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class SignUpVC: SignUpBaseVC {
    // MARK: - Nested type
    struct Method {
        var serviceName: String
        var backgroundColor: UIColor = .clear
        var textColor: UIColor = .black
    }
    
    // MARK: - Properties
    let methods: [Method] = [
        Method(serviceName: "phone"),
        Method(serviceName: "google"),
        Method(serviceName: "instagram"),
        Method(serviceName: "twitter", backgroundColor: UIColor(hexString: "#4AA1EC")!, textColor: .white),
        Method(serviceName: "facebook", backgroundColor: UIColor(hexString: "#415A94")!, textColor: .white),
        Method(serviceName: "apple", backgroundColor: .black, textColor: .white)
    ]
    
    // MARK: - Subviews
    lazy var stackView = UIStackView(axis: .vertical, spacing: 12, alignment: .center, distribution: .fill)
    
    // MARK: - Methods
    override func setUp() {
        super.setUp()
        
        // set up stack view
        for method in methods {
            let methodView = UIView(height: 44, backgroundColor: method.backgroundColor, cornerRadius: 6)
            methodView.borderColor = .a5a7bd
            methodView.borderWidth = 1
            
            let imageView = UIImageView(width: 30, height: 30, imageNamed: "sign-up-with-\(method.serviceName)")
            methodView.addSubview(imageView)
            imageView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(inset: 7), excludingEdge: .trailing)
            
            let label = UILabel.with(text: "continue with".localized().uppercaseFirst + " " + method.serviceName.localized().uppercaseFirst, textSize: 17, weight: .medium, textColor: method.textColor, textAlignment: .center)
            methodView.addSubview(label)
            label.autoAlignAxis(toSuperviewAxis: .horizontal)
            label.autoPinEdge(.leading, to: .trailing, of: imageView, withOffset: 7)
            label.autoPinEdge(toSuperviewEdge: .trailing, withInset: 7)
            
            stackView.addArrangedSubview(methodView)
            
            methodView.autoPinEdge(toSuperviewEdge: .leading)
            methodView.autoPinEdge(toSuperviewEdge: .trailing)
        }
        
        scrollView.contentView.addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(inset: .adaptive(height: 39)), excludingEdge: .bottom)
        
        // terms of use
        scrollView.contentView.addSubview(termOfUseLabel)
        termOfUseLabel.autoPinEdge(.top, to: .bottom, of: stackView, withOffset: .adaptive(height: 30))
        termOfUseLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: .adaptive(height: 39))
        termOfUseLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: .adaptive(height: 39))
        
        // sign in label
        scrollView.contentView.addSubview(signInLabel)
        signInLabel.autoPinEdge(.top, to: .bottom, of: termOfUseLabel, withOffset: .adaptive(height: 80))
        signInLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: .adaptive(height: 39))
        signInLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: .adaptive(height: 39))
        
        // pin bottom
        signInLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: 16)
    }
}
