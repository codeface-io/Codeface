import SwiftUI
import SwiftLSP

struct ArtifactView: View
{
    var body: some View
    {
        ZStack
        {
            HStack(alignment: .firstTextBaseline, spacing: 0)
            {
                ArtifactIcon(artifact: artifact, isSelected: false)
                
                Text(" " + artifact.name)
                    .frame(width: artifact.collapseHorizontally ? 0 : nil)
                    .opacity(artifact.showsName ? 1 : 0)
                    .foregroundColor((artifact.containsSearchTermRegardlessOfParts ?? false) ? .accentColor : .primary)
                
                if !artifact.collapseHorizontally
                {
                    Spacer()
                }
            }
            .font(.system(size: artifact.fontSize,
                          weight: .medium,
                          design: .for(artifact)))
            .frame(width: artifact.frameInScopeContent.width - 2 * CodeArtifact.padding,
                   height: artifact.collapseVertically ? artifact.frameInScopeContent.height - 2 * CodeArtifact.padding : artifact.fontSize)
            .position(x: artifact.frameInScopeContent.width / 2,
                      y: artifact.collapseVertically ? artifact.frameInScopeContent.height / 2 : CodeArtifact.padding + artifact.fontSize / 2)
            
            ArtifactContentView(artifact: artifact,
                                viewModel: viewModel,
                                ignoreSearchFilter: ignoreSearchFilter)
            .frame(width: artifact.contentFrame.width,
                   height: artifact.contentFrame.height)
            .position(x: artifact.contentFrame.centerX,
                      y: artifact.contentFrame.centerY)
            .opacity(artifact.showsContent ? 1.0 : 0)
            
        }
        .frame(width: artifact.frameInScopeContent.width,
               height: artifact.frameInScopeContent.height)
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
        .position(x: artifact.frameInScopeContent.centerX,
                  y: artifact.frameInScopeContent.centerY)
    }
    
    @ObservedObject var artifact: CodeArtifact
    let viewModel: Codeface
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
