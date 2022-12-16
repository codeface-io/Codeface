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
                // we have to write the view model async (later) to not screw SwiftUI (and focus management)
                newFocus in Task { processorVM.set(fieldIsFocused: newFocus) }
            }
            .onReceive(processorVM.$searchVM.dropFirst().map({ $0.fieldIsFocused }).removeDuplicates())
            {
                isFocused = $0
            }
            .onChange(of: searchTerm)
            {
                // we have to write the view model async (later) to not screw SwiftUI (and focus management)
                newTerm in Task { processorVM.set(searchTerm: newTerm) }
            }
            .onReceive(processorVM.$searchVM.dropFirst().map({ $0.searchTerm }).removeDuplicates())
            {
                searchTerm = $0
            }
            .onSubmit
            {
                // we don't wait for the view model here just to avoid a little visual hickup
                isFocused = false
                
                // we have to write the view model async (later) to not screw SwiftUI (and focus management)
                Task { processorVM.submitSearchTerm() }
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
