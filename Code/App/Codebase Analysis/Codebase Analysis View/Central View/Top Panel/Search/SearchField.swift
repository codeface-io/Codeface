import SwiftUI

struct SearchField: View
{
    @MainActor
    init(analysis: CodebaseAnalysis, artifactName: String)
    {
        self.analysis = analysis
        _searchTerm = State(wrappedValue: analysis.search.term)
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
                newFocus in Task { analysis.set(fieldIsFocused: newFocus) }
            }
            .onReceive(analysis.$search.dropFirst().map({ $0.fieldIsFocused }).removeDuplicates())
            {
                isFocused = $0
            }
            .onChange(of: searchTerm)
            {
                // ❗️ we have to write the view model async (later) to not screw up focus management
                newTerm in Task { analysis.set(searchTerm: newTerm) }
            }
            .onReceive(analysis.$search.dropFirst().map({ $0.term }).removeDuplicates())
            {
                searchTerm = $0
            }
            .onSubmit
            {
                // we don't wait for the view model here in order to avoid a certain visual hickup
                isFocused = false
                
                // ❗️ we have to write the view model async (later) to not screw up focus management
                Task { analysis.submitSearchTerm() }
            }
            
            if !analysis.search.term.isEmpty
            {
                Button(systemImageName: "xmark.circle.fill")
                {
                    withAnimation(.easeInOut(duration: 1))
                    {
                        analysis.set(searchTerm: "")
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
    
    /// ❗️ we can **not** make analysis an `@ObservedObject` and simply use `onChange(of:)` for observing `Search` since that would also screw up focus management ...
    let analysis: CodebaseAnalysis
    
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
