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
                case .treeMap:
                    if artifact.parts.isEmpty
                    {
                        VStack(alignment: .center)
                        {
                            Label("Empty Scope", systemImage: "xmark.rectangle")
                            .font(.system(.title))
                            .padding(.bottom)
                            
                            Text(artifact.name + " contains no further symbols that could be detected.")
                        }
                        .foregroundColor(.secondary)
                        .padding()
                    }
                    else
                    {
                        RootArtifactContentView(artifact: artifact,
                                              viewModel: viewModel)
                        .padding(CodeArtifact.padding)
                    }
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
                        .foregroundColor(.secondary)
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
