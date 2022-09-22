import SwiftUIToolz
import SwiftUI
import CodefaceCore

struct ContentNavigationView: View
{
    var body: some View
    {
        NavigationView
        {
            SidebarAnalysisContent(processorVM: processorVM,
                                   selectedArtifact: $codefaceDocument.selectedArtifact)
            .frame(minWidth: 250)
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    Button(action: toggleSidebar)
                    {
                        Image(systemName: "sidebar.leading")
                    }
                    
                    if CodebaseLocationPersister.hasPersistedLastCodebaseLocation
                    {
                        Spacer()
                        
                        Button(action: { codefaceDocument.loadProcessorForLastCodebase() })
                        {
                            Image(systemName: "arrow.clockwise")
                        }
                        .help("Import the last imported folder again")
                    }
                }
            }
        }
    }
    
    @ObservedObject var codefaceDocument: CodefaceDocument
    @ObservedObject var processorVM: ProjectProcessorViewModel
}
