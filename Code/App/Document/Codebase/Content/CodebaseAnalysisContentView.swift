import SwiftUI
import CodefaceCore
import SwiftLSP

struct CodebaseAnalysisContentView: View
{
    var body: some View
    {
        VStack(spacing: 0)
        {
            CodebaseAnalysisContentPanel(processorVM: processorVM)
            
            if artifactVM.filteredParts.isEmpty
            {
                let contentIsFilteredOut = !artifactVM.passesSearchFilter || !artifactVM.parts.isEmpty
                
                if contentIsFilteredOut
                {
                    VStack(alignment: .center)
                    {
                        Spacer()
                        
                        Label("No Search Results", systemImage: "xmark.rectangle")
                            .foregroundColor(.secondary)
                            .font(.system(.title))
                            .padding(.bottom)
                        
                        Text(artifactVM.codeArtifact.name + " does not contain the search term")
                            .foregroundColor(.secondary)
                            .padding(.bottom)
                        
                        Button("Remove Search Filter", role: .destructive)
                        {
                            processorVM.clearSearchField()
                        }
                        
                        Spacer()
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
                switch processorVM.displayMode
                {
                case .treeMap: TreeMap(rootArtifactVM: artifactVM,
                                       viewModel: processorVM)
                case .code: CodeView(artifact: artifactVM)
                }
            }
        }
        .toolbar
        {
            ToolbarItemGroup(placement: ToolbarItemPlacement.secondaryAction)
            {
                Button {
                    withAnimation(.easeInOut(duration: SearchVM.visibilityToggleAnimationDuration)) {
                        processorVM.searchVM.searchBarIsShown.toggle()
                    }
                } label: {
                    Image(systemName: "magnifyingglass")
                }
                .help("Toggle the search bar")
                
                DisplayModePicker(displayMode: $processorVM.displayMode)
            }
        }
    }
    
    let artifactVM: ArtifactViewModel
    
    @ObservedObject var codefaceDocument: CodefaceDocument
    @ObservedObject var processorVM: ProjectProcessorViewModel
    
    @ObservedObject private var serverManager = LSP.ServerManager.shared
}

struct CodebaseAnalysisContentPanel: View
{
    var body: some View
    {
        VStack(spacing: 0)
        {
            PathBarView(overviewBar: processorVM.pathBar)
            SearchBarView(processorVM: processorVM)
        }
        .background(Color(NSColor.controlBackgroundColor))
    }
    
    @ObservedObject var processorVM: ProjectProcessorViewModel
}
