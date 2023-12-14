#if canImport(SwiftCompilerPlugin)
  import SwiftCompilerPlugin
  import SwiftSyntaxMacros

  @main
  struct MoveMockCompilerPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
      MoveMockMacros.self
    ]
  }
#endif
