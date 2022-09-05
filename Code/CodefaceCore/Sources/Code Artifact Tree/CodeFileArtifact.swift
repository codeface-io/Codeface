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
        
        symbolGraph.addEdge(from: sourceSymbol, to: targetSymbol)
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
    
    public var symbolGraph = Graph<CodeSymbolArtifact>()
    
    // MARK: - Basics
    
    public let id = UUID().uuidString
    public let codeFile: CodeFile
}
