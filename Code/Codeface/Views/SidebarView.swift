import SwiftUI

struct SidebarView: View
{
    var body: some View
    {
        List(viewModel.artifacts,
             selection: $viewModel.selectedArtifact)
        {
            artifact in
            
            DisclosingRowView(artifact: artifact,
                              viewModel: viewModel)
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
    
    @ObservedObject var viewModel: Codeface
}

struct DisclosingRowView: View
{
    internal init(artifact: CodeArtifact,
                  viewModel: Codeface)
    {
        self.artifact = artifact
        self.viewModel = viewModel
        
        isExpanded = artifact.isExpanded
    }
    
    var body: some View
    {
        if artifact.parts.isEmpty
        {
            RowView(artifact: artifact,
                    viewModel: viewModel)
        }
        else
        {
            DisclosureGroup(isExpanded: $isExpanded)
            {
                ForEach(artifact.parts)
                {
                    DisclosingRowView(artifact: $0,
                                      viewModel: viewModel)
                }
            }
            label:
            {
                RowView(artifact: artifact,
                        viewModel: viewModel)
            }
            .onReceive(artifact.$isExpanded) { isExpanded = $0 }
        }
    }
    
    @State var isExpanded = false
    
    let artifact: CodeArtifact
    @ObservedObject var viewModel: Codeface
}

struct RowView: View
{
    var body: some View
    {
        NavigationLink(tag: artifact, selection: $viewModel.selectedArtifact)
        {
            Group
            {
                switch viewModel.displayMode
                {
                case .treeMap:
                    GeometryReader
                    {
                        geo in
                        
                        ArtifactContentView(artifact: artifact,
                                            viewModel: viewModel,
                                            ignoreSearchFilter: viewModel.isSearching)
                        .drawingGroup()
                        .onChange(of: geo.size)
                        {
                            size in
                            
                            Task
                            {
                                withAnimation(.easeInOut(duration: 1))
                                {
                                    artifact.updateLayoutOfParts(forScopeSize: size,
                                                                 ignoreSearchFilter: viewModel.isSearching)
                                }
                            }
                        }
                        .onReceive(viewModel.$isSearching)
                        {
                            _ in
                            
                            Task
                            {
                                withAnimation(.easeInOut(duration: 1))
                                {
                                    artifact.updateLayoutOfParts(forScopeSize: geo.size,
                                                                 ignoreSearchFilter: viewModel.isSearching)
                                }
                            }
                        }
                    }
                    .padding(CodeArtifact.padding)
                    
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
                DisplayModePicker(displayMode: $viewModel.displayMode)
                
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
                            Image(systemName: "xmark")
                        }
                    }
                }
            }
        } label: {
            SidebarLabel(artifact: artifact,
                         isSelected: artifact === viewModel.selectedArtifact)
        }
    }
    
    let artifact: CodeArtifact
    @ObservedObject var viewModel: Codeface
}

extension CodeArtifact: Hashable
{
    nonisolated static func == (lhs: CodeArtifact, rhs: CodeArtifact) -> Bool
    {
        // TODO: implement true equality instead of identity
        lhs === rhs
    }
    
    func hash(into hasher: inout Hasher)
    {
        hasher.combine(id)
    }
}
