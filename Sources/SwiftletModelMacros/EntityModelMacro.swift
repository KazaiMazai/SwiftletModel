//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 03/08/2024.
//

import Foundation
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

#if !canImport(SwiftSyntax600)
  import SwiftSyntaxMacroExpansion
#endif
//
//public enum StorableEntityMacro: ExtensionMacro {
//  public static func expansion(
//    of node: AttributeSyntax,
//    attachedTo declaration: some DeclGroupSyntax,
//    providingExtensionsOf type: some TypeSyntaxProtocol,
//    conformingTo protocols: [TypeSyntax],
//    in context: some MacroExpansionContext
//  ) throws -> [ExtensionDeclSyntax] {
//    let equatableExtension = try ExtensionDeclSyntax("extension \(type.trimmed): Storable {}")
//
//    return [equatableExtension]
//      
//       
//      
//      declaration.memberBlock.members
//          .compactMap { $0.decl.as(StructDeclSyntax.self) }
//            
//  }
//}
//
//
//public enum DefaultFatalErrorImplementationMacro: ExtensionMacro {
//
//  /// Unique identifier for messages related to this macro.
//  private static let messageID = MessageID(domain: "MacroExamples", id: "ProtocolDefaultImplementation")
//
//  /// Generates extension for the protocol to which this macro is attached.
//  public static func expansion(
//    of node: AttributeSyntax,
//    attachedTo declaration: some DeclGroupSyntax,
//    providingExtensionsOf type: some TypeSyntaxProtocol,
//    conformingTo protocols: [TypeSyntax],
//    in context: some MacroExpansionContext
//  ) throws -> [ExtensionDeclSyntax] {
//
//    // Validate that the macro is being applied to a protocol declaration
//    guard let protocolDecl = declaration.as(ProtocolDeclSyntax.self) else {
//      throw SimpleDiagnosticMessage(
//        message: "Macro `defaultFatalErrorImplementation` can only be applied to a protocol",
//        diagnosticID: messageID,
//        severity: .error
//      )
//    }
//
//    // Extract all the methods from the protocol and assign default implementations
//    let methods = protocolDecl.memberBlock.members
//      .map(\.decl)
//      .compactMap { declaration -> FunctionDeclSyntax? in
//        guard var function = declaration.as(FunctionDeclSyntax.self) else {
//          return nil
//        }
//        function.body = CodeBlockSyntax {
//          ExprSyntax(#"fatalError("whoops 😅")"#)
//        }
//        return function
//      }
//
//    // Don't generate an extension if there are no methods
//    if methods.isEmpty {
//      return []
//    }
//
//    // Generate the extension containing the default implementations
//    let extensionDecl = ExtensionDeclSyntax(extendedType: type) {
//      for method in methods {
//        MemberBlockItemSyntax(decl: method)
//      }
//    }
//
//    return [extensionDecl]
//  }
//}
//
//
//
//fileprivate extension VariableDeclSyntax {
//    var isReadonlyField: Bool {
//        if case .keyword(Keyword.let) = bindingSpecifier.tokenKind {
//            return true
//        }
//
//        guard let binding = bindings.first else {
//            fatalError("compiler bug: expected a binding from VariableDeclSyntax")
//        }
//
//        guard case let .accessors(accessors) = binding.accessorBlock?.accessors else {
//            // `var` declarations without accessors should not be readonly.
//            return false
//        }
//
//        // Search for the setter for the field to be read-write.
//        for accessor in accessors {
//            if case .keyword(Keyword.set) = accessor.accessorSpecifier.tokenKind {
//                return false
//            }
//        }
//
//        // Setter is not found, the field is read-only.
//        return true
//    }
//
//    var fieldName: String {
//        guard let binding = bindings.first else {
//            fatalError("compiler bug: expected a binding from VariableDeclSyntax")
//        }
//
//        guard let ident = binding.pattern.as(IdentifierPatternSyntax.self) else {
//            fatalError("compiler bug: unknown binding pattern (\(binding.pattern))")
//        }
//
//        return ident.identifier.text
//    }
//}
//
//public struct RuntimeInspectableMacro: MemberMacro, ExtensionMacro {
//    public static func expansion(
//        of node: SwiftSyntax.AttributeSyntax,
//        attachedTo declaration: some SwiftSyntax.DeclGroupSyntax,
//        providingExtensionsOf type: some SwiftSyntax.TypeSyntaxProtocol,
//        conformingTo protocols: [SwiftSyntax.TypeSyntax],
//        in context: some SwiftSyntaxMacros.MacroExpansionContext
//    ) throws -> [SwiftSyntax.ExtensionDeclSyntax] {
//        let ext: DeclSyntax = "extension \(type.trimmed): RuntimeInspectable {}"
//        return [ext.cast(ExtensionDeclSyntax.self)]
//    }
//
//    public static func expansion(
//        of node: AttributeSyntax,
//        providingMembersOf declaration: some DeclGroupSyntax,
//        in context: some MacroExpansionContext
//    ) throws -> [DeclSyntax] {
//        let isValueType =
//            (declaration.as(StructDeclSyntax.self) != nil) ||
//            (declaration.as(EnumDeclSyntax.self) != nil)
//
//        let fieldMembers = declaration.memberBlock.members.compactMap {
//            return $0.decl.as(VariableDeclSyntax.self)
//        }
//
//        // Synthesize `allFieldNames` implementation.
//        let fieldNames = fieldMembers.map(\.fieldName)
//        let allFieldNamesDecl: DeclSyntax =
//            """
//            public var allFieldNames: AnyCollection<String> {
//                return AnyCollection(\(literal: fieldNames))
//            }
//            """
//
//        // Synthesize `field(named:)` implementation.
//        let fieldNamedMethodDecl = synthesizeFieldNamedMethod(
//            with: fieldMembers,
//            usingUnsafePointer: isValueType
//        )
//
//        return [allFieldNamesDecl, fieldNamedMethodDecl]
//    }
//
//    private static func synthesizeFieldNamedMethod(
//        with fieldMembers: [VariableDeclSyntax],
//        usingUnsafePointer: Bool
//    ) -> DeclSyntax {
//        let branches = fieldMembers.map {
//            let fieldName = $0.fieldName
//
//            let writerExpr: ExprSyntax = if $0.isReadonlyField {
//                .init(NilLiteralExprSyntax())
//            } else if usingUnsafePointer {
//                """
//                {
//                    pointer.pointee.\(raw: fieldName) = $0
//                }
//                """
//            } else {
//                """
//                {
//                    self.\(raw: fieldName) = $0
//                }
//                """
//            }
//
//            let stmt: StmtSyntax = if usingUnsafePointer {
//                """
//                if name == \(literal: fieldName) {
//                    return withUnsafeMutablePointer(to: &self) { pointer in
//                        return FieldAccessor(
//                            type: type(of: pointer.pointee.\(raw: fieldName)),
//                            name: \(literal: fieldName),
//                            reader: {
//                                return pointer.pointee.\(raw: fieldName)
//                            },
//                            writer: \(writerExpr)
//                        )
//                    }
//                }
//                """
//            } else {
//                """
//                if name == \(literal: fieldName) {
//                    return FieldAccessor(
//                        type: type(of: self.\(raw: fieldName)),
//                        name: \(literal: fieldName),
//                        reader: {
//                            return self.\(raw: fieldName)
//                        },
//                        writer: \(writerExpr)
//                    )
//                }
//                """
//            }
//
//            return stmt
//        }
//
//        let mutatingKeyword = if usingUnsafePointer {
//            TokenSyntax.keyword(.mutating)
//        } else {
//            TokenSyntax.unknown("")
//        }
//
//        let methodDecl: DeclSyntax =
//            """
//            public \(mutatingKeyword) func field(named name: String) -> FieldAccessing? {
//                \(CodeBlockItemListSyntax(branches.map {
//                    .init(item: .stmt($0))
//                }))
//                return nil
//            }
//            """
//
//        return methodDecl
//    }
//}
// 

