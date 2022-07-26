import Foundation

@MainActor
class CodeArtifact: Identifiable, ObservableObject
{
    // Mark: - Presentation Model
    
    @Published var presentationModel = CodeArtifactPresentationModel()
    
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
    
    enum Kind { case folder(URL), file(CodeFile), symbol(CodeSymbol) }
    
    let id = UUID().uuidString
}

struct CodeArtifactPresentationModel
{
    var showsName: Bool { frameInScopeContent.width - (2 * Self.padding + fontSize) >= 4 * fontSize }
    
    var collapseHorizontally: Bool { frameInScopeContent.width <= fontSize + (2 * Self.padding) }
    
    var collapseVertically: Bool { frameInScopeContent.height <= fontSize + (2 * Self.padding) }
    
    var fontSize: Double
    {
        1.2 * sqrt(sqrt(frameInScopeContent.height * frameInScopeContent.width))
    }
    
    static var padding: Double = 16
    static var minWidth: Double = 30
    static var minHeight: Double = 30
    
    var frameInScopeContent = LayoutFrame.zero
    
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
}
