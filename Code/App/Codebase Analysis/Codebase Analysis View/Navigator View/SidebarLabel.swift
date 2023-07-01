import SwiftUIToolzOLD
import SwiftUI

struct SidebarLabel: View
{
    var body: some View
    {
        Label
        {
            Text(compactDisplayName)
                .font(.system(.title3, design: artifactVM.fontDesign))
            
            if showsLinesOfCode, let linesOfCode = artifactVM.metrics.linesOfCode
            {
                Spacer()

                Text("\(linesOfCode)")
                    .foregroundColor(.init(artifactVM.linesOfCodeColor))
                    .monospacedDigit()
            }
        }
        icon:
        {
            ArtifactIconView(icon: artifactVM.icon, size: 14)
        }
    }
    
    private var compactDisplayName: String
    {
        switch artifactVM.kind
        {
        case .folder(let folderVM):
            let components = folderVM.name.components(separatedBy: "/")
            
            if components.count > 1, let firstComponent = components.first
            {
                return firstComponent + " …"
            }
            else
            {
                return artifactVM.displayName
            }
            
        default:
            return artifactVM.displayName
        }
    }
    
    @ObservedObject var artifactVM: ArtifactViewModel
    @Binding var showsLinesOfCode: Bool
}
