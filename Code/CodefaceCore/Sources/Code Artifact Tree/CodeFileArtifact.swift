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
        
        // TODO: make this sanity check O(1) or remove it after a while #performance
        guard symbols.contains(sourceSymbol) && symbols.contains(targetSymbol) else
        {
            log(error: "Tried to add dependency to file between symbols outside the file")
            return
        }
        
        symbolDependencies.addEdge(from: sourceSymbol, to: targetSymbol)
    }
    
    public var name: String { codeFile.name }
    public var kindName: String { "File" }
    public var code: String? { codeFile.code }
}

@MainActor
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
    
    public var symbols = [CodeSymbolArtifact]()
    public var symbolDependencies = Edges<CodeSymbolArtifact>()
    
    // MARK: - Basics
    
    public let id = UUID().uuidString
    public let codeFile: CodeFile
}
