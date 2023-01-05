import SwiftUI

struct ToolbarFilterIndicator: View
{
    var body: some View
    {
        if !analysis.search.term.isEmpty
        {
            Button
            {
                analysis.set(searchTerm: "")
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
