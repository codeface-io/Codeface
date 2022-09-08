import Foundation
import SwiftNodes

public class CodeFileArtifact: Identifiable
{
    init(codeFile: CodeFile, scope: CodeArtifact)
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
    let codeFile: CodeFile
}
