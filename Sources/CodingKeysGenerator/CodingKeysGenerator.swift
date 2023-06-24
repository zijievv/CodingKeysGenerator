@attached(member, names: named(CodingKeys))
public macro CodingKeys() = #externalMacro(module: "CodingKeysGeneratorMacros", type: "CodingKeysMacro")

@attached(member)
public macro CodingKey(custom: String) = #externalMacro(
    module: "CodingKeysGeneratorMacros",
    type: "CustomCodingKeyMacro"
)

@attached(member)
public macro CodingKeyIgnored() = #externalMacro(module: "CodingKeysGeneratorMacros", type: "CodingKeyIgnoredMacro")
