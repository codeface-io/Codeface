import SwiftUI
import CodefaceCore

struct SearchField: View {
    
    internal init(processorVM: ProjectProcessorViewModel) {
        self.processorVM = processorVM
        self.searchVM = processorVM.searchVM
    }
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search Field",
                      text: $searchVM.searchTerm,
                      prompt: Text("Enter search term"))
            .onChange(of: searchVM.searchTerm) { newSearchTerm in
                processorVM.userChangedSearchTerm()
                showSubmitButton = !processorVM.searchVM.searchTerm.isEmpty
            }
            .focused($isFocused)
            .onChange(of: isFocused)
            {
                isFocusedNow in
                
                if isFocusedNow
                {
                    processorVM.searchFieldObtainedFocus()
                    
                    if !searchVM.searchTerm.isEmpty {
                        showSubmitButton = true
                    }
                }
                else if showSubmitButton
                {
                    submit()
                }
            }
            .textFieldStyle(.plain)
            .foregroundColor(.accentColor)
            .onSubmit { submit() }
            
            if showSubmitButton
            {
                Button(systemImageName: "return") { submit() }
                    .buttonStyle(.plain)
                    .focusable(false)
            }
            
            if !searchVM.searchTerm.isEmpty
            {
                Button(systemImageName: "xmark.circle.fill") {
                    withAnimation(.easeInOut(duration: 1.5))
                    {
                        processorVM.removeSearchFilter()
                    }
                }
                .buttonStyle(.plain)
                .focusable(false)
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
        .onChange(of: searchVM.showsSearchBar) { newValue in
            if !newValue {
                isFocused = false
            }
        }
    }
    
    @MainActor
    private func submit()
    {
        showSubmitButton = false
        processorVM.submit()
        isFocused = false
    }
    
    @FocusState private var isFocused: Bool
    @State private var showSubmitButton = false
    let processorVM: ProjectProcessorViewModel
    @ObservedObject private var searchVM: SearchVM
}

extension Button where Label == Image {
    init(systemImageName: String, action: @escaping () -> Void) {
        self = Button(action: action) {
            Image(systemName: systemImageName)
        }
    }
}
