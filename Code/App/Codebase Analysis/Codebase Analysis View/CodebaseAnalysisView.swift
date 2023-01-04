import SwiftUI

struct CodebaseAnalysisView: View
{
    var body: some View
    {
        DoubleSidebarView(showLeftSidebar: $processor.showsLeftSidebar,
                          showRightSidebar: $processor.showsRightSidebar)
        {
            if let artifactVM = processor.selectedArtifact
            {
                CodebaseCentralView(artifactVM: artifactVM,
                                    processorVM: processor)
            }
            else
            {
                VStack
                {
                    Spacer()
                    
                    Label("Nothing Selected", systemImage: "xmark.rectangle")
                        .font(.title)
                    
                    Text("Select a code artifact in the navigator on the left.")
                        .font(.title3)
                        .padding(.top)
                    
                    Spacer()
                }
                .foregroundColor(.secondary)
                .padding()
            }
        }
        leftSidebar:
        {
            CodebaseNavigatorView(rootArtifact: rootArtifact,
                                  selectedArtifact: $processor.selectedArtifact,
                                  showsLinesOfCode: $processor.showLoC)
        }
        rightSidebar:
        {
            CodebaseInspectorView(processor: processor)
        }
    }
    
    let rootArtifact: ArtifactViewModel

    @ObservedObject var processor: CodebaseProcessor
}
