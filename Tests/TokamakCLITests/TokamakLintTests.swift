//
//  TokamakLintTests.swift
//  TokamakCLI
//
//  Created by Matvii Hodovaniuk on 3/31/19.
//

@testable import TokamakLint
import XCTest

final class TokamakLintTests: XCTestCase {
  func testPositivePropsIsEquatableRule() throws {
    let path = "\(try srcRoot())/ValidationTests/TestPropsEquatable.swift"
    let result = try PropsIsEquatableRule.validate(path: path)
    XCTAssertEqual(result, [])
  }

  func testNegativePropsIsEquatableRule() throws {
    let path = "\(try srcRoot())/ValidationTests/TestPropsIsNotEquatable.swift"
    let result = try PropsIsEquatableRule.validate(path: path)
    XCTAssertEqual(result.count, 1)
  }

  func testOneRenderFunctionRule() throws {
    let path = "\(try srcRoot())/ValidationTests/PositiveTestHooksRule.swift"
    let result = try OneRenderFunctionRule.validate(path: path)
    XCTAssertEqual(result, [])
  }

  func testRenderGetsHooksRule() throws {
    let path = "\(try srcRoot())/ValidationTests/PositiveTestHooksRule.swift"
    let result = try RenderGetsHooksRule.validate(path: path)
    XCTAssertEqual(result, [])
  }
}
