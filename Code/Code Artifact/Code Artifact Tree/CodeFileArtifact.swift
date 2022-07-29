import Foundation

extension CodeFileArtifact: CodeArtifact
{
    var name: String { codeFile.name }
    var kindName: String { "File" }
    var code: String? { codeFile.code }
}

@MainActor
class CodeFileArtifact: Identifiable, ObservableObject
{
    init(codeFile: CodeFile, scope: CodeArtifact)
    {
        self.codeFile = codeFile
        self.scope = scope
    }
    
    // Mark: - Metrics
    
    var metrics = Metrics()
    
    // Mark: - Tree Structure
    
    weak var scope: CodeArtifact?
    
    var symbols = [CodeSymbolArtifact]()
    
    // Mark: - Basics
    
    let id = UUID().uuidString
    let codeFile: CodeFile
}
