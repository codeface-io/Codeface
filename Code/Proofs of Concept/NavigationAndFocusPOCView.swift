import SwiftUI

struct NavigationAndFocusPOCView: View
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
        
        
        
        DoubleSidebarView(showLeftSidebar: $showLeftSidebar,
                          showRightSidebar: $showRightSidebar)
        {
            VStack
            {
                HStack {
                    Text("HUHU")
                    Spacer()
                }
                
                TextField("Text Field Content", text: $textContent)
                    .focused($contentIsFocused)
                    .onSubmit {
                        contentIsFocused = false
                    }
                Spacer()
            }
            .frame(maxHeight: .infinity)
            .ignoresSafeArea(.all, edges: [.top])
            .background(.black)
        }
        leftSidebar:
        {
            VStack
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
        }
        rightSidebar:
        {
            Text("right")
        }
    }
    
    @State var selection: String? = nil
    
    @State private var showLeftSidebar: Bool = true
    @State private var showRightSidebar: Bool = false
    
    @State var textLeft = ""
    @FocusState var leftIsFocused: Bool
    
    @State var textContent = ""
    @FocusState var contentIsFocused: Bool
}
