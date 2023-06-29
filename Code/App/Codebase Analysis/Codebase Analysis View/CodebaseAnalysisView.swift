import SwiftUI

struct CodebaseAnalysisView: View
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
    
    @ObservedObject var analysis: CodebaseAnalysis
    @ObservedObject var displayOptions: WindowDisplayOptions
}
