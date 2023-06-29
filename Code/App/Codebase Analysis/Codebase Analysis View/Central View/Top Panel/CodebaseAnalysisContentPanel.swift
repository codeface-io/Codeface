import SwiftUI

struct TopBar: View
{
    var body: some View
    {
        VStack(spacing: 0)
        {
            PathBarView(overviewBar: analysis.pathBar)
            
            SearchBarView(analysis: analysis,
                          artifactName: analysis.selectedArtifact.codeArtifact.name)
            
            Divider()
        }
        .background(Color(NSColor.controlBackgroundColor))
    }
    
    @ObservedObject var analysis: CodebaseAnalysis
}
