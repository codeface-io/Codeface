import SwiftUI

struct CodebaseAnalysisView: View
{
    var body: some View
    {
        DoubleSidebarView(showLeftSidebar: $documentWindow.showsLeftSidebar,
                          showRightSidebar: $documentWindow.showsRightSidebar)
        {
            Group
            {
                if let artifactVM = processor.selectedArtifact
                {
                    CodebaseAnalysisContentView(artifactVM: artifactVM,
                                                displayMode: $documentWindow.displayMode,
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
        }
        leftSidebar:
        {
            CodebaseNavigatorView(rootArtifact: rootArtifact,
                                  selectedArtifact: $processor.selectedArtifact,
                                  showsLinesOfCode: $processor.showLoC)
        }
        rightSidebar:
        {
            if let artifactVM = processor.selectedArtifact
            {
                ArtifactInspectorView(artifactVM: artifactVM)
            }
            else
            {
                Text("Select a code artifact in the Navigator.")
            }
        }
    }
    
    let rootArtifact: ArtifactViewModel
    
    @ObservedObject var documentWindow: DocumentWindow
    @ObservedObject var processor: CodebaseProcessor
}
