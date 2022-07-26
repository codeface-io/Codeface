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
                    .frame(width: artifact.presentationModel.collapseHorizontally ? 0 : nil)
                    .opacity(artifact.presentationModel.showsName ? 1 : 0)
                    .foregroundColor((artifact.containsSearchTermRegardlessOfParts ?? false) ? .accentColor : .primary)
                
                if !artifact.presentationModel.collapseHorizontally
                {
                    Spacer()
                }
            }
            .font(.system(size: artifact.presentationModel.fontSize,
                          weight: .medium,
                          design: .for(artifact)))
            .frame(width: artifact.presentationModel.frameInScopeContent.width - 2 * CodeArtifactPresentationModel.padding,
                   height: artifact.presentationModel.collapseVertically ? artifact.presentationModel.frameInScopeContent.height - 2 * CodeArtifactPresentationModel.padding : artifact.presentationModel.fontSize)
            .position(x: artifact.presentationModel.frameInScopeContent.width / 2,
                      y: artifact.presentationModel.collapseVertically ? artifact.presentationModel.frameInScopeContent.height / 2 : CodeArtifactPresentationModel.padding + artifact.presentationModel.fontSize / 2)
            
            ArtifactContentView(artifact: artifact,
                                viewModel: viewModel,
                                ignoreSearchFilter: ignoreSearchFilter)
            .frame(width: artifact.presentationModel.contentFrame.width,
                   height: artifact.presentationModel.contentFrame.height)
            .position(x: artifact.presentationModel.contentFrame.centerX,
                      y: artifact.presentationModel.contentFrame.centerY)
            .opacity(artifact.presentationModel.showsContent ? 1.0 : 0)
            
        }
        .frame(width: artifact.presentationModel.frameInScopeContent.width,
               height: artifact.presentationModel.frameInScopeContent.height)
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
        .position(x: artifact.presentationModel.frameInScopeContent.centerX,
                  y: artifact.presentationModel.frameInScopeContent.centerY)
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
