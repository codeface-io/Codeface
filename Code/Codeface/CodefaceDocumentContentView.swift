import SwiftUIToolz
import SwiftUI
import CodefaceCore

struct CodefaceDocumentContentView: View
{
    var body: some View
    {
        if codefaceDocument.projectProcessorVM != nil
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
                Text(" ")
            }
        }
        else
        {
            Text("To import a codebase from a folder, see the File menu.")
                .multilineTextAlignment(.center)
                .font(.title)
                .foregroundColor(.secondary)
                .padding()
        }
    }
    
    @ObservedObject var codefaceDocument: CodefaceDocument
}
