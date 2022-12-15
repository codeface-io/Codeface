import SwiftUI
import CodefaceCore

struct SearchBarView: View {
    
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
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
        .frame(height: processorVM.searchVM.searchBarIsShown ? nil : 0)
        .focusable(processorVM.searchVM.searchBarIsShown)
        .clipShape(Rectangle())
    }
    
    @ObservedObject var processorVM: ProjectProcessorViewModel
}
