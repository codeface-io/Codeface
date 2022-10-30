import SwiftUIToolz
import SwiftUI
import CodefaceCore

struct SidebarLabel: View
{
    var body: some View
    {
        Label
        {
            Text(artifact.codeArtifact.name)
                .font(.system(.title3, design: artifact.fontDesign))
            
            if let loc = artifact.codeArtifact.linesOfCode
            {
                Spacer()
                
                Text("\(loc)")
                    .foregroundColor(isSelected ? .primary : .init(artifact.linesOfCodeColor))
                    .monospacedDigit()
            }
        }
        icon:
        {
            ArtifactIcon(artifact: artifact, isSelected: isSelected)
        }
    }
    
    @State var artifact: ArtifactViewModel
    let isSelected: Bool
}
