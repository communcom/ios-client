//
//  TagListView+Extension.swift
//  Commun
//
//  Created by Chung Tran on 9/17/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import TagListView

extension TagListView {
    static func `default`(tags: [String]) -> TagListView {
        let tagListView = TagListView(forAutoLayout: ())
        tagListView.tagBackgroundColor = .appLightGrayColor
        tagListView.textFont = .systemFont(ofSize: 15, weight: .semibold)
        tagListView.textColor = .appMainColor
        tagListView.marginX = 10
        tagListView.marginY = 10
        tagListView.paddingX = 15
        tagListView.paddingY = 10
        tagListView.addTags(tags)
        tagListView.tagViews.forEach {
            $0.layer.cornerRadius = 35/2
            $0.layer.masksToBounds = true
        }
        return tagListView
    }
}
