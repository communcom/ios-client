//
//  Array.swift
//  Commun
//
//  Created by Chung Tran on 10/1/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxDataSources

extension RangeReplaceableCollection where Element: Equatable {
    @discardableResult
    mutating func appendIfNotContains(_ element: Element) -> (appended: Bool, memberAfterAppend: Element) {
        if let index = firstIndex(of: element) {
            return (false, self[index])
        } else {
            append(element)
            return (true, element)
        }
    }
}

extension RangeReplaceableCollection where Element: IdentifiableType {
    mutating func joinUnique(_ newElements: [Element]) {
        let newElements = newElements.filter {item in
            !self.contains(where: {$0.identity == item.identity})
        }
        self.append(contentsOf: newElements)
    }
    
    func filterOut(_ elements: [Element]) -> Self {
        let newElements = self.filter {item in
            !elements.contains(where: {$0.identity == item.identity})
        }
        return newElements
    }
}
