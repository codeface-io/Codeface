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
                .frame(maxWidth: artifactVM.shouldCollapseHorizontally ? 0 : .infinity,
                       alignment: .leading)
                .font(.system(size: fontSize,
                              weight: .medium,
                              design: artifactVM.fontDesign))
                .foregroundColor(.primary)
                .drawingGroup() // so the opacity animation works and the text does not just plop in ...
                .opacity(artifactVM.shouldShowName ? 1 : 0)
                .padding(.leading,
                         artifactVM.shouldCollapseHorizontally ? 0 : artifactVM.fontSize / 3)
        }
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
