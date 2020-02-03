//
//  SearchListFetcher.swift
//  Commun
//
//  Created by Chung Tran on 2/3/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift
import CyberSwift

class SearchListFetcher: ListFetcher<ResponseAPIContentSearchItem> {
    // MARK: - Nested types
    enum SearchType {
        case quickSearch
        case extendedSearch
        case entitySearch
    }
    
    // MARK: - Properties
    override var isPaginationEnabled: Bool {false}
    
    var searchType = SearchType.quickSearch
    lazy var total: UInt = 0
    lazy var entities = [SearchEntityType]()
    lazy var extendedSearchEntity = [SearchEntityType: [String: UInt]]()
    lazy var entitySearchEntity = SearchEntityType.communities
    
    override var request: Single<[ResponseAPIContentSearchItem]> {
        switch searchType {
        case .quickSearch:
            return RestAPIManager.instance.quickSearch(queryString: search ?? "", entities: entities, limit: limit)
                .do(onSuccess: { (result) in
                    self.total = result.total
                })
                .map {$0.items}
        case .extendedSearch:
            return RestAPIManager.instance.extendedSearch(queryString: search ?? "", entities: extendedSearchEntity)
                .do(onSuccess: {result in
                    self.total = (result.communities?.total ?? 0) + (result.profiles?.total ?? 0) + (result.posts?.total ?? 0)
                })
                .map { result in
                    (result.communities?.items ?? []) + (result.profiles?.items ?? []) + (result.posts?.items ?? [])
                }
        case .entitySearch:
            return  RestAPIManager.instance.entitySearch(queryString: search ?? "", entity: entitySearchEntity, limit: limit, offset: offset)
                .do(onSuccess: { (result) in
                    self.total = result.total
                })
                .map {$0.items}
        }
    }
    
    override func join(newItems items: [ResponseAPIContentSearchItem]) -> [ResponseAPIContentSearchItem] {
        items
    }
}
