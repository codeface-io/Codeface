import AST
import Parser
import Source

func testSwiftAST(withFileContent content: String)
{
    let parser = Parser(source: SourceFile(content: content))
    
    do
    {
        let fileSyntaxTree = try parser.parse()

        TopLevelTypeReporter().reportTypes(in: fileSyntaxTree)
    }
    catch let error
    {
        print(error.localizedDescription)
    }
}

class TopLevelTypeReporter
{
    func reportTypes(in topLevelDecl: TopLevelDeclaration)
    {
        for statement in topLevelDecl.statements
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
