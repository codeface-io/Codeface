import SwiftUI
import CodefaceCore

struct ArtifactHeaderView: View
{
    var body: some View
    {
        HStack(alignment: .firstTextBaseline, spacing: 0)
        {
            ArtifactIcon(artifact: artifactVM, isSelected: false)
            
            Text(artifactVM.displayName)
                .frame(maxWidth: .infinity, alignment: .leading)
                .opacity(artifactVM.calculateWhetherToShowName() ? 1 : 0)
                .foregroundColor(.primary)
                .padding(.leading,
                         artifactVM.calculateWhetherToCollapseHorizontally() ? 0 : artifactVM.calculateFontSize() / 7)
        }
        .font(.system(size: artifactVM.calculateFontSize(),
                      weight: .medium,
                      design: artifactVM.fontDesign))
    }
    
    @ObservedObject var artifactVM: ArtifactViewModel
}

private extension ArtifactViewModel
{
    var displayName: String
    {
        calculateWhetherToCollapseHorizontally() ? "" : codeArtifact.name
    }
}
