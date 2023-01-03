import SwiftUI

struct ToolbarFilterIndicator: View
{
    var body: some View
    {
        if !processorVM.search.term.isEmpty
        {
            Button
            {
                processorVM.set(searchTerm: "")
            }
            label:
            {
                HStack
                {
                    Text("Search Filter:")
                    
                    Text(processorVM.search.term)
                        .foregroundColor(.accentColor)
                    
                    Image(systemName: "xmark")
                        .imageScale(.medium)
                }
            }
            .help("Clear the Search Term")
        }
    }
    
    @ObservedObject var processorVM: CodebaseProcessor
}
