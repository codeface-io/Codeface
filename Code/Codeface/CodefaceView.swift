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
            Sidebar(viewModel: viewModel)
            .searchable(text: $searchTerm,
                        placement: .toolbar,
                        prompt: searchPrompt)
            .onSubmit(of: .search)
            {
                viewModel.submitSearch()
            }
            
            switch viewModel.analysisState
            {
            case .failed, .stopped, .running:
                EmptyView()
            case .succeeded(let rootArtifact):
                Label("Select a code artifact from \(rootArtifact.name)",
                      systemImage: "arrow.left")
                .padding()
                .font(.system(.title))
                .foregroundColor(.secondary)
            }
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
