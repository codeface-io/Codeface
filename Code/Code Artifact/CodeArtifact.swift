import Foundation

@MainActor
class CodeArtifact: Identifiable, ObservableObject
{
    // Mark: - Presentation Model
    
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
    
    @Published var isExpanded = false
    
    @Published var frameInScopeContent = LayoutFrame.zero
    
    var showsContent = true
    var contentFrame = LayoutFrame.zero
    
    struct LayoutFrame: Equatable
    {
        static var zero: LayoutFrame { .init(centerX: 0, centerY: 0, width: 0, height: 0) }
        
        init(centerX: Double, centerY: Double, width: Double, height: Double)
        {
            self.centerX = centerX
            self.centerY = centerY
            self.width = width
            self.height = height
        }
        
        init(x: Double, y: Double, width: Double, height: Double)
        {
            self.centerX = x + width / 2
            self.centerY = y + height / 2
            self.width = width
            self.height = height
        }
        
        var x: Double { centerX - width / 2 }
        var y: Double { centerY - height / 2 }
        
        let centerX: Double
        let centerY: Double
        let width: Double
        let height: Double
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
    
    // Mark: - Tree Structure
    
    weak var scope: CodeArtifact?
    
    var parts = [CodeArtifact]()
    
    // Mark: - Basics
    
    init(kind: Kind, scope: CodeArtifact?)
    {
        self.kind = kind
        self.scope = scope
    }
    
    let kind: Kind
    
    enum Kind { case folder(CodeFolder), file(CodeFile), symbol(CodeSymbol) }
    
    let id = UUID().uuidString
}
