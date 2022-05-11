import SwiftUI
import SwiftLSP

struct ArtifactView: View
{
    var body: some View
    {
        GeometryReader
        {
            geo in
            
            if geo.size.height >= 30
            {
                VStack(alignment: .leading, spacing: 0)
                {
                    HStack
                    {
                        Image(systemName: systemImageName(for: artifact.kind))
                            .foregroundColor(iconColor(for: artifact.kind))
                        Text(artifact.displayName)
                    }
                    .padding()
                    
                    ArtifactContentView(artifact: artifact)
                }
                .frame(width: geo.size.width, height: geo.size.height, alignment: .leading)
                .clipped()
                .background(Rectangle().fill(bgColor(for: artifact.kind)).cornerRadius(5)
                    .shadow(color: .black, radius: 10, x: 0, y: 5))
            }
        }
    }
    
    @State var artifact: CodeArtifact
}

struct ArtifactContentView: View
{
    var body: some View
    {
        GeometryReader
        {
            geo in
            
            if geo.size.height >= 30, let parts = artifact.parts
            {
                VStack(alignment: .leading)
                {
                    ForEach(parts.indices, id: \.self)
                    {
                        index in
                        
                        ArtifactView(artifact: parts[index])
                    }
                }
                .padding([.leading, .trailing, .bottom])
            }
        }
    }
    
    @State var artifact: CodeArtifact
}

func bgColor(for artifactKind: CodeArtifact.Kind) -> Color
{
    switch artifactKind
    {
    case .folder: return .primary.opacity(0.1)
    case .file: return .primary.opacity(0.1)
    case .symbol: return .primary.opacity(0.1)
    }
}

func iconColor(for artifactKind: CodeArtifact.Kind) -> Color
{
    switch artifactKind
    {
    case .folder: return Color(NSColor.secondaryLabelColor)
    case .file: return .white
    case .symbol(let symbol): return iconColor(for: symbol)
    }
}

func iconColor(for symbol: LSPDocumentSymbol) -> Color
{
    guard let symbolKind = symbol.symbolKind else
    {
        return Color(NSColor.secondaryLabelColor)
    }
    
    switch symbolKind
    {
    case .File, .Module, .Package:
        return .white
    case .Class, .Interface, .Struct, .Enum:
        return Color(NSColor.systemPurple)
    case .Namespace:
        return Color(NSColor.systemOrange)
    case .Method, .Constructor, .Function:
        return Color(NSColor.systemBlue)
    case .Property, .Field, .EnumMember:
        return Color(NSColor.systemTeal)
    case .Variable, .Constant:
        return Color(NSColor.systemPink)
    case .String:
        return Color(NSColor.systemRed)
    case .Number, .Boolean, .Array, .Object, .Key, .Null, .Event, .Operator, .TypeParameter:
        return Color(NSColor.secondaryLabelColor)
    }
}

func systemImageName(for artifactKind: CodeArtifact.Kind) -> String
{
    switch artifactKind
    {
    case .folder: return "folder.fill"
    case .file: return "doc.fill"
    case .symbol(let symbol): return iconSystemImageName(for: symbol)
    }
}

func iconSystemImageName(for symbol: LSPDocumentSymbol) -> String
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
    case .Class, .Interface, .Struct, .Enum:
        return "t.square.fill"
    case .Namespace:
        return "x.square.fill"
    case .Method, .Constructor, .Function:
        return "f.square.fill"
    case .Property, .Field, .EnumMember:
        return "p.square.fill"
    case .Variable:
        return "v.square.fill"
    case .Constant:
        return "c.square.fill"
    case .String:
        return "s.square.fill"
    case .Number, .Boolean, .Array, .Object, .Key, .Null, .Event, .Operator, .TypeParameter:
        return "square.fill"
    }
}
