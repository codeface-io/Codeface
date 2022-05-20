import Foundation

@MainActor
class CodeArtifact: Identifiable, ObservableObject
{
    // Mark: - Layout Model
    
    @Published var layoutModel = LayoutModel(width: 100, height: 50, centerX: 50, centerY: 25)
    
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
    }
    
    // Mark: - Search
    
    @Published var passesSearchFilter = true
    
    var containsSearchTermRegardlessOfParts = true
    var partsContainSearchTerm = true
    
    // Mark: - Basics
    
    init(kind: Kind, parts: [CodeArtifact] = [])
    {
        self.kind = kind
        self.parts = parts
    }
    
    var parts = [CodeArtifact]()
    
    let kind: Kind
    enum Kind { case folder(CodeFolder), file(CodeFile), symbol(CodeSymbol) }
    
    let id = UUID().uuidString
}
