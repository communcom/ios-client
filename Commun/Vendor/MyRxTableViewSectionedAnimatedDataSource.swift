//
//  MyRxTableViewSectionedAnimatedDataSource.swift
//  Commun
//
//  Created by Chung Tran on 03/06/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxSwift
import RxDataSources

final class MyRxTableViewSectionedAnimatedDataSource<S: AnimatableSectionModelType>: RxTableViewSectionedAnimatedDataSource<S> {
    
    private var currentItemsCount = 0
    
    var isEmpty: Bool {
        return currentItemsCount == 0
    }
    
    override func tableView(_ tableView: UITableView, observedEvent: Event<[S]>) {
        super.tableView(tableView, observedEvent: observedEvent)
        switch observedEvent {
        case let .next(events):
            guard let lastEvent = events.last else { return }
            currentItemsCount = lastEvent.items.count
        default: break
        }
    }
}
