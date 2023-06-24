# CodingKeysGenerator

Swift macros generating customizable CodingKeys

## Usage

Source code:

```swift
@CodingKeys
struct Entity {
    @CodingKey(custom: "entity_id")
    let id: String
    let currentValue: Int
    @CodingKeyIgnored
    let foo: Bool
}
```

Expanded source:

```swift
struct Entity {
    let id: String
    let currentValue: Int
    let foo: Bool
    enum CodingKeys: String, CodingKey {
        case id = "entity_id"
        case currentValue = "current_value"
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
