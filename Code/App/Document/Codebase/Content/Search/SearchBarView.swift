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
                withAnimation(.easeInOut(duration: SearchVM.visibilityToggleAnimationDuration))
                {
                    processorVM.searchVM.searchBarIsShown = false
                }
            }
            .focusable(false)
            .padding(.trailing)
        }
        .focusable(processorVM.searchVM.searchBarIsShown)
        .frame(height: processorVM.searchVM.searchBarIsShown ? nil : 0)
        .clipShape(Rectangle())
    }
    
    @ObservedObject var processorVM: ProjectProcessorViewModel
}
