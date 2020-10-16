//
//  CMLanguageView.swift
//  Commun
//
//  Created by Chung Tran on 9/16/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class CMLanguageView: MyView {
    lazy var flagImageView = UIImageView(width: 30, height: 30, cornerRadius: 15)
    lazy var languageName = UILabel.with(textSize: 15)
    
    override func commonInit() {
        super.commonInit()
        let stackView = UIStackView(axis: .horizontal, spacing: 16, alignment: .center, distribution: .fill)
        addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges()
        stackView.addArrangedSubviews([flagImageView, languageName])
    }
    
    func setUp(with language: Language) {
        flagImageView.image = UIImage.init(named: "flag.\(language.code)")
        languageName.text = (language.name + " language").localized().uppercaseFirst
    }
    
    func setUp(code: String?) {
        if let language = Language.supported.first(where: {$0.code == code}) {
            setUp(with: language)
            return
        }
        flagImageView.image = UIImage.init(named: "flag.\(code ?? "")")
        languageName.text = code
    }
}
