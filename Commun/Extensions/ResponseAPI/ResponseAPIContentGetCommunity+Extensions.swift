//
//  ResponseAPIContentGetCommunity+Extensions.swift
//  Commun
//
//  Created by Chung Tran on 4/2/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

extension ResponseAPIContentGetCommunity {
    public static var myFeed: ResponseAPIContentGetCommunity {
        let path = Bundle.main.path(forResource: "MyFeedCommunity", ofType: "json")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
        return try! JSONDecoder().decode(ResponseAPIContentGetCommunity.self, from: data)
    }
}
