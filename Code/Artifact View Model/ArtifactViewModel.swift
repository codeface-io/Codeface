import CodefaceCore
import SwiftLSP
import Foundation
import SwiftyToolz

@MainActor
class ArtifactViewModel: Identifiable, ObservableObject, Equatable
{
    nonisolated static func == (lhs: ArtifactViewModel,
                                rhs: ArtifactViewModel) -> Bool
    {
        lhs === rhs
    }
    
    // MARK: - Initialization
    
    init(folderArtifact: CodeFolderArtifact)
    {
        // create child presentations for parts recursively
        self.parts = folderArtifact.parts.map
        {
            switch $0.kind
            {
            case .file(let file): return .init(fileArtifact: file)
            case .subfolder(let subfolder): return .init(folderArtifact: subfolder)
            }
        }
        
        iconSystemImageName = "folder.fill"
        iconFillColor = .dynamic(.bytes(19, 165, 235), .bytes(83, 168, 209))
        linesOfCodeColor = .system(.gray)
        
        kind = .folder(folderArtifact)
    }
    
    private init(fileArtifact: CodeFileArtifact)
    {
        // create child presentations for symbols recursively
        self.parts = fileArtifact.symbols.map
        {
            ArtifactViewModel(symbolArtifact: $0)
        }
        
        if fileArtifact.codeFile.name.hasSuffix(".swift")
        {
            iconSystemImageName = "swift"
            iconFillColor = .rgba(.bytes(251, 139, 57))
        }
        else
        {
            iconSystemImageName = "doc.fill"
            iconFillColor = .rgba(.white)
        }
            
        linesOfCodeColor = .system(systemColor(forLinesOfCode: fileArtifact.linesOfCode))
        
        kind = .file(fileArtifact)
    }
    
    private init(symbolArtifact: CodeSymbolArtifact)
    {
        // create child presentations for subsymbols recursively
        self.parts = symbolArtifact.subsymbols.map
        {
            ArtifactViewModel(symbolArtifact: $0)
        }
        
        self.iconSystemImageName = symbolIconSystemImageName(for: symbolArtifact.kind)
        self.iconFillColor = symbolIconFillColor(for: symbolArtifact.kind)
        linesOfCodeColor = .system(.gray)
        
        kind = .symbol(symbolArtifact)
    }
    
    // MARK: - Search
    
    @Published var passesSearchFilter = true
    
    var containsSearchTermRegardlessOfParts: Bool?
    var partsContainSearchTerm: Bool?
    
    // MARK: - UI
    
    var headerFrame: Frame
    {
        .init(centerX: frameInScopeContent.width / 2 + (extraSpaceForTitles / 2),
              centerY: collapseVertically ? frameInScopeContent.height / 2 : Self.padding + fontSize / 2,
              width: frameInScopeContent.width - 2 * Self.padding + extraSpaceForTitles,
              height: collapseVertically ? frameInScopeContent.height - 2 * Self.padding : fontSize)
    }
    
    var extraSpaceForTitles: Double { collapseHorizontally ? 0 : 6.0 }
    
    @Published var isInFocus = false
    
    var showsName: Bool
    {
        frameInScopeContent.width - (2 * Self.padding + fontSize) >= 3 * fontSize
    }
    
    var collapseHorizontally: Bool { frameInScopeContent.width <= fontSize + (2 * Self.padding) }
    
    var collapseVertically: Bool { frameInScopeContent.height <= fontSize + (2 * Self.padding) }
    
    var fontSize: Double
    {
        let viewSurface = frameInScopeContent.height * frameInScopeContent.width
        return 3 * pow(viewSurface, (1 / 6.0))
    }
    
    static var padding: Double = 16
    static var minWidth: Double = 30
    static var minHeight: Double = 30
    
    @Published var frameInScopeContent = Frame.zero
    
    var showsContent = true
    var contentFrame = Frame.zero
    
    let iconSystemImageName: String
    let iconFillColor: UXColor
    let linesOfCodeColor: UXColor
    
    // MARK: - Basics
    
    @Published var partDependencies = [Dependency]()
    let parts: [ArtifactViewModel]
    
    struct Dependency: Identifiable
    {
        let id = UUID()
        
        let sourcePart: ArtifactViewModel
        var sourcePoint: Point = .zero
        
        let targetPart: ArtifactViewModel
        var targetPoint: Point = .zero
        
        let weight: Int
    }
    
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

@MainActor
private func symbolIconSystemImageName(for symbolKind: LSPDocumentSymbol.SymbolKind?) -> String
{
    guard let symbolKind = symbolKind else
    {
        return "questionmark.square.fill"
    }
    
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
    guard let symbolKind = symbolKind else
    {
        return .system(.secondaryLabel)
    }
    
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
