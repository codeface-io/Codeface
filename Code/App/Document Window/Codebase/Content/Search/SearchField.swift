import SwiftUI
import CodefaceCore

struct SearchField: View
{
    @MainActor
    init(processorVM: ProjectProcessorViewModel, artifactName: String)
    {
        self.processorVM = processorVM
        _searchTerm = State(wrappedValue: processorVM.searchVM.term)
        self.artifactName = artifactName
    }
    
    var body: some View
    {
        HStack(alignment: .firstTextBaseline)
        {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search Field",
                      text: $searchTerm,
                      prompt: Text("Find in \(artifactName)"))
            .textFieldStyle(.plain)
            .focused($isFocused)
            .onChange(of: isFocused)
            {
                // ❗️ we have to write the view model async (later) to not screw up focus management
                newFocus in Task { processorVM.set(fieldIsFocused: newFocus) }
            }
            .onReceive(processorVM.$searchVM.dropFirst().map({ $0.fieldIsFocused }).removeDuplicates())
            {
                isFocused = $0
            }
            .onChange(of: searchTerm)
            {
                // ❗️ we have to write the view model async (later) to not screw up focus management
                newTerm in Task { processorVM.set(searchTerm: newTerm) }
            }
            .onReceive(processorVM.$searchVM.dropFirst().map({ $0.term }).removeDuplicates())
            {
                searchTerm = $0
            }
            .onSubmit
            {
                // we don't wait for the view model here in order to avoid a certain visual hickup
                isFocused = false
                
                // ❗️ we have to write the view model async (later) to not screw up focus management
                Task { processorVM.submitSearchTerm() }
            }
            
            if !processorVM.searchVM.term.isEmpty
            {
                Button(systemImageName: "xmark.circle.fill")
                {
                    withAnimation(.easeInOut(duration: 1))
                    {
                        processorVM.set(searchTerm: "")
                    }
                }
                .foregroundColor(.secondary)
                .buttonStyle(.plain)
                .focusable(false)
            }
        }
        .padding([.leading, .trailing], 6)
        .frame(minWidth: 200, maxHeight: .infinity)
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
    }
    
    /// ❗️ we can **not** make processorVM an `@ObservedObject` and simply use `onChange(of:)` for observing the search VM since that would also screw up focus management ...
    let processorVM: ProjectProcessorViewModel
    
    @FocusState
    private var isFocused: Bool
    
    @State
    private var searchTerm: String
    
    let artifactName: String
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
