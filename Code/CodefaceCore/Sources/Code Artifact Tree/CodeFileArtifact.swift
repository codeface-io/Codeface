import Foundation
import SwiftyToolz

extension CodeFileArtifact: CodeArtifact
{
    public func addDependency(from source: CodeArtifact,
                              to target: CodeArtifact)
    {
        guard let sourceSymbol = source as? CodeSymbolArtifact,
              let targetSymbol = target as? CodeSymbolArtifact
        else
        {
            log(error: "Tried to add dependency to file scope between non-symbol artifacts.")
            return
        }
        
        guard let sourceNode = symbols.first(where: { $0.content === sourceSymbol } ),
              let targetNode = symbols.first(where: { $0.content === targetSymbol } )
        else
        {
            log(error: "Tried to add dependency to file scope between symbols artifacts that are not in scope.")
            return
        }
        
        symbolDependencies.addEdge(from: sourceNode, to: targetNode)
    }
    
    public var name: String { codeFile.name }
    public var kindName: String { "File" }
    public var code: String? { codeFile.code }
}

public class CodeFileArtifact: Identifiable, ObservableObject
{
    public init(codeFile: CodeFile, scope: CodeArtifact)
    {
        self.codeFile = codeFile
        self.scope = scope
    }
    
    // MARK: - Metrics
    
    public var metrics = Metrics()
    
    // MARK: - Tree Structure
    
    public weak var scope: CodeArtifact?
    
    public var symbols = [Node<CodeSymbolArtifact>]()
    public var symbolDependencies = Edges<CodeSymbolArtifact>()
    
    // MARK: - Basics
    
    public let id = UUID().uuidString
    public let codeFile: CodeFile
}
