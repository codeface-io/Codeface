import AST
import Parser
import Source

class SwiftASTCodeAnalyzer: CodeAnalyzer
{
    // MARK: - Retrieve Type Declarations
    
    func namesOfDeclaredTypes(in code: String) -> [String]?
    {
        let parser = Parser(source: SourceFile(content: code))
        
        do
        {
            let syntaxTree = try parser.parse()
            
            return topLevelTypeDeclarations(in: syntaxTree).compactMap
            {
                $0.string
            }
        }
        catch let error
        {
            print(error.localizedDescription)
            return nil
        }
    }
    
    func topLevelTypeDeclarations(in syntaxTree: TopLevelDeclaration) -> [Identifier]
    {
        var result = [Identifier]()
        
        for statement in syntaxTree.statements
        {
            guard case let declaration as Declaration = statement else
            {
                continue
            }
            
            switch declaration
            {
            case let decl as ClassDeclaration: result.append(decl.name)
            case let decl as EnumDeclaration: result.append(decl.name)
            case let decl as ProtocolDeclaration: result.append(decl.name)
            case let decl as StructDeclaration: result.append(decl.name)
            case let decl as TypealiasDeclaration: result.append(decl.name)
            default: break
            }
        }
        
        return result
    }
    
    // MARK: - Retrieve Type References
    
    func namesOfReferencedTypes(in code: String) -> [String]?
    {
        return TypeReferenceReporter().namesOfReferencedTypes(in: code)
    }
}

// TODO: report top level types for nested types
class TypeReferenceReporter: ASTVisitor
{
    func namesOfReferencedTypes(in code: String) -> [String]?
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
            // TODO: manually extract potential types from req.description
            result.append(req.description)
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
                    result.append(argument.description)
                }
            }
        }

        return true
    }
    
    func visit(_ constant: ConstantDeclaration) throws -> Bool
    {
        for initializer in constant.initializerList
        {
            if let expressionString = initializer.initializerExpression?.description
            {
                // TODO: manually extract potential types from expressionString
                result.append(expressionString)
            }
        }

        return true
    }
    
    func visit(_ decl: FunctionDeclaration) throws -> Bool
    {
        if let type = decl.signature.result?.type
        {
            // TODO: manually extract potential type
            result.append(type.description)
        }

        for param in decl.signature.parameterList
        {
            // TODO: manually extract potential type
            result.append(param.typeAnnotation.type.description)
        }

        return true
    }
    
    private func report(type identifier: Identifier)
    {
        if let string = identifier.string
        {
            result.append(string)
        }
    }
    
    private var result = [String]()
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
