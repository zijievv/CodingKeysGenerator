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
        let cases: [String] = try declaration.memberBlock.members.compactMap { member in
            guard let variableDecl = member.decl.as(VariableDeclSyntax.self) else { return nil }
            guard let property = variableDecl.bindings.first?.pattern.as(IdentifierPatternSyntax.self)?.identifier.text
            else {
                return nil
            }
            if attributesElement(withIdentifier: "CodingKeyIgnored", in: variableDecl.attributes) != nil {
                return nil
            } else if let element = attributesElement(withIdentifier: "CodingKey", in: variableDecl.attributes) {
                guard let customKeyName = customKey(in: element) else {
                    let diagnostic = Diagnostic(node: Syntax(node), message: CodingKeysDiagnostic())
                    throw DiagnosticsError(diagnostics: [diagnostic])
                }
                return "case \(property) = \(customKeyName)"
            } else {
                let raw = property.dropBackticks()
                let snakeCase = raw.snakeCased()
                return raw == snakeCase ? "case \(property)" : "case \(property) = \"\(snakeCase)\""
            }
        }
        guard !cases.isEmpty else { return [] }
        let casesDecl: DeclSyntax = """
enum CodingKeys: String, CodingKey {
    \(raw: cases.joined(separator: "\n    "))
}
"""
        return [casesDecl]
    }

    private static func attributesElement(
        withIdentifier macroName: String,
        in attributes: AttributeListSyntax?
    ) -> AttributeListSyntax.Element? {
        attributes?.first {
            $0.as(AttributeSyntax.self)?
                .attributeName
                .as(SimpleTypeIdentifierSyntax.self)?
                .description == macroName
        }
    }

    private static func customKey(in attributesElement: AttributeListSyntax.Element) -> ExprSyntax? {
        attributesElement
            .as(AttributeSyntax.self)?
            .argument?
            .as(TupleExprElementListSyntax.self)?
            .first?
            .expression
    }
}

public struct CustomCodingKeyMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        []
    }
}

public struct CodingKeyIgnoredMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
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

extension String {
    fileprivate func dropBackticks() -> String {
        count > 1 && first == "`" && last == "`" ? String(dropLast().dropFirst()) : self
    }

    fileprivate func snakeCased() -> String {
        reduce(into: "") { $0.append(contentsOf: $1.isUppercase ? "_\($1.lowercased())" : "\($1)") }
    }
}
