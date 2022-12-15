import SwiftUIToolzOLD
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
                    .foregroundColor(.init(artifact.linesOfCodeColor))
                    .monospacedDigit()
            }
        }
        icon:
        {
            Image(systemName: artifact.iconSystemImageName)
                .foregroundColor(.init(artifact.iconFillColor))
        }
    }
    
    @ObservedObject var artifact: ArtifactViewModel
}
