import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

@testable import CodingKeysGeneratorMacros
@testable import Shared

let testMacros: [String: Macro.Type] = [
    "CodingKeys": CodingKeysMacro.self,
    "CodingKey": CustomCodingKeyMacro.self,
    "CodingKeyIgnored": CodingKeyIgnoredMacro.self,
]

final class CodingKeysGeneratorTests: XCTestCase {
    func testSnakeCasedCodingKeysMacros() {
        let source = """
            @CodingKeys
            struct Entity {
                @CodingKey(custom: "entityID")
                let id: String
                let currentValue: Int
                @CodingKeyIgnored
                let foo: Bool
                let count: Int
                let `protocol`: String
            }
            """
        let expected = """

            struct Entity {
                let id: String
                let currentValue: Int
                let foo: Bool
                let count: Int
                let `protocol`: String

                enum CodingKeys: String, CodingKey {
                    case id = "entityID"
                    case currentValue = "current_value"
                    case count
                    case `protocol`
                }
            }
            """
        assertMacroExpansion(source, expandedSource: expected, macros: testMacros)
    }

    func testKebabCasedCodingKeysMacros() {
        let source = """
            @CodingKeys(style: .kebabCased)
            struct Entity {
                @CodingKey(custom: "entity_id")
                let id: String
                let currentValue: Int
                @CodingKeyIgnored
                let foo: Bool
                let count: Int
                let `protocol`: String
            }
            """
        let expected = """

            struct Entity {
                let id: String
                let currentValue: Int
                let foo: Bool
                let count: Int
                let `protocol`: String

                enum CodingKeys: String, CodingKey {
                    case id = "entity_id"
                    case currentValue = "current-value"
                    case count
                    case `protocol`
                }
            }
            """
        assertMacroExpansion(source, expandedSource: expected, macros: testMacros)
    }

    func testCamelCasedCodingKeysMacros() {
        let source = """
            @CodingKeys(style: .camelCased)
            struct Entity {
                @CodingKey(custom: "entity_id")
                let id: String
                let currentValue: Int
                @CodingKeyIgnored
                let foo: Bool
                let count: Int
                let `protocol`: String
            }
            """
        let expected = """

            struct Entity {
                let id: String
                let currentValue: Int
                let foo: Bool
                let count: Int
                let `protocol`: String

                enum CodingKeys: String, CodingKey {
                    case id = "entity_id"
                    case currentValue
                    case count
                    case `protocol`
                }
            }
            """
        assertMacroExpansion(source, expandedSource: expected, macros: testMacros)
    }

    func testStaticProperties() {
        let source = """
            @CodingKeys
            struct Entity {
                static var foo: Int { 1 }
                static var boo: Int = 1
                static let bar: String = "ssp"
                let value: Int
            }
            """
        let expected = """

            struct Entity {
                static var foo: Int { 1 }
                static var boo: Int = 1
                static let bar: String = "ssp"
                let value: Int

                enum CodingKeys: String, CodingKey {
                    case value
                }
            }
            """
        assertMacroExpansion(source, expandedSource: expected, macros: testMacros)
    }

    func testClassProperties() {
        let source = """
            @CodingKeys
            class Entity {
                final class var foo: Int { 1 }
                class var boo: Int = 1
                class let bar: String = "ssp"
                let value: Int
            }
            """
        let expected = """

            class Entity {
                final class var foo: Int { 1 }
                class var boo: Int = 1
                class let bar: String = "ssp"
                let value: Int

                enum CodingKeys: String, CodingKey {
                    case value
                }
            }
            """
        assertMacroExpansion(source, expandedSource: expected, macros: testMacros)
    }

    func testComputedProperties() {
        let source = """
            @CodingKeys
            struct Entity {
                var bar: Int
                var foo: Int {
                    didSet {
                        print(foo)
                    }
                }
                var title: String { "Entity" }
                var barWrapper: Int {
                    get { bar }
                    set { bar = newValue }
                }
            }
            """
        let expected = """

            struct Entity {
                var bar: Int
                var foo: Int {
                    didSet {
                        print(foo)
                    }
                }
                var title: String { "Entity" }
                var barWrapper: Int {
                    get { bar }
                    set { bar = newValue }
                }

                enum CodingKeys: String, CodingKey {
                    case bar
                    case foo
                }
            }
            """
        assertMacroExpansion(source, expandedSource: expected, macros: testMacros)
    }
}
