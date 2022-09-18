import SwiftUIToolz
import SwiftUI
import CodefaceCore

struct CodefaceDocumentContentView: View
{
    var body: some View
    {
        if let processorVM = codefaceDocument.projectProcessorVM
        {
            NavigationView
            {
                SidebarAnalysisContent(processorVM: processorVM)
                    .frame(minWidth: 250)
                    .toolbar {
                        ToolbarItemGroup(placement: .primaryAction)
                        {
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
                            }
                        }
                    }
                
                // dummy navigation content so view sizing works as expected
                Text(" ")
            }
        }
        else
        {
            Text("Import a codebase folder via the File menu.")
                .multilineTextAlignment(.center)
                .font(.title)
                .foregroundColor(.secondary)
                .padding()
        }
    }
    
    @ObservedObject var codefaceDocument: CodefaceDocument
}
