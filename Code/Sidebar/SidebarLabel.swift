import SwiftUI

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
                    .foregroundColor(isSelected ? .primary : artifact.linesOfCodeColor)
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

