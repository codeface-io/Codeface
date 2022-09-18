import SwiftUIToolz
import SwiftUI
import CodefaceCore

struct CodefaceDocumentContentView: View
{
    var body: some View
    {
        NavigationView
        {
            CodefaceSidebar(codefaceDocument: codefaceDocument)
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
            if codefaceDocument.projectProcessorVM != nil
            {
                ProgressView()
                    .progressViewStyle(.circular)
            }
            else
            {
                Text("To load a codebase, see the File menu.")
                    .multilineTextAlignment(.center)
                    .font(.title)
                    .foregroundColor(.secondary)
                    .padding()
            }
        }
    }
    
    @ObservedObject var codefaceDocument: CodefaceDocument
}
