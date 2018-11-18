import AST
import Parser
import Source

class SwiftASTTypeRetriever: TypeRetriever
{
    // MARK: - Retrieve Type Declarations
    
    func topLevelTypes(in code: String) -> Set<String>?
    {
        let parser = Parser(source: SourceFile(content: code))
        
        do
        {
            let syntaxTree = try parser.parse()
            
            return topLevelTypeDeclarations(in: syntaxTree)
        }
        catch let error
        {
            print(error.localizedDescription)
            return nil
        }
    }
    
    func topLevelTypeDeclarations(in syntaxTree: TopLevelDeclaration) -> Set<String>
    {
        var result = Set<String>()
        
        for statement in syntaxTree.statements
        {
            guard case let declaration as Declaration = statement,
                let identifierString = typeIdentifier(from: declaration)?.string else
            {
                continue
            }
            
            result.insert(identifierString)
        }
        
        return result
    }
    
    private func typeIdentifier(from declaration: Declaration) -> Identifier?
    {
        switch declaration
        {
        case let decl as ClassDeclaration: return decl.name
        case let decl as EnumDeclaration: return decl.name
        case let decl as ProtocolDeclaration: return decl.name
        case let decl as StructDeclaration: return decl.name
        case let decl as TypealiasDeclaration: return decl.name
        default: return nil
        }
    }
    
    // MARK: - Retrieve Type References
    
    func referencedTypes(in code: String) -> Set<String>?
    {
        return TypeReferenceReporter().namesOfReferencedTypes(in: code)
    }
}

// TODO: report top level types for nested types
class TypeReferenceReporter: ASTVisitor
{
    func namesOfReferencedTypes(in code: String) -> Set<String>?
    {
        let parser = Parser(source: SourceFile(content: code))
        
        result.removeAll()
        
        do
        {
            let syntaxTree = try parser.parse()
            
            try _ = traverse(syntaxTree)
            
            return result
        }
        catch let error
        {
            print(error.localizedDescription)
            return nil
        }
    }
    
    func visit(_ classDecl: ClassDeclaration) throws -> Bool
    {
        for typeId in classDecl.typeInheritanceClause?.typeInheritanceList ?? []
        {
            for typeName in typeId.names
            {
                report(type: typeName.name)
            }
        }
        
        return true
    }

    func visit(_ decl: ExtensionDeclaration) throws -> Bool
    {
        for req in decl.genericWhereClause?.requirementList ?? []
        {
            let desc = req.description.replacingOccurrences(of: " ", with: "")
            
            if let possibleType = desc.components(separatedBy: "==").last
            {
                result.insert(possibleType)
            }
            else
            {
                print("couldn't detect type in generic where clause requirement: \(req.description)")
            }
        }

        for typeName in decl.type.names
        {
            report(type: typeName.name)
        }

        return true
    }

    func visit(_ decl: ProtocolDeclaration) throws -> Bool
    {
        let inheritedTypes = decl.typeInheritanceClause?.typeInheritanceList
        for inheritedType in inheritedTypes ?? []
        {
            for typeName in inheritedType.names
            {
                report(type: typeName.name)

                for argument in typeName.genericArgumentClause?.argumentList ?? []
                {
                    // TODO: manually extract potential types from argument.description
                    print(argument.description)
                    result.insert(argument.description)
                }
            }
        }

        return true
    }
    
    func visit(_ constant: ConstantDeclaration) throws -> Bool
    {
        for initializer in constant.initializerList
        {
            if let expr = initializer.initializerExpression?.description
            {
                // TODO: manually extract potential types from expressionString
                
                var components = expr.components(separatedBy: .punctuationCharacters)
                
                components = components.compactMap
                {
                    let component = $0.replacingOccurrences(of: " ", with: "")
                    
                    return component.count > 0 ? component : nil
                }
                
                for component in components
                {
                    result.insert(component)
                }
            }
        }

        return true
    }
    
    func visit(_ decl: FunctionDeclaration) throws -> Bool
    {
        if let type = decl.signature.result?.type
        {
            // TODO: manually extract potential type
            result.insert(type.description)
        }

        for param in decl.signature.parameterList
        {
            // TODO: manually extract potential type
            result.insert(param.typeAnnotation.type.description)
        }

        return true
    }
    
    private func report(type identifier: Identifier)
    {
        if let string = identifier.string
        {
            result.insert(string)
        }
    }
    
    private var result = Set<String>()
}

extension Identifier
{
    var string: String?
    {
        switch self
        {
        case .name(let string): return string
        case .backtickedName(let string): return string
        case .wildcard: return nil
        }
    }
}
