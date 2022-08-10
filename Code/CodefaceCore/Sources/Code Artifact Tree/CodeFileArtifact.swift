import Foundation

extension CodeFileArtifact: CodeArtifact
{
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
    public var symbolDependencies = Edges<CodeSymbolArtifact, CodeSymbolArtifact>()
    
    // MARK: - Basics
    
    public let id = UUID().uuidString
    public let codeFile: CodeFile
}
