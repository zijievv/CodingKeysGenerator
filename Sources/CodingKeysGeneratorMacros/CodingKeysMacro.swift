import Shared
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct CodingKeysMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let codingKeyStyle = try parseStyle(from: node)
        let cases: [String] = try declaration.memberBlock.members.compactMap { member in
            guard
                let variableDecl = member.decl.as(VariableDeclSyntax.self),
                variableDecl.isInstanceProperty(),
                variableDecl.isStoredProperty(),
                let property = variableDecl.propertyName(),
                !isCodingKeyIgnored(variableDecl: variableDecl)
            else { return nil }
            if let element = attributesElement(withIdentifier: "CodingKey", in: variableDecl.attributes) {
                guard let customKeyName = customKey(in: element) else {
                    let diagnostic = Diagnostic(node: Syntax(node), message: CodingKeysDiagnostic())
                    throw DiagnosticsError(diagnostics: [diagnostic])
                }
                return "case \(property) = \(customKeyName)"
            } else {
                let raw = property.dropBackticks()
                let snakeCase: String =
                    switch codingKeyStyle {
                    case .camelCased: raw
                    case .kebabCased: raw.kebabCased()
                    case .snakeCased: raw.snakeCased()
                    }
                return raw == snakeCase ? "case \(property)" : "case \(property) = \"\(snakeCase)\""
            }
        }
        guard !cases.isEmpty else { return [] }
        let accessControl =
            if let accessLevel = declaration.modifiers.map(\.name.text).first(where: { AccessControl(rawValue: $0) != nil }) {
                accessLevel + " "
            } else {
                ""
            }
        let casesDecl: DeclSyntax = """
            \(raw: accessControl)enum CodingKeys: String, CodingKey {
                \(raw: cases.joined(separator: "\n    "))
            }
            """
        return [casesDecl]
    }

    private static func parseStyle(from node: AttributeSyntax) throws -> CodingKeyStyle {
        guard
            let styleRawText = node
                .arguments?.as(LabeledExprListSyntax.self)?
                .first?
                .expression.as(MemberAccessExprSyntax.self)?.declName.baseName.text
        else {
            return .snakeCased
        }
        if let style: CodingKeyStyle = .init(rawText: styleRawText) {
            return style
        } else {
            let diagnostic = Diagnostic(node: Syntax(node), message: CodingKeysDiagnostic())
            throw DiagnosticsError(diagnostics: [diagnostic])
        }
    }

    private static func isCodingKeyIgnored(variableDecl: VariableDeclSyntax) -> Bool {
        attributesElement(withIdentifier: "CodingKeyIgnored", in: variableDecl.attributes) != nil
    }

    private static func attributesElement(
        withIdentifier macroName: String,
        in attributes: AttributeListSyntax?
    ) -> AttributeListSyntax.Element? {
        attributes?.first {
            $0.as(AttributeSyntax.self)?
                .attributeName
                .as(IdentifierTypeSyntax.self)?
                .description == macroName
        }
    }

    private static func customKey(in attributesElement: AttributeListSyntax.Element) -> ExprSyntax? {
        attributesElement
            .as(AttributeSyntax.self)?
            .arguments?
            .as(LabeledExprListSyntax.self)?
            .first?
            .expression
    }
}

public struct CustomCodingKeyMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        []
    }
}

public struct CodingKeyIgnoredMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        []
    }
}

struct CodingKeysDiagnostic: DiagnosticMessage {
    let message: String = "Empty argument"
    let diagnosticID: SwiftDiagnostics.MessageID = .init(domain: "CodingKeysGenerator", id: "emptyArgument")
    let severity: SwiftDiagnostics.DiagnosticSeverity = .error
}

extension VariableDeclSyntax {
    fileprivate func isInstanceProperty() -> Bool {
        !modifiers.contains { $0.name.text == "static" || $0.name.text == "class" }
    }

    fileprivate func isStoredProperty() -> Bool {
        guard let accessors = bindings.first?.accessorBlock?.accessors else { return true }
        guard let accessors = accessors.as(AccessorDeclListSyntax.self) else { return false }
        return accessors.contains { $0.accessorSpecifier.text == "willSet" || $0.accessorSpecifier.text == "didSet" }
    }

    fileprivate func propertyName() -> String? {
        bindings.first?.pattern.as(IdentifierPatternSyntax.self)?.identifier.text
    }
}

extension String {
    fileprivate func dropBackticks() -> String {
        count > 1 && first == "`" && last == "`" ? String(dropLast().dropFirst()) : self
    }

    fileprivate func snakeCased() -> String {
        reduce(into: "") { $0.append(contentsOf: $1.isUppercase ? "_\($1.lowercased())" : "\($1)") }
    }

    fileprivate func kebabCased() -> String {
        reduce(into: "") { $0.append(contentsOf: $1.isUppercase ? "-\($1.lowercased())" : "\($1)") }
    }
}

private enum AccessControl: String {
    case open, `public`, package, `internal`, `fileprivate`, `private`
}
