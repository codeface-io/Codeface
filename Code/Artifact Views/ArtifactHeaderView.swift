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
                .opacity(artifactVM.showsName ? 1 : 0)
                .foregroundColor((artifactVM.containsSearchTermRegardlessOfParts ?? false) ? .accentColor : .primary)
                .padding(.leading,
                         artifactVM.collapseHorizontally ? 0 : artifactVM.fontSize / 7)
        }
        .font(.system(size: artifactVM.fontSize,
                      weight: .medium,
                      design: artifactVM.fontDesign))
    }
    
    @ObservedObject var artifactVM: ArtifactViewModel
}
