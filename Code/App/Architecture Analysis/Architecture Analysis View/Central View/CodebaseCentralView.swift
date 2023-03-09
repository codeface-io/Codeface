import SwiftUI
import SwiftLSP

struct CodebaseCentralView: View
{
    var body: some View
    {
        VStack(spacing: 0)
        {
            TopPanel(analysis: analysis)
            
            if analysis.selectedArtifact.filteredParts.isEmpty
            {
                let contentIsFilteredOut = !analysis.selectedArtifact.passesSearchFilter || !analysis.selectedArtifact.parts.isEmpty
                
                if contentIsFilteredOut
                {
                    VStack
                    {
                        Spacer()
                        
                        Label("No Search Results", systemImage: "xmark.rectangle")
                            .foregroundColor(.secondary)
                            .font(.title)
                            .padding(.bottom)
                        
                        Text(analysis.selectedArtifact.codeArtifact.name + " does not contain \"\(analysis.search.term)\"")
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
                else if case .symbol = analysis.selectedArtifact.kind
                {
                    CodeView(artifact: analysis.selectedArtifact)
                }
                else
                {
                    VStack
                    {
                        Label("Empty " + analysis.selectedArtifact.codeArtifact.kindName, systemImage: "xmark.rectangle")
                            .foregroundColor(.secondary)
                            .font(.system(.title))
                            .padding(.bottom)
                        
                        if serverManager.serverIsWorking
                        {
                            Text(analysis.selectedArtifact.codeArtifact.name + " contains no further symbols.")
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
                switch analysis.displayMode
                {
                case .treeMap: TreeMap(analysis: analysis)
                case .code: CodeView(artifact: analysis.selectedArtifact)
                }
            }
            
            PurchasePanel()
        }
    }
    
    @ObservedObject var analysis: ArchitectureAnalysis
    
    @ObservedObject private var serverManager = LSP.ServerManager.shared
}
