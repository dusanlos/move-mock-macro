//
//  AssertBuildResult.swift
//
//
//  Created by Dusan Los on 01/12/2023.
//

import SwiftSyntax
import SwiftSyntaxMacrosTestSupport
import _SwiftSyntaxTestSupport

func assertBuildResult<T: SyntaxProtocol>(
  _ buildable: T,
  _ expectedResult: String,
  trimTrailingWhitespace: Bool = true,
  file: StaticString = #file,
  line: UInt = #line
) {
  var buildableDescription = buildable.formatted().description
  var expectedResult = expectedResult
  if trimTrailingWhitespace {
    buildableDescription = buildableDescription.trimmingTrailingWhitespace()
    expectedResult = expectedResult.trimmingTrailingWhitespace()
  }
  assertStringsEqualWithDiff(
    buildableDescription,
    expectedResult,
    file: file,
    line: line
  )
}
