import SwiftUI

struct ProofOfConceptView: View
{
    var body: some View
    {
//        NavigationSplitView
//        {
//            List(["1", "2", "3"], id: \.self, selection: $selection) { item in
//                NavigationLink(value: item) {
//                    Text(item)
//                }
//            }
//            .focusable(false)
//            .listStyle(.sidebar)
//            .toolbar {
//                Button("Start Typing") {
//                    Task { contentIsFocused = true }
//                }
//            }
//        }
//        detail:
//        {
//
//            TextField("Text Field Content", text: $textContent)
//                .focused($contentIsFocused)
//                .onSubmit {
//                    contentIsFocused = false
//                }
//            List(["1", "2", "3"], id: \.self, selection: $selection) { item in
//                NavigationLink(value: item) {
//                    Text(item)
//                }
//            }
//            .listStyle(.sidebar)
//        }
        
        
        
//        HSplitView
//        {
//            NavigationStack {
//                List(["1", "2", "3"], id: \.self) { item in
//                    NavigationLink(value: item) {
//                        Text(item)
//                    }
//                }
//                .listStyle(.sidebar)
//            }
//
//            List(["1", "2", "3"], id: \.self) {
//                Text($0)
//            }
//            .listStyle(.sidebar)
//
//            List(["1", "2", "3"], id: \.self) {
//                Text($0)
//            }
//            .listStyle(.sidebar)
//        }
        
        
        
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
                .toolbar {
                    Button("Start Typing") {
                        Task { contentIsFocused = true }
                    }
                }
        }
        rightSidebar:
        {
            Text("right")
        }
    }
    
    @State var selection: String? = nil
    
    @StateObject private var sidebarsVM = DoubleSidebarViewModel()
    
    @State var textLeft = ""
    @FocusState var leftIsFocused: Bool
    
    @State var textContent = ""
    @FocusState var contentIsFocused: Bool
}
