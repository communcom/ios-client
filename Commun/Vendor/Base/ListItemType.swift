//
//  ListItemType.swift
//  Commun
//
//  Created by Chung Tran on 10/23/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxDataSources

typealias ListItemType = Decodable & Equatable & IdentifiableType

extension Decodable where Self: Equatable & IdentifiableType {
    static var changedEventName: String {"DidChange"}
    static var deletedEventName: String {"Deleted"}
    static var blockedEventName: String {"Blocked"}
    
    public func notifyEvent(eventName: String) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "\(Self.self)\(event)"), object: self)
    }
    
    public func notifyChanged() {
        notifyEvent(eventName: Self.changedEventName)
    }
    
    public func notifyDeleted() {
        notifyEvent(eventName: Self.deletedEventName)
    }
}
