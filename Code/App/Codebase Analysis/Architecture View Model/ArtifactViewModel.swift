import SwiftLSP
import Foundation
import SwiftyToolz

@MainActor
class ArtifactViewModel: Identifiable, ObservableObject, Comparable
{
    // MARK: - Initialization
    
    init(folderArtifact: CodeFolderArtifact, isPackage: Bool) async
    {
        // create child presentations for parts recursively
        self.parts = await folderArtifact.partGraph.values.asyncMap
        {
            switch $0.kind
            {
            case .file(let file):
                return await .init(fileArtifact: file)
            case .subfolder(let subfolder):
                return await .init(folderArtifact: subfolder, isPackage: false)
            }
        }
        
        icon = isPackage ? .package : .folder
        
        linesOfCodeColor = .system(.gray)
        
        metrics = await folderArtifact.metrics
        
        kind = .folder(folderArtifact)
        
        for part in parts { part.scope = self }
        
        parts.sort()
    }
    
    private init(fileArtifact: CodeFileArtifact) async
    {
        // create child presentations for symbols recursively
        self.parts = await fileArtifact.symbolGraph.values.asyncMap
        {
            await ArtifactViewModel(symbolArtifact: $0)
        }
        
        icon = .forFile(named: fileArtifact.name)
            
        linesOfCodeColor = .system(systemColor(forLinesOfCode: await fileArtifact.linesOfCode))
        
        metrics = await fileArtifact.metrics
        
        kind = .file(fileArtifact)
        
        for part in parts { part.scope = self }
        
        parts.sort()
    }
    
    private init(symbolArtifact: CodeSymbolArtifact) async
    {
        // create child presentations for subsymbols recursively
        parts = await symbolArtifact.subsymbolGraph.values.asyncMap
        {
            await ArtifactViewModel(symbolArtifact: $0)
        }
        
        icon = .for(symbolKind: symbolArtifact.kind)
        
        linesOfCodeColor = .system(.gray)
        
        metrics = await symbolArtifact.metrics
        
        kind = .symbol(symbolArtifact)
        
        for part in parts { part.scope = self }
        
        parts.sort()
    }
    
    // MARK: - Comparability
    
    nonisolated static func < (lhs: ArtifactViewModel,
                               rhs: ArtifactViewModel) -> Bool
    {
        lhs.metrics.sortRank < rhs.metrics.sortRank
    }
    
    // MARK: - Geometry: Basics
    
    /// This is just remembered so that layout updates can be done from where the scope size might not be available. It is **not** used for caching or avoiding redundant layout updates.
    var lastLayoutScopeSize: Size? = nil
    
    @Published var frameInScopeContent = Rectangle.zero
    {
        didSet
        {
            updatePropertiesDerivedFromFrame()
        }
    }
    
    @Published var showsParts: Bool? = nil
    var contentFrame = Rectangle.zero
    @Published var gapBetweenParts: Double?
    
    // MARK: - Geometry: Properties Derived (Cached) From Frame
    
    private func updatePropertiesDerivedFromFrame()
    {
        let width = frameInScopeContent.width
        let height = frameInScopeContent.height
        
        fontSize = 3 * pow(frameInScopeContent.surface, (1 / 6.0))
        
        shouldCollapseHorizontally = width <= fontSize + (2 * Self.padding)
        shouldCollapseVertically = height <= fontSize + (2 * Self.padding)
        shouldShowName = width - (2 * Self.padding + fontSize) >= 3 * fontSize
        
        let extraTrailingLengthForTitles = shouldCollapseHorizontally ? 0 : 6.0
        
        let headerWidth = shouldCollapseHorizontally ? fontSize : ((width - (2 * Self.padding)) + extraTrailingLengthForTitles)
        
        headerFrame = .init(center: Point(width / 2 + (extraTrailingLengthForTitles / 2),
                                          shouldCollapseVertically ? height / 2 : Self.padding + fontSize / 2),
                            size: Size(headerWidth,
                                       shouldCollapseVertically ? height - 2 * Self.padding : fontSize))
    }
    
    var fontSize: Double = 0
    var shouldCollapseHorizontally = false
    var shouldCollapseVertically = false
    var shouldShowName = true
    
    var headerFrame = Rectangle.zero
    
    // MARK: - Geometry: Static Parameters
    
    static var padding: Double = 16
    static let minimumSize = Size(30, 30)
    
    // MARK: - Colors & Symbols
    
    @Published var isInFocus = false
    let icon: ArtifactIcon
    let linesOfCodeColor: UXColor
    
    // MARK: - Search
    
    @Published var passesSearchFilter = true
    
    var containsSearchTermRegardlessOfParts: Bool?
    var partsContainSearchTerm: Bool?
    
    // MARK: - Display Name
    
    var displayName: String
    {
        switch kind
        {
        case .folder(let folder):
            return folder.name.replacingOccurrences(of: "/", with: ".")
        default:
            return codeArtifact.name
        }
    }
    
    // MARK: - Basics
    
    let metrics: Metrics
    
    weak var scope: ArtifactViewModel?
    var parts: [ArtifactViewModel]
    var partDependencies = [DependencyVM]()
    
    nonisolated var id: String { codeArtifact.id }
    
    nonisolated var codeArtifact: any SearchableCodeArtifact
    {
        switch kind
        {
        case .file(let file): return file
        case .folder(let folder): return folder
        case .symbol(let symbol): return symbol
        }
    }
    
    let kind: Kind
    
    enum Kind
    {
        case folder(CodeFolderArtifact),
             file(CodeFileArtifact),
             symbol(CodeSymbolArtifact)
    }
}

class DependencyVM: ObservableObject, Identifiable
{
    internal init(sourcePart: ArtifactViewModel,
                  targetPart: ArtifactViewModel,
                  weight: Int) {
        self.sourcePart = sourcePart
        self.targetPart = targetPart
        self.weight = weight
    }
    
    let id = UUID()
    
    let sourcePart: ArtifactViewModel
    @Published var sourcePoint: Point = .zero
    
    let targetPart: ArtifactViewModel
    @Published var targetPoint: Point = .zero
    
    let weight: Int
}

private func systemColor(forLinesOfCode linesOfCode: Int) -> SystemColor
{
    if linesOfCode < 100 { return .green }
    else if linesOfCode < 200 { return .yellow }
    else if linesOfCode < 300 { return .orange }
    else { return .red }
}
