import SwiftUI

struct SecondaryToolbarButtons: View
{
    var body: some View
    {
        if let analysis
        {
            ToolbarFilterIndicator(analysis: analysis)
        }
    }
    
    private var analysis: CodebaseAnalysis?
    {
        codebaseProcessor.state.analysis
    }
    
    @ObservedObject var codebaseProcessor: CodebaseProcessor
}

struct ToolbarFilterIndicator: View
{
    var body: some View
    {
        if !analysis.search.term.isEmpty
        {
            Button
            {
                withAnimation(.easeInOut(duration: Search.layoutAnimationDuration))
                {
                    analysis.set(searchTerm: "")
                }
            }
            label:
            {
                HStack
                {
                    Text("Search Filter:")
                    
                    Text(analysis.search.term)
                        .foregroundColor(.accentColor)
                    
                    Image(systemName: "xmark")
                        .imageScale(.medium)
                }
            }
            .help("Clear the Search Term")
        }
    }
    
    @ObservedObject var analysis: CodebaseAnalysis
}
