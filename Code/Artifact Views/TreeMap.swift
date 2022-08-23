import SwiftUI
import LSPServiceKit

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
                
                if serverManager.serverIsWorking
                {
                    Text(artifactVM.codeArtifact.name + " contains no further symbols.")
                        .foregroundColor(.secondary)
                }
                else
                {
                    Link("Use LSPService to see symbols and dependencies",
                         destination: lspServicePage)
                }
            }
            .padding()
        }
        else
        {
            VStack(spacing: 0)
            {
                PathBarView(overviewBar: viewModel.pathBar)
                
                RootArtifactContentView(artifact: artifactVM,
                                        codeface: viewModel)
                .padding(ArtifactViewModel.padding)
            }
            .background(Color(white: colorScheme == .dark ? 0 : 0.6))
        }
    }
     
    @ObservedObject private var serverManager = LSPServerManager.shared
    
    let artifactVM: ArtifactViewModel
    @ObservedObject var viewModel: Codeface
    @Environment(\.colorScheme) var colorScheme
}

let lspServicePage = URL(string: "https://www.flowtoolz.com/codeface/lspservice")!
