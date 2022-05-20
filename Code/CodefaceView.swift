import SwiftUI
import AppKit
import SwiftObserver
import SwiftLSP

struct CodefaceView: View
{
    init(displayMode: Binding<DisplayMode>)
    {
        _viewModel = StateObject(wrappedValue: CodeArtifactViewModel())
        _displayMode = displayMode
    }
    
    var body: some View
    {
        NavigationView
        {
            SidebarView(viewModel: viewModel,
                        displayMode: $displayMode)
            .searchable(text: $searchTerm,
                        placement: .toolbar)
            .onSubmit(of: .search)
            {
                viewModel.submitSearch()
            }
                
            Label("Select a code artifact from the list",
                  systemImage: "arrow.left")
                .padding()
                .font(.system(.title))
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
    
    @State var searchTerm = ""
    @StateObject private var viewModel: CodeArtifactViewModel
    
    @Binding var displayMode: DisplayMode
}
