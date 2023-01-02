import SwiftUI

struct SearchBarView: View
{
    var body: some View
    {
        HStack // whole bar
        {
            HStack // field & button
            {
                SearchField(processorVM: processorVM,
                            artifactName: artifactName)
                
                Button("Done")
                {
                    withAnimation(.easeInOut(duration: SearchVM.toggleAnimationDuration))
                    {
                        processorVM.hideSearchBar()
                    }
                }
                .focusable(false)
                .buttonStyle(.plain)
                .padding([.leading, .trailing])
                .frame(maxHeight: .infinity)
                .overlay
                {
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(.primary.opacity(0.2), lineWidth: 0.5)
                }
                .help("Hide the search filter (⇧⌘F)")
            }
            .font(.system(size: CodefaceStyle.fontSize))
            .frame(height: 29)
            .padding(.top, 1)
            .padding(.bottom, 6)
            .padding([.leading, .trailing])
        }
        .frame(height: processorVM.searchVM.barIsShown ? nil : 0)
        .clipShape(Rectangle())
    }
    
    @ObservedObject var processorVM: CodebaseProcessor
    
    let artifactName: String
}
