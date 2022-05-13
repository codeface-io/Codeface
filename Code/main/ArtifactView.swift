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
                                    .lineLimit(1)
                                    .font(.system(parts[index].isSymbol ? .body : .title3,
                                                  design: .for(parts[index])))
                                Spacer()
                            }
                            .padding(CodeArtifact.Layout.padding)
                            
                            GeometryReader
                            {
                                contentSpaceGeometry in
                                
                                if contentSpaceGeometry.size.height >= CodeArtifact.Layout.minHeight
                                {
                                    ArtifactView(artifact: parts[index])
                                        .padding([.leading, .trailing, .bottom],
                                                 CodeArtifact.Layout.padding)
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
                .animation(.easeInOut(duration: 1), value: geo.size)
                .drawingGroup()
            }
        }
    }
    
    @State var artifact: CodeArtifact
}

extension CodeArtifact.Layout
{
    static var padding: Double = 16
    static var minWidth: Double = 100
    static var minHeight: Double = 30
}

extension CodeArtifact
{
    @discardableResult
    func preparePartsForLayout(inScopeOfSize scopeSize: CGSize) -> Bool
    {
        guard let parts = parts, !parts.isEmpty else { return false }
        
        let availableSpacePerPart = Int(scopeSize.width * scopeSize.height) / parts.count
        
        guard availableSpacePerPart >= 5000 else { return false }
        
        return prepare(parts: parts,
                       forLayoutIn: .init(x: 0,
                                          y: 0,
                                          width: scopeSize.width,
                                          height: scopeSize.height))
    }
    
    private func prepare(parts: [CodeArtifact],
                         forLayoutIn availableRect: CGRect) -> Bool
    {
        if parts.isEmpty { return false }
        
        if parts.count == 1
        {
            guard availableRect.width >= CodeArtifact.Layout.minWidth,
                  availableRect.height >= CodeArtifact.Layout.minHeight else { return false }
            
            let part = parts[0]
            
            part.layout = .init(width: availableRect.width,
                                height: availableRect.height,
                                centerX: availableRect.midX,
                                centerY: availableRect.midY)
            
            return true
        }
        
        let (partsA, partsB) = split(parts)
        
        let locA = partsA.reduce(0) { $0 + ($1.metrics?.linesOfCode ?? 0) }
        let locB = partsB.reduce(0) { $0 + ($1.metrics?.linesOfCode ?? 0) }
        
        let fractionOfA = Double(locA) / Double(locA + locB)
        
        guard let (rectA, rectB) = split(availableRect,
                                         firstFraction: fractionOfA) else { return false }
        
        return prepare(parts: partsA, forLayoutIn: rectA)
            && prepare(parts: partsB, forLayoutIn: rectB)
    }
    
    func split(_ parts: [CodeArtifact]) -> ([CodeArtifact], [CodeArtifact])
    {
        let halfTotalLOC = (parts.reduce(0) { $0 + ($1.metrics?.linesOfCode ?? 0) }) / 2
        
        var sumOfLOC = 0
        var minDifferenceToHalfTotalLOC = Int.max
        var optimalEndIndexForPartsA = 0
        
        for index in 0 ..< parts.count
        {
            let part = parts[index]
            sumOfLOC += part.metrics?.linesOfCode ?? 0
            let differenceToHalfTotalLOC = abs(halfTotalLOC - sumOfLOC)
            if differenceToHalfTotalLOC < minDifferenceToHalfTotalLOC
            {
                minDifferenceToHalfTotalLOC = differenceToHalfTotalLOC
                optimalEndIndexForPartsA = index
            }
        }
        
        return (Array(parts[0 ... optimalEndIndexForPartsA]),
                Array(parts[optimalEndIndexForPartsA + 1 ..< parts.count]))
    }
    
    func split(_ rect: CGRect,
               firstFraction: Double) -> (CGRect, CGRect)?
    {
        if rect.width / rect.height > 2
        {
            if 2 * CodeArtifact.Layout.minWidth + CodeArtifact.Layout.padding > rect.width
            {
                return nil
            }
            
            var widthA = (rect.width - CodeArtifact.Layout.padding) * firstFraction
            var widthB = (rect.width - widthA) - CodeArtifact.Layout.padding
            
            if widthA < CodeArtifact.Layout.minWidth
            {
                widthA = CodeArtifact.Layout.minWidth
                widthB = (rect.width - CodeArtifact.Layout.minWidth) - CodeArtifact.Layout.padding
            }
            else if widthB < CodeArtifact.Layout.minWidth
            {
                widthB = CodeArtifact.Layout.minWidth
                widthA = (rect.width - CodeArtifact.Layout.minWidth) - CodeArtifact.Layout.padding
            }
            
            let rectA = CGRect(x: rect.minX,
                               y: rect.minY,
                               width: widthA,
                               height: rect.height)
            
            let rectB = CGRect(x: (rect.minX + widthA) + CodeArtifact.Layout.padding,
                               y: rect.minY,
                               width: widthB,
                               height: rect.height)
            
            return (rectA, rectB)
        }
        else
        {
            if 2 * CodeArtifact.Layout.minHeight + CodeArtifact.Layout.padding > rect.height
            {
                return nil
            }
            
            var heightA = (rect.height - CodeArtifact.Layout.padding) * firstFraction
            var heightB = (rect.height - heightA) - CodeArtifact.Layout.padding
            
            if heightA < CodeArtifact.Layout.minHeight
            {
                heightA = CodeArtifact.Layout.minHeight
                heightB = (rect.height - CodeArtifact.Layout.minHeight) - CodeArtifact.Layout.padding
            }
            else if heightB < CodeArtifact.Layout.minHeight
            {
                heightB = CodeArtifact.Layout.minHeight
                heightA = (rect.height - CodeArtifact.Layout.minHeight) - CodeArtifact.Layout.padding
            }
            
            let rectA = CGRect(x: rect.minX,
                               y: rect.minY,
                               width: rect.width,
                               height: heightA)
            
            let rectB = CGRect(x: rect.minX,
                               y: (rect.minY + heightA) + CodeArtifact.Layout.padding,
                               width: rect.width,
                               height: heightB)
            
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
