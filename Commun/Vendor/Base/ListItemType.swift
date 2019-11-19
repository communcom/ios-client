//
//  ListItemType.swift
//  Commun
//
//  Created by Chung Tran on 10/23/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxDataSources
import RxSwift

typealias ListItemType = Decodable & Equatable & IdentifiableType

extension Decodable where Self: Equatable & IdentifiableType {
    static var changedEventName: String {"DidChange"}
    static var deletedEventName: String {"Deleted"}
    static var blockedEventName: String {"Blocked"}
    
    public func notifyEvent(eventName: String, object: Any? = nil) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "\(Self.self)\(eventName)"), object: object ?? self)
    }
    
    public func notifyChanged() {
        notifyEvent(eventName: Self.changedEventName)
    }
    
    public func notifyDeleted() {
        notifyEvent(eventName: Self.deletedEventName)
    }
    
    public static func observeEvent(eventName: String) -> Observable<Self> {
        NotificationCenter.default.rx.notification(.init(rawValue: "\(Self.self)\(eventName)"))
            .filter { notification in
                guard (notification.object as? Self) != nil
                    else {return false}
                return true
            }
            .map {$0.object as! Self}
    }
    
    public static func observeItemChanged() -> Observable<Self> {
        observeEvent(eventName: changedEventName)
    }
    
    public static func observeItemDeleted() -> Observable<Self> {
        observeEvent(eventName: deletedEventName)
    }
}
