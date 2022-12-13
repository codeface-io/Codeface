import SwiftUI
import CodefaceCore

struct SearchField: View {
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search Field",
                      text: $searchTerm,
                      prompt: Text("Enter search term"))
            .focused($isFocused)
            .onChange(of: isFocused)
            {
                isFocusedNow in
                
                if isFocusedNow
                {
                    processorVM.searchFieldObtainedFocus()
                }
                else
                {
                    processorVM.searchFieldLostFocus(witchSearchTerm: searchTerm)
                }
            }
            .textFieldStyle(.plain)
            .foregroundColor(.accentColor)
            .onSubmit
            {
                isFocused = false
            }
            
            if !searchTerm.isEmpty
            {
                Button(systemImageName: "xmark.circle.fill") {
                    withAnimation(.easeInOut(duration: 1.5))
                    {
                        searchTerm = ""
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(3)
        .background {
            RoundedRectangle(cornerRadius: 6)
                .fill(.primary.opacity(0.04)) // use this to color the bg
        }
        .overlay {
            RoundedRectangle(cornerRadius: 6)
                .stroke(.primary.opacity(0.2))
        }
        .frame(minWidth: 200)
    }
    
    @FocusState private var isFocused: Bool
    @Binding var searchTerm: String
    let processorVM: ProjectProcessorViewModel
}

extension Button where Label == Image {
    init(systemImageName: String, action: @escaping () -> Void) {
        self = Button(action: action) {
            Image(systemName: systemImageName)
        }
    }
}
