import Foundation

extension CodeSymbolArtifact
{
    var positionInFile: Int
    {
        codeSymbol.range.start.line
    }
    
    var name: String { codeSymbol.name }
    var kindName: String { codeSymbol.kindName }
    var code: String? { codeSymbol.code }
}

@MainActor
class CodeSymbolArtifact: Identifiable, ObservableObject
{
    init(codeSymbol: CodeSymbol, scope: Scope)
    {
        self.codeSymbol = codeSymbol
        self.scope = scope
    }
    
    // Mark: - Metrics
    
    var metrics = Metrics()
    
    // Mark: - Search
    
    @Published var passesSearchFilter = true
    
    var containsSearchTermRegardlessOfParts: Bool?
    var partsContainSearchTerm: Bool?
    
    // Mark: - Tree Structure
    
    // TODO: scope reference ought to be weak
    var scope: Scope
    
    enum Scope
    {
        case file(CodeFileArtifact)
        case symbol(CodeSymbolArtifact)
    }
    
    var subSymbols = [CodeSymbolArtifact]()
    
    // Mark: - Basics
    
    let id = UUID().uuidString
    let codeSymbol: CodeSymbol
}
