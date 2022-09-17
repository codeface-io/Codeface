import SwiftUIToolz
import SwiftUI
import CodefaceCore

struct CodefaceView: View
{
    var body: some View
    {
        NavigationView
        {
            CodefaceSidebar(viewModel: viewModel)
                .toolbar
            {
                ToolbarItemGroup(placement: .primaryAction)
                {
                    Button(action: toggleSidebar)
                    {
                        Image(systemName: "sidebar.leading")
                    }
                    
                    if CodebaseLocationPersister.hasPersistedLastCodebaseLocation
                    {
                        Spacer()
                        
                        Button(action: { viewModel.loadProcessorForLastCodebase() })
                        {
                            Image(systemName: "arrow.clockwise")
                        }
                    }
                }
            }
            
            // dummy navigation content so view sizing works as expected
            if viewModel.projectProcessorVM != nil
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
    
    @ObservedObject var viewModel: Codeface
}
