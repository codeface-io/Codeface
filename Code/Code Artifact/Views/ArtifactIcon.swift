import SwiftUI
import SwiftLSP

struct ArtifactIcon: View
{
    var body: some View
    {
        Image(systemName: iconSystemImageName(for: artifact.kind))
            .foregroundColor(isSelected ? .primary : .icon(for: artifact.kind))
    }
    
    let artifact: CodeArtifact
    let isSelected: Bool
}

private extension Color
{
    static func icon(for artifactKind: CodeArtifact.Kind) -> Color
    {
        switch artifactKind
        {
        case .folder: return Color(NSColor.secondaryLabelColor)
        case .file: return .white
        case .symbol(let symbol): return .icon(for: symbol.lspDocumentSymbol)
        }
    }
    
    static func icon(for symbol: LSPDocumentSymbol) -> Color
    {
        guard let symbolKind = symbol.symbolKind else
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
}

private func iconSystemImageName(for artifactKind: CodeArtifact.Kind) -> String
{
    switch artifactKind
    {
    case .folder: return "folder.fill"
    case .file: return "doc.fill"
    case .symbol(let symbol): return iconSystemImageName(for: symbol.lspDocumentSymbol)
    }
}

private func iconSystemImageName(for symbol: LSPDocumentSymbol) -> String
{
    guard let symbolKind = symbol.symbolKind else
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
