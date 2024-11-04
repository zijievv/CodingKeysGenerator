import Shared

@attached(member, names: named(CodingKeys))
public macro CodingKeys(style: CodingKeyStyle = .snakeCased) = #externalMacro(module: "CodingKeysGeneratorMacros", type: "CodingKeysMacro")

@attached(peer)
public macro CodingKey(custom: String) = #externalMacro(module: "CodingKeysGeneratorMacros", type: "CustomCodingKeyMacro")

@attached(peer)
public macro CodingKeyIgnored() = #externalMacro(module: "CodingKeysGeneratorMacros", type: "CodingKeyIgnoredMacro")
