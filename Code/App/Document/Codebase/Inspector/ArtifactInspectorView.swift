import SwiftUI
import CodefaceCore
import SwiftyToolz

struct ArtifactInspectorView: View
{
    var body: some View
    {
        List
        {
            Label
            {
                Text(artifactVM.codeArtifact.name)
            }
            icon:
            {
                Image(systemName: artifactVM.iconSystemImageName)
                    .foregroundColor(.init(artifactVM.iconFillColor))
            }
            .font(.title3)
            
            Text(artifactVM.codeArtifact.kindName)
                .foregroundColor(.secondary)
                .font(.title3)
            
            Divider()
            
            HStack {
                Label("Lines of code:",
                      systemImage: "text.alignleft")
                Spacer()
                Text("\(artifactVM.codeArtifact.linesOfCode)")
                    .foregroundColor(.init(artifactVM.linesOfCodeColor))
            }
            .font(.title3)
            
            Divider()
            
            HStack {
                Label("Is itself in cycles:",
                      systemImage: "exclamationmark.arrow.triangle.2.circlepath")
                Spacer()
                
                let isInCycle = artifactVM.codeArtifact.metrics.isInACycle ?? false
                
                let cycleColor: SwiftyToolz.Color = isInCycle ? .rgb(1, 0, 0) : .rgb(0, 1, 0)
                
                Text("\(isInCycle ? "Yes" : "No")")
                    .foregroundColor(SwiftUI.Color(cycleColor))
            }
            .font(.title3)
            
            HStack
            {
                Label("Parts in cycles:",
                      systemImage: "arrow.3.trianglepath")
                
                Spacer()
                
                let cyclicPortion = artifactVM.codeArtifact.metrics.portionOfPartsInCycles
                
                let cycleColor = Color.rgb(0, 1, 0)
                    .mixed(with: cyclicPortion, of: .rgb(1, 0, 0))
                
                Text("\(Int(cyclicPortion * 100))%")
                    .foregroundColor(SwiftUI.Color(cycleColor))
            }
            .font(.title3)
        }
        .scrollContentBackground(.hidden)
        .background(Color(white: colorScheme == .dark ? 0.1568 : 0.9647))
    }
    
    let artifactVM: ArtifactViewModel
    
    @Environment(\.colorScheme) private var colorScheme
}
