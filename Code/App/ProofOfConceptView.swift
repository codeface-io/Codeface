import SwiftUI

struct ProofOfConceptView: View
{
    var body: some View
    {
        DoubleSidebarView(viewModel: sidebarsVM)
        {
            TextField("Text Field Content", text: $textContent)
                .focused($contentIsFocused)
                .onSubmit {
                    contentIsFocused = false
                }
        }
        leftSidebar:
        {
            TextField("Text Field Left", text: $textLeft)
                .focused($leftIsFocused)
                .onSubmit {
                    leftIsFocused = false
                }
        }
        rightSidebar:
        {
            Text("right")
        }
    }
    
    @StateObject private var sidebarsVM = DoubleSidebarViewModel()
    
    @State var textLeft = ""
    @FocusState var leftIsFocused: Bool
    
    @State var textContent = ""
    @FocusState var contentIsFocused: Bool
}
