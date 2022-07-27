import SwiftUI
import SwiftLSP

struct ArtifactIcon: View
{
    var body: some View
    {
        Image(systemName: artifact.iconSystemImageName)
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
