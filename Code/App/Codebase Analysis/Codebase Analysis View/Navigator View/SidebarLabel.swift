import SwiftUIToolzOLD
import SwiftUI

struct SidebarLabel: View
{
    var body: some View
    {
        Label
        {
            Text(artifact.codeArtifact.name)
                .font(.system(.title3, design: artifact.fontDesign))
            
            if showsLinesOfCode, let linesOfCode = artifact.metrics.linesOfCode
            {
                Spacer()

                Text("\(linesOfCode)")
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
    @Binding var showsLinesOfCode: Bool
}
