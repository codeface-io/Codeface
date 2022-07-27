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
    
    init(folderArtifact: CodeFolderArtifact)
    {
        self.codeArtifact = folderArtifact
        
        // create child presentations for parts recursively
        self.children = folderArtifact.subfolders.map
        {
            ArtifactViewModel(folderArtifact: $0)
        }
        + folderArtifact.files.map
        {
            ArtifactViewModel(fileArtifact: $0)
        }
        
        iconSystemImageName = "folder.fill"
        iconFillColor = Color(NSColor.secondaryLabelColor)
    }
    
    private init(fileArtifact: CodeFileArtifact)
    {
        self.codeArtifact = fileArtifact
        
        // create child presentations for symbols recursively
        self.children = fileArtifact.symbols.map
        {
            ArtifactViewModel(symbolArtifact: $0)
        }
        
        iconSystemImageName = "doc.fill"
        iconFillColor = .white
    }
    
    private init(symbolArtifact: CodeSymbolArtifact)
    {
        self.codeArtifact = symbolArtifact
        
        // create child presentations for subsymbols recursively
        self.children = symbolArtifact.subSymbols.map
        {
            ArtifactViewModel(symbolArtifact: $0)
        }
        
        self.iconSystemImageName = symbolIconSystemImageName(for: symbolArtifact.codeSymbol.kind)
        self.iconFillColor = symbolIconFillColor(for: symbolArtifact.codeSymbol.kind)
    }
    
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
    
    let children: [ArtifactViewModel]?
    
    nonisolated var id: String { codeArtifact.id }
    
    let iconSystemImageName: String
    let iconFillColor: Color
    
    let codeArtifact: CodeArtifact
}

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
