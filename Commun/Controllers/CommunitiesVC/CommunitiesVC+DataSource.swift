//
//  CommunitiesVC+DataSource.swift
//  Commun
//
//  Created by Chung Tran on 8/2/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxDataSources

extension CommunitiesVC {
    typealias Section = AnimatableSectionModel<String, MockupCommunity>
    
    var dataSource: RxTableViewSectionedAnimatedDataSource<Section> {
        return RxTableViewSectionedAnimatedDataSource<Section>(
            configureCell: { dataSource, tableView, indexPath, community -> CommunityCell in
                let cell = tableView.dequeueReusableCell(withIdentifier: "CommunityCell", for: indexPath) as! CommunityCell
                cell.setUp(community: community)
                return cell
            }
        )
    }
}
