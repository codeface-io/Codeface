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
                    
                    Spacer()
                    
//                    Button(action: { codefaceDocument.loadProcessorForLastCodebase() })
//                    {
//                        Image(systemName: "arrow.clockwise")
//                    }
//                    .disabled(!CodebaseLocationPersister.hasPersistedLastCodebaseLocation)
//                    .help("Import the last imported folder again")
                }
                    
                ToolbarItemGroup(placement: .navigation)
                {
                    if let searchTerm = processorVM.appliedSearchTerm, !searchTerm.isEmpty
                    {
                        FilterRemovalButton(processorVM: processorVM)
                    }
                }
            }
        }
    }
    
    @ObservedObject var codefaceDocument: CodefaceDocument
    @ObservedObject var processorVM: ProjectProcessorViewModel
}
