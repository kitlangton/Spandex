//
//  SpandexTests.swift
//  SpandexTests
//
//  Created by Kit Langton on 1/12/21.
//

@testable import Spandex
import XCTest

class SpandexTests: XCTestCase {
    /**
     ## Matches
     - xname
     -  xname
     - the xname
     ## Not Matches
     - xnot
     - xnam
     - theuxname
     */
    func testSnippetMatching() throws {
        let snippet = Snippet(trigger: "xname", content: "Kit Langton")
        XCTAssert(snippet.matches("xname"))
        XCTAssert(snippet.matches(" xname"))
        XCTAssert(snippet.matches("the xname"))
        XCTAssert(!snippet.matches("xnot"))
        XCTAssert(!snippet.matches("xnam"))
        XCTAssert(!snippet.matches("theuxname"))
    }
}
