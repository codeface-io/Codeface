import SwiftUI

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
