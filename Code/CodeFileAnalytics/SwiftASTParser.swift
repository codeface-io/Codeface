import AST
import Parser
import Source

func testSwiftAST(withFilePath filePath: String)
{
    do
    {
        let sourceFile = try SourceReader.read(at: filePath)
        let parser = Parser(source: sourceFile)
        let topLevelDecl = try parser.parse()
        
//        for stmt in topLevelDecl.statements
//        {
//            print(stmt.textDescription)
//        }
        
        let visitor = TypeDeclarationReporter()

        _ = try visitor.traverse(topLevelDecl)
    }
    catch let error
    {
        print(error.localizedDescription)
    }
}

// TODO: don't report nested type declarations for now. only top-level ones.
class TypeDeclarationReporter: ASTVisitor
{
    func visit(_ classDeclaration: ClassDeclaration) throws -> Bool
    {
        report(type: classDeclaration.name)
        return true
    }
    
    func visit(_ enumDeclaration: EnumDeclaration) throws -> Bool
    {
        report(type: enumDeclaration.name)
        return true
    }
    
    func visit(_ protocolDeclaration: ProtocolDeclaration) throws -> Bool
    {
        report(type: protocolDeclaration.name)
        return true
    }
    
    func visit(_ structDeclaration: StructDeclaration) throws -> Bool
    {
        report(type: structDeclaration.name)
        return true
    }
    
    func visit(_ typeAliasDeclaration: TypealiasDeclaration) throws -> Bool
    {
        report(type: typeAliasDeclaration.name)
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
