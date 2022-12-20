import SwiftUI
import CodefaceCore

struct ToolbarFilterIndicator: View
{
    var body: some View
    {
        if !processorVM.searchVM.term.isEmpty
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
                    
                    Text(processorVM.searchVM.term)
                        .foregroundColor(.accentColor)
                    
                    Image(systemName: "xmark")
                        .imageScale(.medium)
                }
            }
            .help("Clear the Search Term")
        }
    }
    
    @ObservedObject var processorVM: CodebaseProcessorViewModel
}
