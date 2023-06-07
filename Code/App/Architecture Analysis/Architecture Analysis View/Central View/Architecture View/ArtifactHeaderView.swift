import SwiftUI

struct ArtifactHeaderView: View
{
    var body: some View
    {
        let fontSize = artifactVM.fontSize
        
        HStack(alignment: .center, spacing: 0)
        {
            ArtifactIconView(icon: artifactVM.icon,
                             size: fontSize)
            
            Text(artifactVM.displayName)
                .frame(maxWidth: .infinity, alignment: .leading)
                .opacity(artifactVM.shouldShowName ? 1 : 0)
                .foregroundColor(.primary)
                .padding(.leading,
                         artifactVM.shouldCollapseHorizontally ? 0 : artifactVM.fontSize / 7)
        }
        .font(.system(size: fontSize,
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
