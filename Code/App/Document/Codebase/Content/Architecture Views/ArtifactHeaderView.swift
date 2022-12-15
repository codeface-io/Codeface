import SwiftUI
import CodefaceCore

struct ArtifactHeaderView: View
{
    var body: some View
    {
        HStack(alignment: .firstTextBaseline, spacing: 0)
        {
            Image(systemName: artifactVM.iconSystemImageName)
                .foregroundColor(.init(artifactVM.iconFillColor))
            
            Text(artifactVM.displayName)
                .frame(maxWidth: .infinity, alignment: .leading)
                .opacity(artifactVM.shouldShowName ? 1 : 0)
                .foregroundColor(.primary)
                .padding(.leading,
                         artifactVM.shouldCollapseHorizontally ? 0 : artifactVM.fontSize / 7)
        }
        .font(.system(size: artifactVM.fontSize,
                      weight: .medium,
                      design: artifactVM.fontDesign))
    }
    
    @ObservedObject var artifactVM: ArtifactViewModel
}

private extension ArtifactViewModel
{
    var displayName: String
    {
        shouldCollapseHorizontally ? "" : codeArtifact.name
    }
}
