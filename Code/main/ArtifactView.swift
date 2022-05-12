import SwiftUI
import SwiftLSP

struct ArtifactViewPreview: PreviewProvider
{
    static var previews: some View
    {
        ArtifactView(artifact: .dummy)
            .previewDisplayName("ArtifactView")
    }
}

extension CodeArtifact {
    static var dummy: CodeArtifact {
        .init(displayName: "Root Folder", kind: .folder(.dummy), parts: [
            CodeArtifact(displayName: "Subfolder 1", kind: .folder(.dummy)),
            CodeArtifact(displayName: "Subfolder 2", kind: .folder(.dummy), parts: [
                CodeArtifact(displayName: "Subfolder 5", kind: .folder(.dummy)),
                CodeArtifact(displayName: "Subfolder 6", kind: .folder(.dummy)),
                CodeArtifact(displayName: "File 1", kind: .file(.dummy)),
                CodeArtifact(displayName: "File 2", kind: .file(.dummy))
            ]),
            CodeArtifact(displayName: "Subfolder 3", kind: .folder(.dummy)),
            CodeArtifact(displayName: "Subfolder 4", kind: .folder(.dummy))
        ])
    }
}

struct ArtifactView: View
{
    var body: some View
    {
        GeometryReader
        {
            geo in
            
            if let parts = artifact.parts,
               !parts.isEmpty,
               viewSize(available: geo.size.height,
                        numberOfViews: parts.count,
                        spacing: 20) >= 20
            {
                ZStack
                {
                    ForEach(0 ... parts.count - 1, id: \.self) { index in
                        VStack(alignment: .leading, spacing: 0)
                        {
                            HStack
                            {
                                Image(systemName: systemImageName(for: parts[index].kind))
                                    .foregroundColor(iconColor(for: parts[index].kind))
                                Text(parts[index].displayName)
                                Spacer()
                            }
                            .padding()
                            
                            GeometryReader
                            {
                                contentSpaceGeometry in
                                
                                if contentSpaceGeometry.size.height >= 20
                                {
                                    ArtifactView(artifact: parts[index])
                                        .padding([.leading, .trailing, .bottom])
                                }
                            }
                        }
                        .frame(width: geo.size.width,
                               height: viewSize(available: geo.size.height,
                                                numberOfViews: parts.count,
                                                spacing: 20))
                        .background(Rectangle().fill(bgColor(for: artifact.kind)).cornerRadius(5)
                            .shadow(color: .black, radius: 10, x: 0, y: 5))
                        .position(x: geo.size.width / 2,
                                  y: viewCenter(ofView: index,
                                                available: geo.size.height,
                                                numberOfViews: parts.count,
                                                spacing: 20))
                    }
                }
                .frame(width: geo.size.width,
                       height: geo.size.height)
                .clipped()
                .drawingGroup()
            }
        }
    }
    
    func viewCenter(ofView index: Int, available: Double, numberOfViews: Int, spacing: Double) -> Double
    {
        let size = viewSize(available: available, numberOfViews: numberOfViews, spacing: spacing)
        return (Double(index) * spacing) + (Double(index) * size) + (size / 2)
    }
    
    func viewSize(available: Double, numberOfViews: Int, spacing: Double) -> Double
    {
        (available - (Double(numberOfViews - 1) * spacing)) / Double(numberOfViews)
    }
    
    @State var artifact: CodeArtifact
}

/// how to draw an arrow: https://stackoverflow.com/questions/48625763/how-to-draw-a-directional-arrow-head
extension Line
{
    var animatableData: AnimatablePair<CGPoint.AnimatableData, CGPoint.AnimatableData>
    {
        get { AnimatablePair(start.animatableData, end.animatableData) }
        set { (start.animatableData, end.animatableData) = (newValue.first, newValue.second) }
    }
}

struct Line: Shape
{
    func path(in rect: CGRect) -> Path
    {
        Path
        {
            p in
            
            p.move(to: start)
            p.addLine(to: end)
        }
    }
    
    var start, end: CGPoint
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
