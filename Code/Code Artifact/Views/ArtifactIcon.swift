import SwiftUI
import SwiftLSP

struct ArtifactIcon: View
{
    var body: some View
    {
        Image(systemName: iconSystemImageName(for: artifact))
            .foregroundColor(isSelected ? .primary : .icon(for: artifact))
    }
    
    let artifact: ArtifactViewModel
    let isSelected: Bool
}

private extension Color
{
    static func icon(for artifactKind: ArtifactViewModel) -> Color
    {
        // TODO: reproduce coloring symbol by kind
        return .white
//        switch artifactKind
//        {
//        case .folder: return Color(NSColor.secondaryLabelColor)
//        case .file: return .white
//        case .symbol(let symbol): return .icon(for: symbol.kind)
//        }
    }
    
    static func icon(for symbolKind: LSPDocumentSymbol.SymbolKind?) -> Color
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
}

func iconSystemImageName(for artifactKind: ArtifactViewModel) -> String
{
    // TODO: reproduce symbol selection by kind
    return "doc.fill"
//    switch artifactKind
//    {
//    case .folder: return "folder.fill"
//    case .file: return "doc.fill"
//    case .symbol(let symbol): return iconSystemImageName(for: symbol.kind)
//    }
}

private func iconSystemImageName(for symbolKind: LSPDocumentSymbol.SymbolKind?) -> String
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
