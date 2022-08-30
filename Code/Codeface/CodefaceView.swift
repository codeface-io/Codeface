import SwiftUIToolz
import SwiftUI
import AppKit
import CodefaceCore
import SwiftObserver
import SwiftLSP

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
                    
                    if ProjectDescriptionPersister.hasPersistedLastProject
                    {
                        Spacer()
                        
                        Button(action: { viewModel.loadLastActiveProject() })
                        {
                            Image(systemName: "arrow.clockwise")
                        }
                    }
                }
            }
            
            Text("") // dummy navigation content so view sizing works as expected
        }
    }
    
    @ObservedObject var viewModel: CodefaceViewModel
}
