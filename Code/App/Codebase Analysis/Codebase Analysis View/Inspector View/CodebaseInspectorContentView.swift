import SwiftUI
import SwiftyToolz

struct CodebaseInspectorContentView: View
{
    var body: some View
    {
        List
        {
            Label
            {
                Text("Identity")
            }
            icon:
            {
                Image(systemName: "info.circle")
            }
            .font(.title3)
            .foregroundColor(.secondary)
            
            LabeledContent("Name")
            {
                Label
                {
                    Text(selectedArtifact.codeArtifact.name)
                }
                icon:
                {
                    Image(systemName: selectedArtifact.iconSystemImageName)
                        .foregroundColor(.init(selectedArtifact.iconFillColor))
                }
            }
            
            LabeledContent("Type")
            {
                Text(selectedArtifact.codeArtifact.kindName)
            }

            Divider()
            
            Label
            {
                Text("Size")
            }
            icon:
            {
                Image(systemName: "arrow.up.and.down.text.horizontal")
            }
            .font(.title3)
            .foregroundColor(.secondary)
            
            LabeledContent("Lines of Code")
            {
                Text("\(selectedArtifact.codeArtifact.linesOfCode)")
                    .foregroundColor(.init(selectedArtifact.linesOfCodeColor))
            }
            
            Divider()
            
            Label
            {
                Text("Cycles")
            }
            icon:
            {
                Image(systemName: "arrow.3.trianglepath")
            }
            .font(.title3)
            .foregroundColor(.secondary)
            
            LabeledContent("Is Itself in Cycles")
            {
                let isInCycle = selectedArtifact.codeArtifact.metrics.isInACycle ?? false
                
                let cycleColor: SwiftyToolz.Color = isInCycle ? .rgb(1, 0, 0) : .rgb(0, 1, 0)
                
                Text("\(isInCycle ? "Yes" : "No")")
                    .foregroundColor(SwiftUI.Color(cycleColor))
            }
            
            LabeledContent("Cyclic Code in Parts")
            {
                let cyclicPortion = selectedArtifact.codeArtifact.metrics.portionOfPartsInCycles
                
                let cycleColor = Color.rgb(0, 1, 0)
                    .mixed(with: cyclicPortion, of: .rgb(1, 0, 0))
                
                Text("\(Int(cyclicPortion * 100))%")
                    .foregroundColor(SwiftUI.Color(cycleColor))
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color(white: colorScheme == .dark ? 0.1568 : 0.9647))
    }
    
    let selectedArtifact: ArtifactViewModel
    
    @Environment(\.colorScheme) private var colorScheme
}
