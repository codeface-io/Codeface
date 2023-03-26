import SwiftUI

struct ArchitectureAnalysisView: View
{
    var body: some View
    {
        DoubleSidebarView(showLeftSidebar: $displayOptions.showsLeftSidebar,
                          showRightSidebar: $displayOptions.showsRightSidebar)
        {
            CodebaseCentralView(analysis: analysis,
                                displayOptions: displayOptions)
        }
        leftSidebar:
        {
            CodebaseNavigatorView(analysis: analysis,
                                  showsLinesOfCode: $displayOptions.showsLinesOfCode)
        }
        rightSidebar:
        {
            CodebaseInspectorView(selectedArtifact: analysis.selectedArtifact)
        }
    }
    
    @ObservedObject var analysis: ArchitectureAnalysis
    @ObservedObject var displayOptions: DocumentWindowDisplayOptions
}
