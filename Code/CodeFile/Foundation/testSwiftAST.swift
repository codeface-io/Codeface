import AST
import Parser
import Source

func testSwiftAST(withFileContent content: String)
{
    let parser = Parser(source: SourceFile(content: content))
    
    do
    {
        let fileSyntaxTree = try parser.parse()

        _ = try TypeReferenceReporter().traverse(fileSyntaxTree)
        //TopLevelTypeReporter().reportTypes(in: fileSyntaxTree)
    }
    catch let error
    {
        print(error.localizedDescription)
    }
}

class TypeReferenceReporter: ASTVisitor
{
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
            //print("where clause requirement: " + req.description)
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
                    //print("generic argument: \(argument.description)")
                }
            }
        }

        return true
    }
    
    func visit(_ constant: ConstantDeclaration) throws -> Bool
    {
        for initializer in constant.initializerList
        {
            //print("init expr: " + (initializer.initializerExpression?.description ?? ""))
        }

        return true
    }
    
    func visit(_ decl: FunctionDeclaration) throws -> Bool
    {
        if let type = decl.signature.result?.type
        {
            print("type: \(type)")
        }

        for param in decl.signature.parameterList
        {
            print("type: \(param.typeAnnotation.type)")
        }

        return true
    }
    
    private func report(type identifier: Identifier)
    {
        switch identifier
        {
        case .name(let string): print("type: " + string)
        case .backtickedName(let string): print("type: " + string)
        case .wildcard: break
        }
    }
}


class TopLevelTypeReporter
{
    func reportTypes(in topLevelDeclaration: TopLevelDeclaration)
    {
        for statement in topLevelDeclaration.statements
        {
            guard case let declaration as Declaration = statement else
            {
                continue
            }
            
            switch declaration
            {
            case let decl as ClassDeclaration:
                report(type: decl.name)
            case let decl as EnumDeclaration:
                report(type: decl.name)
            case let decl as ProtocolDeclaration:
                report(type: decl.name)
            case let decl as StructDeclaration:
                report(type: decl.name)
            case let decl as TypealiasDeclaration:
                report(type: decl.name)
            default: break
            }
        }
    }
    
    private func report(type identifier: Identifier)
    {
        switch identifier
        {
        case .name(let string): print("type: " + string)
        case .backtickedName(let string): print("type: " + string)
        case .wildcard: break
        }
    }
}
