import SwiftUI

struct CodefaceView14: View
{
    var body: some View
    {
        NavigationSplitView(columnVisibility: $columnVisibility)
        {
            List(Item.all, selection: $selectedItem)
            {
                NavigationLink($0.name, value: $0)
            }
        }
        detail:
        {
            InspectorView(item: selectedItem,
                          showsInspector: $showsInspector)
                .animation(.default, value: selectedItem)
        }
        .onAppear {
            Task {
                selectedItem = .all.first
            }
        }
    }

    @State var selectedItem: Item? = nil
    
    @Binding var columnVisibility: NavigationSplitViewVisibility
    @Binding var showsInspector: Bool
}

struct InspectorView: View {

    var body: some View {
        
        GeometryReader { geo in
            
            HStack(spacing: 0) {
                
                //Main
                VStack {
                    Text(item?.text ?? "No item selected. Select Item 1.")
                        .font(.title)
                        .padding()
                    
                    let subitems = item?.subitems ?? []
                    
                    List(subitems, id: \.self) { num in
                        Text("Subitem \(num)")
                    }
                    .focusable(false)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // Inspector
                HStack(spacing: 0) {
                    Divider()
                        .frame(minWidth: 0)
                    
                    List {
                        if let item {
                            Text("\(item.name) Inspector Element 1")
                            Text("\(item.name) Inspector Element 2")
                            Text("\(item.name) Inspector Element 3")
                            Text("\(item.name) Inspector Element 4")
                            Text("\(item.name) Inspector Element 5")
                        } else {
                            Text("No item selected")
                        }
                    }
                    .focusable(false)
                    .listStyle(.sidebar)
                }
                .frame(width: showsInspector ? max(250, geo.size.width / 4) : 0)
                .opacity(showsInspector ? 1 : 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .toolbar {
                // TODO: fext field in toolbar does not recognize its focus ...
                SearchField()
                
                Button {
                    withAnimation {
                        showsInspector.toggle()
                    }
                } label: {
                    Image(systemName: "sidebar.right")
                }
            }
        }
    }
    
    let item: Item?
    
    @Binding var showsInspector: Bool
}

struct SearchField: View {
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.primary.opacity(0.55))
            
            TextField("Search Field",
                      text: $searchTerm,
                      prompt: Text("Enter search term"))
            .focused($isFocused)
            .textFieldStyle(.plain)
        }
        .padding(6)
        .background {
            RoundedRectangle(cornerRadius: 6)
                .fill(isFocused ? Color.primary.opacity(0.05) : .clear) // use this to color the bg
        }
        .overlay {
            RoundedRectangle(cornerRadius: 6)
                .stroke(.primary.opacity(0.08))
        }
        .frame(minWidth: 200)
    }
    
    @FocusState private var isFocused: Bool
    @State var searchTerm = ""
}

struct Item: Hashable, Identifiable
{
    static let all: [Item] =
    [
        .init(name: "Item 1",
              text: "If you select Item 2, then this content will animate into ...",
             subitems: [0, 1, 3, 4, 6, 7, 9, 10, 12]),
        .init(name: "Item 2",
              text: "... this one because both are in a structurally identical view.",
             subitems: [0, 2, 3, 5, 6, 8, 9, 11, 12])
    ]
    
    let id = UUID()
    let name: String
    let text: String
    let subitems: [Int]
}
