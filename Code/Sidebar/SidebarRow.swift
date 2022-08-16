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
                    } label:
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
        } label:
        {
            SidebarLabel(artifact: artifact,
                         isSelected: artifact === viewModel.selectedArtifact)
        }
    }
    
    let artifact: ArtifactViewModel
    @ObservedObject var viewModel: Codeface
}
