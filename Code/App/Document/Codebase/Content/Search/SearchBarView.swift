import SwiftUI
import CodefaceCore

struct SearchBarView: View
{
    var body: some View
    {
        HStack(alignment: .firstTextBaseline)
        {
            SearchField(processorVM: processorVM)
                .padding(.top, 1)
                .padding([.bottom, .trailing], 6)
                .padding([.leading])
            
            Button("Done")
            {
                withAnimation(.easeInOut(duration: SearchVM.toggleAnimationDuration))
                {
                    processorVM.hideSearchBar()
                }
            }
            .focusable(false)
            .padding(.trailing)
            .help("Hide the search filter (⇧⌘F)")
        }
        .frame(height: processorVM.searchVM.barIsShown ? nil : 0)
        .clipShape(Rectangle())
    }
    
    @ObservedObject var processorVM: ProjectProcessorViewModel
}
