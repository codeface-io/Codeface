import SwiftUI
import CodefaceCore

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
