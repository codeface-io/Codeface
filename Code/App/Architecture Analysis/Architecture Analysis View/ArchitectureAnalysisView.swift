import SwiftUI

struct ArchitectureAnalysisView: View
{
    var body: some View
    {
        DoubleSidebarView(showLeftSidebar: $analysis.showsLeftSidebar,
                          showRightSidebar: $analysis.showsRightSidebar)
        {
            CodebaseCentralView(analysis: analysis)
        }
        leftSidebar:
        {
            CodebaseNavigatorView(analysis: analysis,
                                  showsLinesOfCode: $analysis.showLoC)
        }
        rightSidebar:
        {
            CodebaseInspectorView(selectedArtifact: analysis.selectedArtifact)
        }
    }
    
    @ObservedObject var analysis: ArchitectureAnalysis
}
