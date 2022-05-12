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
               artifact.preparePartsForLayout(inScopeOfSize: geo.size)
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
                        .frame(width: parts[index].layout.width,
                               height: parts[index].layout.height)
                        .background(Rectangle().fill(bgColor(for: artifact.kind)).cornerRadius(5)
                            .shadow(color: .black, radius: 10, x: 0, y: 5))
                        .position(x: parts[index].layout.centerX,
                                  y: parts[index].layout.centerY)
                    }
                }
                .frame(width: geo.size.width,
                       height: geo.size.height)
                .clipped()
                .animation(.easeInOut(duration: 1), value: geo.size)
                .drawingGroup()
            }
        }
    }
    
    @State var artifact: CodeArtifact
}

extension CodeArtifact
{
    @discardableResult
    func preparePartsForLayout(inScopeOfSize scopeSize: CGSize) -> Bool
    {
        guard let parts = parts, !parts.isEmpty else { return false }
        
        let availableSpacePerPart = Int(scopeSize.width * scopeSize.height) / parts.count
        
        guard availableSpacePerPart >= 5000 else { return false }
        
        prepare(parts: parts,
                forLayoutInRect: .init(x: 0,
                                       y: 0,
                                       width: scopeSize.width,
                                       height: scopeSize.height))
        
        return true
    }
    
    private func prepare(parts: [CodeArtifact],
                         forLayoutInRect availableRect: CGRect)
    {
        if parts.isEmpty { return }
        
        if parts.count == 1
        {
            let part = parts[0]
            
            part.layout = .init(width: availableRect.width,
                                height: availableRect.height,
                                centerX: availableRect.midX,
                                centerY: availableRect.midY)
            
            return
        }
        
        let lastIndexOfFirstHalf = (parts.count - 1) / 2
        
        let partsA = Array(parts[0 ... lastIndexOfFirstHalf])
        let partsB = Array(parts[lastIndexOfFirstHalf + 1 ..< parts.count])
        
        let (rectA, rectB) = split(availableRect,
                                   vertically: availableRect.width / availableRect.height > 3)
        
        prepare(parts: partsA, forLayoutInRect: rectA)
        prepare(parts: partsB, forLayoutInRect: rectB)
    }
    
    func split(_ rect: CGRect, vertically: Bool) -> (CGRect, CGRect)
    {
        if vertically
        {
            let rectA = CGRect(x: rect.minX,
                               y: rect.minY,
                               width: (rect.width / 2) - 10,
                               height: rect.height)
            
            let rectB = CGRect(x: (rect.minX + rect.width / 2) + 10,
                               y: rect.minY,
                               width: (rect.width / 2) - 10,
                               height: rect.height)
            
            return (rectA, rectB)
        }
        else
        {
            let rectA = CGRect(x: rect.minX,
                               y: rect.minY,
                               width: rect.width,
                               height: (rect.height / 2) - 10)
            
            let rectB = CGRect(x: rect.minX,
                               y: (rect.minY + rect.height / 2) + 10,
                               width: rect.width,
                               height: (rect.height / 2) - 10)
            
            return (rectA, rectB)
        }
    }
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
