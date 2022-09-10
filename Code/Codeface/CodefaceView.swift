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
                    
                    if ProjectLocationPersister.hasPersistedLastProjectLocation
                    {
                        Spacer()
                        
                        Button(action: { viewModel.loadLastProject() })
                        {
                            Image(systemName: "arrow.clockwise")
                        }
                    }
                }
            }
            
            // dummy navigation content so view sizing works as expected
            if let analysisVM = viewModel.projectProcessorVM
            {
                DummyNavigationContent(analysisVM: analysisVM)
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

private struct DummyNavigationContent: View
{
    var body: some View
    {
        switch analysisVM.analysisState
        {
        case .running:
            ProgressView()
                .progressViewStyle(.circular)
        case .succeeded(let rootFolderVM):
            Text("← Select some code artifact in " + rootFolderVM.codeArtifact.name)
                .multilineTextAlignment(.center)
                .font(.title)
                .foregroundColor(.secondary)
                .padding()
        default:
            Text("")
        }
    }
    
    @ObservedObject var analysisVM: ProjectProcessorViewModel
}
