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
            
            if let projectAnalysis = viewModel.projectAnalysis
            {
                switch projectAnalysis.analysisState
                {
                case .failed, .stopped, .running:
                    EmptyView()
                case .succeeded(let rootArtifactPresentation):
                    Label("Select a code artifact from \(rootArtifactPresentation.codeArtifact.name)",
                          systemImage: "arrow.left")
                    .padding()
                    .font(.system(.title))
                    .foregroundColor(.secondary)
                }
            }
            else
            {
                EmptyView()
            }
        }
    }
    
    @ObservedObject var viewModel: CodefaceViewModel
}
