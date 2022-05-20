import SwiftUI
import SwiftLSP

struct ArtifactView: View
{
    var body: some View
    {
        VStack(alignment: .leading, spacing: 0)
        {
            HStack
            {
                ArtifactIcon(artifact: artifact, isSelected: false)
                
                if artifact.layoutModel.width > 90
                {
                    Text(artifact.name)
                        .lineLimit(1)
                        .foregroundColor(artifact.containsSearchTermRegardlessOfParts ?? false ? .accentColor : .primary)
                    Spacer()
                }
            }
            .font(.system(size: artifact.layoutModel.fontSize,
                          weight: .medium,
                          design: .for(artifact)))
            .padding(CodeArtifact.LayoutModel.padding)
            
            GeometryReader
            {
                contentSpaceGeometry in
                
                if contentSpaceGeometry.size.height >= CodeArtifact.LayoutModel.minHeight
                {
                    ArtifactContentView(artifact: artifact,
                                        ignoreSearchFilter: ignoreSearchFilter)
                        .padding([.leading, .trailing, .bottom],
                                 CodeArtifact.LayoutModel.padding)
                }
            }
        }
        .frame(width: artifact.layoutModel.width,
               height: artifact.layoutModel.height)
        .background(RoundedRectangle(cornerRadius: 5)
            .fill(Color.primary.opacity(0.1))
            .overlay(RoundedRectangle(cornerRadius: 5)
                .strokeBorder(isHovering ? Color.accentColor : Color.clear,
                              antialiased: true)))
        .onHover
        {
            if $0
            {
                isHovering = true
            }
            else
            {
                withAnimation(.easeInOut) { self.isHovering = false }
            }
        }
        .position(x: artifact.layoutModel.centerX,
                  y: artifact.layoutModel.centerY)
        .animation(.easeInOut(duration: 1), value: artifact.layoutModel)
    }
    
    @ObservedObject var artifact: CodeArtifact
    let ignoreSearchFilter: Bool
    @State var isHovering: Bool = false
}

extension Font.Design
{
    static func `for`(_ artifact: CodeArtifact) -> Font.Design
    {
        switch artifact.kind
        {
        case .symbol: return .monospaced
        default: return .default
        }
    }
}
