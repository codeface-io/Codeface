import SwiftUI
import LSPServiceKit
import CodefaceCore

struct TreeMap: View
{
    var body: some View
    {
        if rootArtifactVM.filteredParts.isEmpty
        {
            VStack(alignment: .center)
            {
                Label("Empty Scope", systemImage: "xmark.rectangle")
                    .foregroundColor(.secondary)
                    .font(.system(.title))
                    .padding(.bottom)
                
                if !rootArtifactVM.parts.isEmpty
                {
                    Text("No elements in " + rootArtifactVM.codeArtifact.name + " contain the term \"\(viewModel.appliedSearchTerm ?? "")\"")
                        .foregroundColor(.secondary)
                        .padding(.bottom)
                    
                    Button("Remove Search Filter", role: .destructive)
                    {
                        viewModel.removeSearchFilter()
                    }
                }
                else if serverManager.serverIsWorking
                {
                    Text(rootArtifactVM.codeArtifact.name + " contains no further symbols.")
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
                
                RootArtifactContentView(artifact: rootArtifactVM,
                                        viewModel: viewModel)
                .padding(ArtifactViewModel.padding)
            }
            .background(Color(white: colorScheme == .dark ? 0 : 0.6))
        }
    }
     
    @ObservedObject private var serverManager = LSPServerManager.shared
    
    let rootArtifactVM: ArtifactViewModel
    @ObservedObject var viewModel: ProjectAnalysisViewModel
    @Environment(\.colorScheme) var colorScheme
}

let lspServicePage = URL(string: "https://www.codeface.io/lspservice")!
