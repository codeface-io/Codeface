import SwiftUI
import SwiftyToolz
import LSPServiceKit
import SwiftLSP
import CodefaceCore

struct SidebarRow: View
{
    var body: some View
    {
        NavigationLink(tag: selectedArtifactVM, selection: $viewModel.selectedArtifact)
        {
            Group
            {
                if selectedArtifactVM.filteredParts.isEmpty
                {
                    let contentIsFilteredOut = !selectedArtifactVM.passesSearchFilter || !selectedArtifactVM.parts.isEmpty
                    
                    if contentIsFilteredOut
                    {
                        VStack(alignment: .center)
                        {
                            Label("No Search Results", systemImage: "xmark.rectangle")
                                .foregroundColor(.secondary)
                                .font(.system(.title))
                                .padding(.bottom)
                            
                            Text(selectedArtifactVM.codeArtifact.name + " does not contain the term \"\(viewModel.appliedSearchTerm ?? "")\"")
                                .foregroundColor(.secondary)
                                .padding(.bottom)
                            
                            Button("Remove Search Filter", role: .destructive)
                            {
                                viewModel.removeSearchFilter()
                            }
                        }
                        .padding()
                    }
                    else if case .symbol = selectedArtifactVM.kind
                    {
                        CodeView(artifact: selectedArtifactVM)
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
                                Text(selectedArtifactVM.codeArtifact.name + " contains no further symbols.")
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
                    case .treeMap: TreeMap(rootArtifactVM: selectedArtifactVM,
                                           viewModel: viewModel)
                    case .code: CodeView(artifact: selectedArtifactVM)
                    }
                }
            }
            .toolbar
            {
                if !selectedArtifactVM.filteredParts.isEmpty
                {
                    DisplayModePicker(displayMode: $viewModel.displayMode)
                }
                
                if let searchTerm = viewModel.appliedSearchTerm,
                   !searchTerm.isEmpty
                {
                    Button
                    {
                        withAnimation(.easeInOut)
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
            SidebarLabel(artifact: selectedArtifactVM,
                         isSelected: selectedArtifactVM === viewModel.selectedArtifact)
        }
    }
    
    let selectedArtifactVM: ArtifactViewModel
    @ObservedObject var viewModel: ProjectProcessorViewModel
    @ObservedObject private var serverManager = LSP.ServerManager.shared
}
