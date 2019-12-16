//
//  Array.swift
//  Commun
//
//  Created by Chung Tran on 10/1/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
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

extension RangeReplaceableCollection where Element == ResponseAPIContentGetComment {
    var sortedByTimeDesc: [ResponseAPIContentGetComment] {
        sorted { (comment1, comment2) -> Bool in
            let date1 = Date.from(string: comment1.meta.creationTime)
            let date2 = Date.from(string: comment2.meta.creationTime)
            return date1.compare(date2) == .orderedAscending
        }
    }
}
