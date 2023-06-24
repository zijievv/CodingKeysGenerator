import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct CodingKeysGeneratorPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        CodingKeysMacro.self,
        CustomCodingKeyMacro.self,
        CodingKeyIgnoredMacro.self,
    ]
}