//public struct ListablePropertiesMacro: ExtensionMacro {
//    public static func expansion(of node: SwiftSyntax.AttributeSyntax, attachedTo declaration: some SwiftSyntax.DeclGroupSyntax, providingExtensionsOf type: some SwiftSyntax.TypeSyntaxProtocol, conformingTo protocols: [SwiftSyntax.TypeSyntax], in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.ExtensionDeclSyntax] {
//        let variables = declaration.memberBlock.members
//            .compactMap { $0.decl.as(VariableDeclSyntax.self) }
//            .filter { $0.modifiers.first?.name.text != "static" }
//        
//        let varNames = variables.compactMap {
//            $0.bindings.first?.pattern.as(IdentifierPatternSyntax.self)?.identifier.text
//        }
//        
//        let syntax = try ExtensionDeclSyntax("""
//        extension \(raw: type) {
//            static func getProperties() -> [String] {
//                \(raw: varNames)
//            }
//        }
//        """)
//        
//        return [syntax]
//    }
//    
//    
//}

public struct StorableEntityMacro: ExtensionMacro {
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, attachedTo declaration: some SwiftSyntax.DeclGroupSyntax, providingExtensionsOf type: some SwiftSyntax.TypeSyntaxProtocol, conformingTo protocols: [SwiftSyntax.TypeSyntax], in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.ExtensionDeclSyntax] {
        

        let normalize = try normalizeMe(declaration: declaration, type: type)
        let save = try saveMe(declaration: declaration, type: type)
        return [normalize, save].compactMap { $0 }
    }
     
    static func relationAttribute(from list: AttributeListSyntax) -> Bool {
        for attribute in list {
            guard let customAttribute = attribute.as(AttributeSyntax.self),
                let name = customAttribute.attributeName.as(IdentifierTypeSyntax.self),
                  name.name.text == "HasMany" || 
                    name.name.text == "HasOne" ||
                    name.name.text == "BelongsTo" else {
                continue
            }
            return true
        }
        return false
    }
    
    
    static func atts(from vars: VariableDeclSyntax) -> String? {
        for attribute in vars.attributes {
            guard let customAttribute = attribute.as(AttributeSyntax.self),
                let name = customAttribute.attributeName.as(IdentifierTypeSyntax.self),
                (name.name.text == "HasMany" ||
                    name.name.text == "HasOne" ||
                    name.name.text == "BelongsTo") else {
                continue
            }
            
            if let argumentList = customAttribute.arguments?.as(LabeledExprListSyntax.self) {
                return argumentList.map {
                    let label = $0.label.map { "\($0): "} ?? ""
                    let expression = "\($0.expression)".replacingOccurrences(of: "\\.", with: "\\.$")
                                  
                    return "\(label)\(expression)"
                }
                .joined(separator: ",")
                 
            }
            
            if let text = vars.bindings.first?.pattern.as(IdentifierPatternSyntax.self)?.identifier.text {
                return "\\.$\(text)"
            }
                
        }
        return nil
    }
    
    
    static func normalizeMe(declaration: some SwiftSyntax.DeclGroupSyntax,
                            type: some SwiftSyntax.TypeSyntaxProtocol) throws -> SwiftSyntax.ExtensionDeclSyntax? {
        
        let variables = declaration.memberBlock.members
            .compactMap { $0.decl.as(VariableDeclSyntax.self) }
            .filter { relationAttribute(from: $0.attributes) }
            .filter { $0.modifiers.first?.name.text != "static" }
        
        let varNames = variables.compactMap {
            $0.bindings.first?.pattern.as(IdentifierPatternSyntax.self)?.identifier.text
       
        }.map {
            "$\($0).normalize()"
        }
        
        let body = varNames.joined(separator: "\n")
        
        let syntax = try ExtensionDeclSyntax("""
        extension \(raw: type) {
            mutating func normalizeMe() {
               \(raw: body)
            }
        }
        """)
        
        return syntax
    }
    
    static func saveMe(declaration: some SwiftSyntax.DeclGroupSyntax,
                            type: some SwiftSyntax.TypeSyntaxProtocol) throws -> SwiftSyntax.ExtensionDeclSyntax? {
        
        let variables = declaration.memberBlock.members
            .compactMap { $0.decl.as(VariableDeclSyntax.self) }
            .compactMap { atts(from: $0) }
            .map {
                "try save(\($0), to: &context)"
            }
        
        let body = variables.joined(separator: "\n")
        
        let syntax = try ExtensionDeclSyntax("""
        extension \(raw: type) {
            func saveMe(to context: inout Context) throws {
                context.insert(self)
                \(raw: body)
            }
        }
        """)
        
        return syntax
    }
     
    
}

