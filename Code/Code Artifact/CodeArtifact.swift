import Foundation

@MainActor
class CodeArtifact: Identifiable, ObservableObject
{
    func isRevealed() -> Bool
    {
        guard scope?.isExpanded ?? true else { return false }
            
        return scope?.isRevealed() ?? true
    }
    
    
    func reveal()
    {
        scope?.reveal()
        
        scope?.isExpanded = true
    }
    
    @Published var isExpanded: Bool
    
    // Mark: - Layout Model
    
    
    @Published var frameInScopeContent = LayoutModel(width: 100, height: 50, centerX: 50, centerY: 25)
    
    var showsContent = true
    var contentFrame: CGRect = .zero
    
    struct LayoutModel: Equatable
    {
        let width: Double
        let height: Double
        let centerX: Double
        let centerY: Double
    }
    
    // Mark: - Metrics
    
    var metrics = Metrics()
    
    struct Metrics
    {
        var linesOfCode: Int?
        var linesOfCodeWithoutParts: Int?
        
        var sizeRelativeToAllPartsInScope: Double?
    }
    
    // Mark: - Search
    
    @Published var passesSearchFilter = true
    
    var containsSearchTermRegardlessOfParts: Bool?
    var partsContainSearchTerm: Bool?
    
    // Mark: - Basics
    
    init(kind: Kind,
         parts: [CodeArtifact] = [],
         scope: CodeArtifact?)
    {
        self.kind = kind
        self.parts = parts
        self.scope = scope
        
        isExpanded = scope == nil
    }
    
    weak var scope: CodeArtifact?
    
    var parts = [CodeArtifact]()
    
    let kind: Kind
    enum Kind { case folder(CodeFolder), file(CodeFile), symbol(CodeSymbol) }
    
    let id = UUID().uuidString
}
