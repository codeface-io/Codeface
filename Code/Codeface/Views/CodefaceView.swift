import SwiftUI
import AppKit
import SwiftObserver
import SwiftLSP

struct CodefaceView: View
{
    var body: some View
    {
        NavigationView
        {
            SidebarView(viewModel: viewModel)
            .searchable(text: $searchTerm,
                        placement: .toolbar,
                        prompt: searchPrompt)
            .onSubmit(of: .search)
            {
                viewModel.submitSearch()
            }
            
            Label("Select a code artifact from the list",
                  systemImage: "arrow.left")
            .padding()
            .font(.system(.title))
            .foregroundColor(.secondary)
        }
        .onReceive(viewModel.$isSearching)
        {
            if $0 { searchTerm = viewModel.appliedSearchTerm ?? "" }
        }
        .onChange(of: searchTerm)
        {
            newSearchTerm in
            
            withAnimation(.easeInOut)
            {
                viewModel.userChanged(searchTerm: newSearchTerm)
            }
        }
    }
    
    private var searchPrompt: String
    {
        "Search in \(viewModel.selectedArtifact?.name ?? "Selected Artifact")"
    }
    
    @State var searchTerm = ""
    
    @ObservedObject var viewModel: Codeface
}
