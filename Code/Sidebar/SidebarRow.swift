import SwiftUI

struct SidebarRow: View
{
    var body: some View
    {
        NavigationLink(tag: artifact, selection: $viewModel.selectedArtifact)
        {
            Group
            {
                switch viewModel.displayMode
                {
                case .treeMap: TreeMap(artifact: artifact, viewModel: viewModel)
                case .code: CodeView(artifact: artifact)
                }
            }
            .navigationTitle(artifact.codeArtifact.name)
            .navigationSubtitle(artifact.codeArtifact.kindName)
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
    
    let artifact: ArtifactViewModel
    @ObservedObject var viewModel: Codeface
}


struct TreeMap: View
{
    var body: some View
    {
        if artifact.parts.isEmpty
        {
            VStack(alignment: .center)
            {
                Label("Empty Scope", systemImage: "xmark.rectangle")
                    .font(.system(.title))
                    .padding(.bottom)
                
                Text(artifact.codeArtifact.name + " contains no further symbols that could be detected.")
            }
            .foregroundColor(.secondary)
            .padding()
        }
        else
        {
            RootArtifactContentView(artifact: artifact,
                                    viewModel: viewModel)
            .padding(ArtifactViewModel.padding)
            .background(Color(white: colorScheme == .dark ? 0 : 0.6))
        }
    }
    
    let artifact: ArtifactViewModel
    @ObservedObject var viewModel: Codeface
    @Environment(\.colorScheme) var colorScheme
}

struct CodeView: View
{
    var body: some View
    {
        if let code = artifact.codeArtifact.code
        {
            TextEditor(text: .constant(code))
                .font(.system(.body, design: .monospaced))
        }
        else
        {
            VStack
            {
                Label {
                    Text(artifact.codeArtifact.name)
                } icon: {
                    ArtifactIcon(artifact: artifact, isSelected: false)
                }
                .font(.system(.title))
                
                Text("Select a contained file or symbol to show their code.")
                    .padding(.top)
            }
            .foregroundColor(.secondary)
            .padding()
        }
    }
    
    let artifact: ArtifactViewModel
}
