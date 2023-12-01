import SwiftUI
import SwiftLSP

struct CodebaseContentView: View
{
    var body: some View {
        
        if selectedArtifact.partsPassingFilter.isEmpty
        {
            let contentIsFilteredOut = !selectedArtifact.passesSearchFilter || !selectedArtifact.parts.isEmpty
            
            if contentIsFilteredOut
            {
                VStack
                {
                    Spacer()
                    
                    Label("No Search Results", systemImage: "xmark.rectangle")
                        .foregroundColor(.secondary)
                        .font(.title)
                        .padding(.bottom)
                    
                    Text(selectedArtifact.codeArtifact.name + " does not contain \"\(analysis.search.term)\"")
                        .foregroundColor(.secondary)
                        .padding(.bottom)
                        .font(.title3)
                    
                    Button("Clear Search Filter", role: .destructive)
                    {
                        withAnimation(.easeInOut(duration: Search.layoutAnimationDuration))
                        {
                            analysis.set(searchTerm: "")
                        }
                    }
                    .focusable(false)
                    .font(.title3)
                    
                    Spacer()
                }
                .padding()
            }
            else if case .symbol = selectedArtifact.kind
            {
                CodeView(artifact: selectedArtifact)
            }
            else // no filters, just a leaf artifact that is not a symbol
            {
                switch analysis.displayMode
                {
                case .treeMap:
                    VStack
                    {
                        Spacer()
                        
                        Label("Empty " + selectedArtifact.codeArtifact.kindName,
                              systemImage: "xmark.rectangle")
                            .foregroundColor(.secondary)
                            .font(.system(.title))
                            .padding(.bottom)
                        
                        if serverManager.serverIsWorking
                        {
                            Text(selectedArtifact.codeArtifact.name + " contains no further symbols.")
                                .foregroundColor(.secondary)
                        }
                        else
                        {
                            LSPServiceHint()
                        }
                        
                        Spacer()
                    }
                    .padding(50)
                    
                case .code:
                    CodeView(artifact: selectedArtifact)
                }
            }
        }
        else
        {
            switch analysis.displayMode
            {
            case .treeMap:
                TreeMap(analysis: analysis)
            case .code:
                CodeView(artifact: selectedArtifact)
            }
        }
    }
    
    @ObservedObject var analysis: CodebaseAnalysis
    
    // we need the selectedArtifact explicitly (even though it is accessible via analysis) so we can directly observe the properties on the selectedArtifact
    @ObservedObject var selectedArtifact: ArtifactViewModel
    
    @ObservedObject private var serverManager = LSP.ServerManager.shared
}
