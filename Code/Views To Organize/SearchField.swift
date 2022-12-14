import SwiftUI
import CodefaceCore

struct SearchField: View
{
    init(processorVM: ProjectProcessorViewModel)
    {
        self.processorVM = processorVM
        _searchTerm = State(wrappedValue: processorVM.searchVM.searchTerm)
    }
    
    var body: some View
    {
        HStack(alignment: .firstTextBaseline)
        {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search Field",
                      text: $searchTerm,
                      prompt: Text("Enter search term"))
            .textFieldStyle(.plain)
            .foregroundColor(.accentColor)
            .focused($isFocused)
            .onChange(of: isFocused)
            {
                processorVM.userChanged(fieldIsFocused: $0)
            }
            .onChange(of: processorVM.searchVM.fieldIsFocused)
            {
                isFocused = $0
            }
            .onChange(of: searchTerm)
            {
                processorVM.write(searchTerm: $0)
            }
            .onChange(of: processorVM.searchVM.searchTerm)
            {
                searchTerm = $0
            }
            .onSubmit
            {
                processorVM.submitSearchTerm()
            }
            
            if processorVM.searchVM.submitButtonIsShown
            {
                Button(systemImageName: "return")
                {
                    processorVM.submitSearchTerm()
                }
                .buttonStyle(.plain)
                .focusable(false)
            }
            
            if !processorVM.searchVM.searchTerm.isEmpty
            {
                Button(systemImageName: "xmark.circle.fill")
                {
                    withAnimation(.easeInOut(duration: 1.5))
                    {
                        processorVM.clearSearchField()
                    }
                }
                .buttonStyle(.plain)
                .focusable(false)
            }
        }
        .padding(3)
        .background
        {
            RoundedRectangle(cornerRadius: 6)
                .fill(.primary.opacity(0.04))
        }
        .overlay
        {
            RoundedRectangle(cornerRadius: 6)
                .stroke(.primary.opacity(0.2))
        }
        .frame(minWidth: 200)
    }
    
    @ObservedObject
    var processorVM: ProjectProcessorViewModel
    
    @FocusState
    private var isFocused: Bool
    
    @State
    private var searchTerm: String
}

extension Button where Label == Image
{
    init(systemImageName: String, action: @escaping () -> Void)
    {
        self = Button(action: action)
        {
            Image(systemName: systemImageName)
        }
    }
}
