import SwiftUI
import SwiftLSP

struct ArtifactView: View
{
    var body: some View
    {
        ZStack
        {
            let extraSpaceForTitles = artifactVM.collapseHorizontally ? 0 : 10.0
            
            HStack(alignment: .firstTextBaseline, spacing: 0)
            {
                ArtifactIcon(artifact: artifactVM, isSelected: false)
                
                if !artifactVM.collapseHorizontally
                {
                    Text(artifactVM.codeArtifact.name)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .opacity(artifactVM.showsName ? 1 : 0)
                        .foregroundColor((artifactVM.containsSearchTermRegardlessOfParts ?? false) ? .accentColor : .primary)
                        .padding(.leading, artifactVM.fontSize / 7)
                }
            }
            .font(.system(size: artifactVM.fontSize,
                          weight: .medium,
                          design: artifactVM.fontDesign))
            .frame(width: artifactVM.frameInScopeContent.width - 2 * ArtifactViewModel.padding + extraSpaceForTitles,
                   height: artifactVM.collapseVertically ? artifactVM.frameInScopeContent.height - 2 * ArtifactViewModel.padding : artifactVM.fontSize)
            .position(x: artifactVM.frameInScopeContent.width / 2 + (extraSpaceForTitles / 2),
                      y: artifactVM.collapseVertically ? artifactVM.frameInScopeContent.height / 2 : ArtifactViewModel.padding + artifactVM.fontSize / 2)
            
            
            ArtifactContentView(artifactVM: artifactVM,
                                codeface: viewModel,
                                ignoreSearchFilter: ignoreSearchFilter,
                                bgBrightness: bgBrightness)
            .frame(width: artifactVM.contentFrame.width,
                   height: artifactVM.contentFrame.height)
            .position(x: artifactVM.contentFrame.centerX,
                      y: artifactVM.contentFrame.centerY)
            .opacity(artifactVM.showsContent ? 1.0 : 0)
            
        }
        .frame(width: artifactVM.frameInScopeContent.width,
               height: artifactVM.frameInScopeContent.height)
        .background(RoundedRectangle(cornerRadius: 5)
            .fill(Color(white: bgBrightness))
            .overlay(RoundedRectangle(cornerRadius: 5)
                .strokeBorder(isHovering ? Color.accentColor : .primary.opacity(0.25),
                              antialiased: true)))
        .onHover
        {
            if $0
            {
                isHovering = true
                artifactVM.isInFocus = true
                viewModel.statusBarText = "\(artifactVM.codeArtifact.name) component: #\(artifactVM.codeArtifact.metrics.componentNumber ?? -1)  ancestors: \(artifactVM.codeArtifact.metrics.numberOfAllIncomingDependenciesInScope ?? -1) incoming: \(artifactVM.incomingDependencies.count)"
            }
            else
            {
                withAnimation(.easeInOut)
                {
                    self.isHovering = false
                    artifactVM.isInFocus = false
                    viewModel.statusBarText = ""
                }
            }
        }
        .position(x: artifactVM.frameInScopeContent.centerX,
                  y: artifactVM.frameInScopeContent.centerY)
    }
    
    @ObservedObject var artifactVM: ArtifactViewModel
    let viewModel: Codeface
    let ignoreSearchFilter: Bool
    @State var isHovering: Bool = false
    let bgBrightness: Double
}