//class AtGlobalVisitor: SyntaxVisitor {
//
//    struct Result {
//        let name: String
//        let type: String
//        let location: SourceRange
//        let url: URL
//    }
//
//    let converter: SourceLocationConverter
//    let url: URL
//    var results = [Result]()
//
//    init(url: URL, tree: SourceFileSyntax) {
//        self.converter = SourceLocationConverter(file: url.path, tree: tree)
//        self.url = url
//        super.init()
//        walk(tree)
//    }
//
//    func atGlobalAttribute(from list: AttributeListSyntax) -> CustomAttributeSyntax? {
//        for attribute in list {
//            guard let customAttribute = attribute.as(CustomAttributeSyntax.self),
//                let name = customAttribute.attributeName.as(SimpleTypeIdentifierSyntax.self),
//                name.name.text == "Global" else { continue }
//            return customAttribute
//        }
//        return nil
//    }
//
//    func identifierBinding(from list: PatternBindingListSyntax) -> (PatternBindingSyntax, name: String)? {
//        for binding in list {
//            guard let name = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text else { return nil }
//            return (binding, name)
//        }
//        return nil
//    }
//
//    func type(from attribute: CustomAttributeSyntax, _ binding: PatternBindingSyntax) -> (TypeSyntax, name: String)? {
//        guard let type = binding.typeAnnotation?.type ?? attribute.attributeName.as(SimpleTypeIdentifierSyntax.self)?.genericArgumentClause?.arguments.first?.argumentType,
//            let name = type.as(SimpleTypeIdentifierSyntax.self)?.name.text else { return nil }
//        return (type, name)
//    }
//
//    override func visit(_ node: VariableDeclSyntax) -> SyntaxVisitorContinueKind {
//        if let attribute = node.attributes.flatMap(atGlobalAttribute),
//            let (binding, name) = identifierBinding(from: node.bindings),
//            let (_, type) = type(from: attribute, binding) {
//                let location = node.sourceRange(converter: converter)
//            results.append(Result(name: name, type: type, location: location, url: url))
//        }
//        return .skipChildren
//    }
//
//}


