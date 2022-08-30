import SwiftUI
import LSPServiceKit
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
                    VStack(alignment: .center)
                    {
                        Label("Empty Scope", systemImage: "xmark.rectangle")
                            .foregroundColor(.secondary)
                            .font(.system(.title))
                            .padding(.bottom)
                        
                        if !selectedArtifactVM.parts.isEmpty
                        {
                            Text("No elements in " + selectedArtifactVM.codeArtifact.name + " contain the term \"\(viewModel.appliedSearchTerm ?? "")\"")
                                .foregroundColor(.secondary)
                                .padding(.bottom)
                            
                            Button("Remove Search Filter", role: .destructive)
                            {
                                viewModel.removeSearchFilter()
                            }
                        }
                        else if serverManager.serverIsWorking
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
                else
                {
                    switch viewModel.displayMode
                    {
                    case .treeMap: TreeMap(rootArtifactVM: selectedArtifactVM, viewModel: viewModel)
                    case .code: CodeView(artifact: selectedArtifactVM)
                    }
                }
            }
            .navigationTitle(selectedArtifactVM.codeArtifact.name)
            .navigationSubtitle(selectedArtifactVM.codeArtifact.kindName)
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
    @ObservedObject var viewModel: ProjectAnalysisViewModel
    @ObservedObject private var serverManager = LSPServerManager.shared
}
