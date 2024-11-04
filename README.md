# CodingKeysGenerator

Swift macros generating customizable CodingKeys

## Declaration

```swift
public enum CodingKeyStyle {
    case camelCased
    case kebabCased
    case snakeCased
}

@attached(member, names: named(CodingKeys))
public macro CodingKeys(style: CodingKeyStyle = .snakeCased) = #externalMacro(module: "CodingKeysGeneratorMacros", type: "CodingKeysMacro")

@attached(peer)
public macro CodingKey(custom: String) = #externalMacro(module: "CodingKeysGeneratorMacros", type: "CustomCodingKeyMacro")

@attached(peer)
public macro CodingKeyIgnored() = #externalMacro(module: "CodingKeysGeneratorMacros", type: "CodingKeyIgnoredMacro")
```

## Usage

Source code:

```swift
@CodingKeys(style: .snakeCased) // default style is `snakeCased`
struct Entity {
    @CodingKey(custom: "entity_id")
    let id: String
    let currentValue: Int
    let count: Int
    let `protocol`: String
    @CodingKeyIgnored
    let foo: Bool
}
```

Expanded source:

```swift
struct Entity {
    let id: String
    let currentValue: Int
    let count: Int
    let `protocol`: String
    let foo: Bool
    enum CodingKeys: String, CodingKey {
        case id = "entity_id"
        case currentValue = "current_value"
        case count
        case `protocol`
    }
}
```

## Installation

### [Swift Package Manager](https://www.swift.org/package-manager/) (SPM)

Add the following line to the dependencies in `Package.swift`, to use CodingKeysGenerator macros in a SPM project:

```swift
.package(url: "https://github.com/zijievv/CodingKeysGenerator", from: "0.1.0"),
```

In your target:

```swift
.target(name: "<TARGET_NAME>", dependencies: [
    .product(name: "CodingKeysGenerator", package: "CodingKeysGenerator"),
    // ...
]),
```

Add `import CodingKeysGenerator` into your source code to use CodingKeysGenerator macros.

### Xcode

Go to `File > Add Package Dependencies...` and paste the repo's URL:

```
https://github.com/zijievv/CodingKeysGenerator
```
