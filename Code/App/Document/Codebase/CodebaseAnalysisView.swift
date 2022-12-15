import SwiftUI
import CodefaceCore

struct CodebaseAnalysisView: View
{
    var body: some View
    {
        DoubleSidebarView(viewModel: sidebarViewModel)
        {
            Group
            {
                if let artifactVM = codefaceDocument.selectedArtifact
                {
                    CodebaseAnalysisContentView(artifactVM: artifactVM,
                                                codefaceDocument: codefaceDocument,
                                                processorVM: processorVM)
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
                                  codefaceDocument: codefaceDocument)
        }
        rightSidebar:
        {
            Group
            {
                if let artifactVM = codefaceDocument.selectedArtifact
                {
                    ArtifactInspectorView(artifactVM: artifactVM)
                }
                else
                {
                    Text("Select a code artifact in the Navigator.")
                }
            }
        }
    }
    
    let sidebarViewModel: DoubleSidebarViewModel
    let rootArtifact: ArtifactViewModel
    
    @ObservedObject var codefaceDocument: CodefaceDocument
    @ObservedObject var processorVM: ProjectProcessorViewModel
}
