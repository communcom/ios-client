//
//  CommunTests.swift
//  CommunTests
//
//  Created by Chung Tran on 14/06/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import XCTest

class JSONParsingTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testChainResponseErrorJSON() {
        let string = "{\"code\":500,\"message\":\"Internal Service Error\",\"error\":{\"code\":3050003,\"name\":\"eosio_assert_message_exception\",\"what\":\"eosio_assert_message assertion failure\",\"details\":[{\"message\":\"assertion failure with message: not enough power\",\"file\":\"wasm_interface.cpp\",\"line_number\":928,\"method\":\"eosio_assert\"},{\"message\":\"pending console output: \",\"file\":\"apply_context.cpp\",\"line_number\":79,\"method\":\"exec_one\"}]}}"
        
        let object = try? JSONSerialization.jsonObject(with: string.data(using: .utf8)!, options: .allowFragments) as? [String: Any]
        
        let bcError = object?["error"] as? [String: Any]
        let details = bcError?["details"] as? [[String: Any]]
        
        let firstDetail = details?.first
        
        let messsage = firstDetail?["message"] as? String
        
        XCTAssertEqual(messsage, "assertion failure with message: not enough power")
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
