import SwiftUI

struct SidebarView: View
{
    var body: some View
    {
        List(viewModel.artifacts, children: \.children, selection: $selectedArtifact)
        {
            artifact in
            
            NavigationLink(tag: artifact, selection: $selectedArtifact)
            {
                Group
                {
                    switch displayMode
                    {
                    case .treeMap:
                        ArtifactContentView(artifact: artifact,
                                            ignoreSearchFilter: viewModel.isSearching)
                            .drawingGroup()
                            .padding(CodeArtifact.LayoutModel.padding)
                            
                    case .code:
                        if let code = artifact.code
                        {
                            TextEditor(text: .constant(code))
                                .font(.system(.body, design: .monospaced))
                        }
                        else
                        {
                            VStack
                            {
                                Label {
                                    Text(artifact.name)
                                } icon: {
                                    ArtifactIcon(artifact: artifact, isSelected: false)
                                }
                                .font(.system(.title))
                                
                                Text("Select a contained file or symbol to show their code.")
                                    .padding(.top)
                            }
                            .padding()
                        }
                    }
                }
                .navigationTitle(artifact.name)
                .navigationSubtitle(artifact.kindName)
                .toolbar
                {
                    DisplayModePicker(displayMode: $displayMode)
                   
                    if let searchTerm = viewModel.appliedSearchTerm,
                       !searchTerm.isEmpty
                    {
                        Button
                        {
                            withAnimation(.easeInOut)
                            {
                                viewModel.removeSearchFilter()
                            }
                        }
                        label:
                        {
                            HStack
                            {
                                Text("Search Filter:")
                                Text(searchTerm)
                                    .foregroundColor(.accentColor)
                                Image(systemName: "multiply")
                            }
                        }
                    }
                }
            }
            label:
            {
                SidebarLabel(artifact: artifact,
                             isSelected: artifact === selectedArtifact)
            }
        }
        .listStyle(.sidebar)
        .toolbar
        {
            Button(action: toggleSidebar)
            {
                Image(systemName: "sidebar.leading")
            }
        }
        .onReceive(viewModel.$isSearching)
        {
            if !$0 { dismissSearch() }
        }
        .onChange(of: isSearching)
        {
            [isSearching] isSearchingNow in
            
            if !isSearching, isSearchingNow
            {
                viewModel.beginSearch()
            }
        }
    }
    
    @Environment(\.isSearching) var isSearching
    @Environment(\.dismissSearch) var dismissSearch
    
    @ObservedObject var viewModel: CodeArtifactViewModel
    @Binding var displayMode: DisplayMode
    
    @State var selectedArtifact: CodeArtifact?
}

private extension CodeArtifact
{
    /// SwiftUI needs this optional
    var children: [CodeArtifact]? { parts.isEmpty ? nil : parts }
}
