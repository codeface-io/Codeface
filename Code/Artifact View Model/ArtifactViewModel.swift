import CodefaceCore
import SwiftUI
import SwiftLSP
import Foundation

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
        iconFillColor = Color("folderBlue")
        fontDesign = .default
        linesOfCodeColor = Color(NSColor.systemGray)
        
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
            iconFillColor = Color(red: 251.0 / 255.0,
                                  green: 139.0 / 255.0,
                                  blue: 57.0 / 255.0)
        }
        else
        {
            iconSystemImageName = "doc.fill"
            iconFillColor = .white
        }
            
        fontDesign = .default
        linesOfCodeColor = locColorForFile(linesOfCode: fileArtifact.linesOfCode)
        
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
        fontDesign = .monospaced
        linesOfCodeColor = Color(NSColor.systemGray)
        
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
    let iconFillColor: Color
    let fontDesign: Font.Design
    let linesOfCodeColor: Color
    
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

private func symbolIconFillColor(for symbolKind: LSPDocumentSymbol.SymbolKind?) -> Color
{
    guard let symbolKind = symbolKind else
    {
        return Color(NSColor.secondaryLabelColor)
    }
    
    switch symbolKind
    {
    case .File, .Module, .Package:
        return .white
    case .Class, .Interface, .Struct:
        return Color(NSColor.systemPurple)
    case .Namespace, .Enum:
        return Color(NSColor.systemOrange)
    case .Method, .Constructor:
        return Color(NSColor.systemBlue)
    case .Property, .Field, .EnumMember:
        return Color(NSColor.systemTeal)
    case .Variable, .Constant, .Function, .Operator:
        return Color(NSColor.systemGreen)
    case .Number, .Boolean, .Array, .Object, .Key, .Null, .Event, .TypeParameter, .String:
        return Color(NSColor.secondaryLabelColor)
    }
}

private func locColorForFile(linesOfCode: Int) -> Color
{
    if linesOfCode < 100 { return Color(NSColor.systemGreen) }
    else if linesOfCode < 200 { return Color(NSColor.systemYellow) }
    else if linesOfCode < 300 { return Color(NSColor.systemOrange) }
    else { return Color(NSColor.systemRed) }
}
