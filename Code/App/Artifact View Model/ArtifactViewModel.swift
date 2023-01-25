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
        
        if isPackage
        {
            iconSystemImageName = "shippingbox.fill"
            iconFillColor = .dynamic(.in(light: .bytes(167, 129, 79),
                                         darkness: .bytes(193, 156, 106)))
        }
        else
        {
            iconSystemImageName = "folder.fill"
            iconFillColor = .dynamic(.in(light: .bytes(19, 165, 235),
                                         darkness: .bytes(83, 168, 209)))
        }
        
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
        
        if fileArtifact.name.hasSuffix(".swift")
        {
            iconSystemImageName = "swift"
            iconFillColor = .rgba(.bytes(251, 139, 57))
        }
        else
        {
            iconSystemImageName = "doc.fill"
            iconFillColor = .rgba(.white)
        }
            
        linesOfCodeColor = .system(systemColor(forLinesOfCode: await fileArtifact.linesOfCode))
        
        metrics = await fileArtifact.metrics
        
        kind = .file(fileArtifact)
        
        for part in parts { part.scope = self }
        
        parts.sort()
    }
    
    private init(symbolArtifact: CodeSymbolArtifact) async
    {
        // create child presentations for subsymbols recursively
        self.parts = await symbolArtifact.subsymbolGraph.values.asyncMap
        {
            await ArtifactViewModel(symbolArtifact: $0)
        }
        
        self.iconSystemImageName = symbolIconSystemImageName(for: symbolArtifact.kind)
        self.iconFillColor = symbolIconFillColor(for: symbolArtifact.kind)
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
    
    var lastScopeContentSize: Size? = nil
    @Published var frameInScopeContent = Rectangle.zero
    {
        didSet
        {
            updatePropertiesDerivedFromFrame()
        }
    }
    
    @Published var showsContent = false
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
        
        let extraSpaceForTitles = shouldCollapseHorizontally ? 0 : 6.0
        headerFrame = .init(center: Point(width / 2 + (extraSpaceForTitles / 2),
                                          shouldCollapseVertically ? height / 2 : Self.padding + fontSize / 2),
                            size: Size(width - 2 * Self.padding + extraSpaceForTitles,
                                       shouldCollapseVertically ? height - 2 * Self.padding : fontSize))
    }
    
    var fontSize: Double = 0
    var shouldCollapseHorizontally = false
    var shouldCollapseVertically = false
    var shouldShowName = true
    
    var headerFrame = Rectangle.zero
    
    // MARK: - Geometry: Static Parameters
    
    static var padding: Double = 16
    static var minWidth: Double = 30
    static var minHeight: Double = 30
    
    // MARK: - Colors & Symbols
    
    @Published var isInFocus = false
    
    let iconSystemImageName: String
    let iconFillColor: UXColor
    let linesOfCodeColor: UXColor
    
    // MARK: - Search
    
    @Published var passesSearchFilter = true
    
    var containsSearchTermRegardlessOfParts: Bool?
    var partsContainSearchTerm: Bool?
    
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

private func symbolIconSystemImageName(for symbolKind: LSPDocumentSymbol.SymbolKind?) -> String
{
    guard let symbolKind else { return "questionmark.square.fill" }
    
    switch symbolKind
    {
    case .File:
        return "doc.fill"
    case .Module, .Package:
        return "shippingbox.fill"
    case .Null:
        return "square.fill"
    default:
        if let firstCharacter = symbolKind.name.first?.lowercased()
        {
            return firstCharacter + ".square.fill"
        }
        else
        {
            return "questionmark.square.fill"
        }
    }
}

private func symbolIconFillColor(for symbolKind: LSPDocumentSymbol.SymbolKind?) -> UXColor
{
    guard let symbolKind else { return .system(.secondaryLabel) }
    
    switch symbolKind
    {
    case .File, .Module, .Package:
        return .rgba(.white)
    case .Class, .Interface, .Struct:
        return .system(.purple)
    case .Namespace, .Enum:
        return .system(.orange)
    case .Method, .Constructor:
        return .system(.blue)
    case .Property, .Field, .EnumMember:
        return .system(.teal)
    case .Variable, .Constant, .Function, .Operator:
        return .system(.green)
    case .Number, .Boolean, .Array, .Object, .Key, .Null, .Event, .TypeParameter, .String:
        return .system(.secondaryLabel)
    }
}

private func systemColor(forLinesOfCode linesOfCode: Int) -> UXColor.System
{
    if linesOfCode < 100 { return .green }
    else if linesOfCode < 200 { return .yellow }
    else if linesOfCode < 300 { return .orange }
    else { return .red }
}
