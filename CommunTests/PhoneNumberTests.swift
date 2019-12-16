//
//  PhoneNumberTests.swift
//  CommunTests
//
//  Created by Chung Tran on 05/07/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import XCTest

class PhoneNumberTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testSubstringFunction() {
        let source = "96061"
        let result = source.fillWithDash(start: 3, offsetBy: 3)
        XCTAssertEqual(result, "61_")
    }

    func testPhoneNumber() {
        let source = ""
        
        var result: String
        
        result = String(format: "+7 (%@) %@-%@-%@",
                        source.fillWithDash(start: 0, offsetBy: 3),
                        source.fillWithDash(start: 3, offsetBy: 3),
                        source.fillWithDash(start: 6, offsetBy: 2),
                        source.fillWithDash(start: 8, offsetBy: 2))
        
        XCTAssertEqual(result, "+7 (___) ___-__-__")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

extension String {
    /// This method makes it easier extract a substring by character index where a character is viewed as a human-readable character (grapheme cluster).
    func fillWithDash(start: Int, offsetBy: Int) -> String {
        guard let substringStartIndex = self.index(startIndex, offsetBy: start, limitedBy: endIndex) else {
            return Array(0..<offsetBy).reduce("", {(result, _) -> String in
                return result + "_"}
            )
        }
        
        if let substringEndIndex = self.index(startIndex, offsetBy: start + offsetBy, limitedBy: endIndex) {
            return String(self[substringStartIndex ..< substringEndIndex])
        }
        
        var result = String(self[substringStartIndex...])
        
        if (result.count < offsetBy) {
            result += Array(0..<offsetBy-result.count).reduce("", {(result, _) -> String in
                return result + "_"}
            )
        }
        
        return result
    }
}
