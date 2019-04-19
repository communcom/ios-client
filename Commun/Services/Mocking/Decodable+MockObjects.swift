//
//  MockObjects.swift
//  Commun
//
//  Created by Chung Tran on 19/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxSwift

extension Decodable {
    fileprivate static func mockData() -> Self?  {
        if let path = Bundle.main.path(forResource: String(describing: self), ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                print(String(describing: self))
                print(data)
                let result = try JSONDecoder().decode(Self.self, from: data)
                return result
            } catch {
                print(error)
                // handle error
            }
        }
        return nil
    }
    
    static func observableWithMockData() -> Observable<Self> {
        return Observable.just(mockData()!)
    }
}
