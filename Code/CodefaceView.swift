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
                
            Label("Select a code artifact from the list",
                  systemImage: "arrow.left")
                .padding()
                .font(.system(.title))
        }
        .searchable(text: $searchTerm)
        .onChange(of: searchTerm)
        {
            newSearchTerm in
            
            withAnimation(.easeInOut)
            {
                viewModel.userTyped(searchTerm: newSearchTerm)
            }
        }
        
    }
    
    @State var searchTerm = ""
    @StateObject private var viewModel: CodeArtifactViewModel
    
    @Binding var displayMode: DisplayMode
}
