import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

struct SimpleDiagnosticMessage: DiagnosticMessage {
    let message: String
    
    var severity: DiagnosticSeverity { .error }
    var diagnosticID: MessageID { MessageID(domain: "ViewModelMacro", id: message) }
}

public struct ViewModelMacro: MemberMacro, ExtensionMacro {
    // Protocol 추가
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        attachedTo declaration: some SwiftSyntax.DeclGroupSyntax,
        providingExtensionsOf type: some SwiftSyntax.TypeSyntaxProtocol,
        conformingTo protocols: [SwiftSyntax.TypeSyntax],
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.ExtensionDeclSyntax] {
        let observableExtension = try ExtensionDeclSyntax("extension \(type.trimmed): ObservableObject {}")
        return [observableExtension]
    }
    
    // 내부 기본 메서드 적용
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let (hasState, hasAction, hasReduce) = validateRequirements(in: declaration, context: context)
        
        guard hasState && hasAction && hasReduce else {
            return []
        }
        
        let members = generateViewModelMembers()
        return members
    }
    
    // 기본 구현 요구 사항에 대한 warning, error
    private static func validateRequirements(
      in declaration: some DeclGroupSyntax,
      context: some MacroExpansionContext
    ) -> (hasState: Bool, hasAction: Bool, hasReduce: Bool) {
        var hasState = false
        var hasAction = false
        var hasReduce = false

        for member in declaration.memberBlock.members {
            if let structDecl = member.decl.as(StructDeclSyntax.self),
               structDecl.name.text == "State" {
                hasState = true
            }
            
            if let enumDecl = member.decl.as(EnumDeclSyntax.self),
               enumDecl.name.text == "Action" {
                hasAction = true
            }

            if let funcDecl = member.decl.as(FunctionDeclSyntax.self),
               funcDecl.name.text == "reduce" {
                let parameters = funcDecl.signature.parameterClause.parameters
                if parameters.count == 2,
                   parameters.first?.firstName.text == "state",
                   parameters.last?.firstName.text == "action",
                   let type = parameters.first?.type.as(AttributedTypeSyntax.self),
                   ((type.specifiers.first?.description.hasPrefix("inout")) != nil),
                   type.baseType.description.trimmingCharacters(in: .whitespacesAndNewlines) == "State" {
                    hasReduce = true
                }
            }
        }

        if !hasState {
            let fixIt = FixIt(
                message: SimpleFixItMessage(message: "Insert struct State {}"),
                changes: [
                    .replaceTrailingTrivia(
                        token: declaration.memberBlock.leftBrace,
                        newTrivia: Trivia(pieces:
                            declaration.memberBlock.leftBrace.trailingTrivia + [
                            .newlines(1),
                            .spaces(4),
                            .lineComment("struct State { }"),
                            .newlines(1)
                        ])
                    )
                ]
            )

            context.diagnose(
                Diagnostic(
                    node: Syntax(declaration),
                    message: SimpleDiagnosticMessage(message: "Missing required struct 'State'"),
                    fixIts: [fixIt]
                )
            )
        }

        if !hasAction {
            let fixIt = FixIt(
                message: SimpleFixItMessage(message: "Insert enum Action {}"),
                changes: [
                    .replaceTrailingTrivia(
                        token: declaration.memberBlock.leftBrace,
                        newTrivia: Trivia(pieces:
                            declaration.memberBlock.leftBrace.trailingTrivia + [
                            .newlines(1),
                            .spaces(4),
                            .lineComment("enum Action { }"),
                            .newlines(1)
                        ])
                    )
                ]
            )

            context.diagnose(
                Diagnostic(
                    node: Syntax(declaration),
                    message: SimpleDiagnosticMessage(message: "Missing required enum 'Action'"),
                    fixIts: [fixIt]
                )
            )
        }

        if !hasReduce {
            let fixIt = FixIt(
                message: SimpleFixItMessage(message: "Insert reduce function"),
                changes: [
                    .replaceTrailingTrivia(
                        token: declaration.memberBlock.leftBrace,
                        newTrivia: Trivia(pieces:
                            declaration.memberBlock.leftBrace.trailingTrivia + [
                            .newlines(1),
                            .spaces(4),
                            .lineComment("func reduce(state: inout State, action: Action) { }"),
                            .newlines(1)
                        ])
                    )
                ]
            )

            context.diagnose(
                Diagnostic(
                    node: Syntax(declaration),
                    message: SimpleDiagnosticMessage(message: "Missing required function 'reduce(state:action:)'"),
                    fixIts: [fixIt]
                )
            )
        }

        return (hasState, hasAction, hasReduce)
    }

    // 내부적으로 구현할 항목
    private static func generateViewModelMembers() -> [DeclSyntax] {
        let stateProperty: DeclSyntax = """
        @Published private(set) var state = State()
        """
        
        let sendMethod: DeclSyntax = """
        func send(_ action: Action) {
            reduce(state: &state, action: action)
        }
        """
        let dynamicMemberSubscript: DeclSyntax = """
        subscript<T>(dynamicMember keyPath: KeyPath<State, T>) -> T {
            state[keyPath: keyPath]
        }
        """
        
        return [stateProperty, sendMethod, dynamicMemberSubscript]
    }
}

struct SimpleFixItMessage: FixItMessage {
    let message: String
    var fixItID: MessageID { .init(domain: "ViewModelMacro", id: message) }
}

@main
struct ViewModelMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        ViewModelMacro.self,
    ]
}
