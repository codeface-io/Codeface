import SwiftUI
import SwiftyToolz
import LSPServiceKit
import SwiftLSP
import CodefaceCore

struct SidebarRow: View
{
    var body: some View
    {
        NavigationLink(tag: artifactVM, selection: $selectedArtifact)
        {
            Group
            {
                if artifactVM.filteredParts.isEmpty
                {
                    let contentIsFilteredOut = !artifactVM.passesSearchFilter || !artifactVM.parts.isEmpty

                    if contentIsFilteredOut
                    {
                        VStack(alignment: .center)
                        {
                            Label("No Search Results", systemImage: "xmark.rectangle")
                                .foregroundColor(.secondary)
                                .font(.system(.title))
                                .padding(.bottom)

                            Text(artifactVM.codeArtifact.name + " does not contain the term \"\(viewModel.appliedSearchTerm ?? "")\"")
                                .foregroundColor(.secondary)
                                .padding(.bottom)
                            
                            Button("Remove Search Filter", role: .destructive)
                            {
                                viewModel.removeSearchFilter()
                            }
                        }
                        .padding()
                    }
                    else if case .symbol = artifactVM.kind
                    {
                        CodeView(artifact: artifactVM)
                    }
                    else
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
                }
                else
                {
                    switch viewModel.displayMode
                    {
                    case .treeMap: TreeMap(rootArtifactVM: artifactVM, viewModel: viewModel)
                    case .code: CodeView(artifact: artifactVM)
                    }
                }
            }
            .toolbar
            {
                if !artifactVM.filteredParts.isEmpty
                {
                    DisplayModePicker(displayMode: $viewModel.displayMode)
                }
                
                if let searchTerm = viewModel.appliedSearchTerm,
                   !searchTerm.isEmpty
                {
                    Button
                    {
                        withAnimation(.easeInOut(duration: 1.5))
                        {
                            viewModel.removeSearchFilter()
                        }
                    } label:
                    {
                        HStack
                        {
                            Text("Search Filter:")
                            Text(searchTerm)
                                .foregroundColor(.accentColor)
                            Image(systemName: "xmark")
                        }
                    }
                }
            }
        } label:
        {
            SidebarLabel(artifact: artifactVM, isSelected: artifactVM === selectedArtifact)
        }
    }
    
    let artifactVM: ArtifactViewModel
    @ObservedObject var viewModel: ProjectProcessorViewModel
    @Binding var selectedArtifact: ArtifactViewModel?
    @ObservedObject private var serverManager = LSP.ServerManager.shared
}
