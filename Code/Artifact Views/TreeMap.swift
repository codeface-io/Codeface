import SwiftUI

struct TreeMap: View
{
    var body: some View
    {
        if artifactVM.parts.isEmpty
        {
            VStack(alignment: .center)
            {
                Label("Empty Scope", systemImage: "xmark.rectangle")
                    .foregroundColor(.secondary)
                    .font(.system(.title))
                    .padding(.bottom)
                
                Text(artifactVM.codeArtifact.name + " contains no further symbols.")
                    .foregroundColor(.secondary)
                
                if !lspServiceConnection.isWorking
                {
                    Link("Use LSPService to see symbols and dependencies",
                         destination: LSPServiceConnection.infoPageURL)
                }
            }
            .padding()
        }
        else
        {
            VStack(spacing: 0)
            {
                OverviewBarView(overviewBar: viewModel.overviewBar)
                
                RootArtifactContentView(artifact: artifactVM,
                                        codeface: viewModel)
                .padding(ArtifactViewModel.padding)
            }
            .background(Color(white: colorScheme == .dark ? 0 : 0.6))
        }
    }
     
    @ObservedObject private var lspServiceConnection = LSPServiceConnection.shared
    
    let artifactVM: ArtifactViewModel
    @ObservedObject var viewModel: Codeface
    @Environment(\.colorScheme) var colorScheme
}
