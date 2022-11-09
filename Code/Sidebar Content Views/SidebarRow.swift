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
                        VStack
                        {
                            Label("Empty " + artifactVM.codeArtifact.kindName, systemImage: "xmark.rectangle")
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
                                LSPServiceHint()
                            }
                        }
                        .padding(50)
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
            // FIXME: try to fix this with the new SwiftUI on Ventura: having a "2nd" toolbar here can lead to a crash: size window smaller so that sidebar disappears automatically, size window bigger so that sidebar reappears, select some higher-level artifact
//            .toolbar {
//                ToolbarItemGroup(placement: .automatic) {
//                    if let searchTerm = viewModel.appliedSearchTerm, !searchTerm.isEmpty
//                    {
//                        FilterRemovalButton(processorVM: viewModel)
//                    }
//
//                    // DisplayModePicker(displayMode: $viewModel.displayMode)
//                }
//            }
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

struct FilterRemovalButton: View
{
    var body: some View
    {
        Button {
            withAnimation(.easeInOut(duration: 1.5))
            {
                processorVM.removeSearchFilter()
            }
        } label: {
            HStack
            {
                Text("Search Filter:")
                Text(processorVM.appliedSearchTerm ?? "")
                    .foregroundColor(.accentColor)
                Image(systemName: "xmark")
            }
        }
    }
    
    @ObservedObject var processorVM: ProjectProcessorViewModel
}
