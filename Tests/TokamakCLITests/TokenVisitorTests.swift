//
//  TokenVisitorTests.swift
//  SwiftSyntax
//
//  Created by Matvii Hodovaniuk on 5/1/19.
//

import SwiftSyntax
@testable import TokamakLint
import XCTest

final class TokenVisitorTests: XCTestCase {
  func testRange() throws {
    let srcRoot = ProcessInfo.processInfo.environment["SRCROOT"]!
    let path = "\(srcRoot)/ValidationTests/TestPropsEquatable.swift"

    let fileURL = URL(fileURLWithPath: path)
    let parsedTree = try SyntaxTreeParser.parse(fileURL)
    let visitor = TokenVisitor()

    visitor.path = path
    parsedTree.walk(visitor)

    let startRow = 11
    let endRow = 11
    let startColumn = 0
    let endColumn = 7
    let structs = visitor.getNodes(get: "StructDecl", from: visitor.tree[0])
    let structDecl = structs[0].children[0]

    XCTAssertEqual(startRow, structDecl.range.startRow)
    XCTAssertEqual(endRow, structDecl.range.endRow)
    XCTAssertEqual(startColumn, structDecl.range.startColumn)
    XCTAssertEqual(endColumn, structDecl.range.endColumn)
  }
}
