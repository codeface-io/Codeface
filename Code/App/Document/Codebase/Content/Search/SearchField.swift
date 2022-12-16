import SwiftUI
import CodefaceCore

struct SearchField: View
{
    @MainActor
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
            .focused($isFocused)
            .onChange(of: isFocused)
            {
                print("view observes system/user: \($0)")
                processorVM.set(fieldIsFocused: $0)
            }
            .onReceive(processorVM.$searchVM.dropFirst().map({ $0.fieldIsFocused }).removeDuplicates())
            {
                print("view observes model: \($0)")
                isFocused = $0
            }
            .onChange(of: searchTerm)
            {
                processorVM.set(searchTerm: $0)
            }
            .onReceive(processorVM.$searchVM.dropFirst().map({ $0.searchTerm }).removeDuplicates())
            {
                searchTerm = $0
            }
            .onSubmit
            {
                isFocused = false
                processorVM.submitSearchTerm()
            }
            
            if !processorVM.searchVM.searchTerm.isEmpty
            {
                Button(systemImageName: "xmark.circle.fill")
                {
                    withAnimation(.easeInOut(duration: 1))
                    {
                        processorVM.set(searchTerm: "")
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
                .fill(.primary.opacity(isFocused ? 0.02 : 0.06))
        }
        .overlay
        {
            RoundedRectangle(cornerRadius: 6)
                .stroke(.primary.opacity(0.2), lineWidth: 0.5)
        }
        .frame(minWidth: 200)
    }
    
    let processorVM: ProjectProcessorViewModel
    
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
