import SwiftUI

struct SidebarRow: View
{
    var body: some View
    {
        NavigationLink(tag: artifactVM, selection: $viewModel.selectedArtifact)
        {
            Group
            {
                switch viewModel.displayMode
                {
                case .treeMap: TreeMap(artifactVM: artifactVM, viewModel: viewModel)
                case .code: CodeView(artifact: artifactVM)
                }
            }
            .navigationTitle(artifactVM.codeArtifact.name)
            .navigationSubtitle(artifactVM.codeArtifact.kindName)
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
            SidebarLabel(artifact: artifactVM,
                         isSelected: artifactVM === viewModel.selectedArtifact)
        }
    }
    
    let artifactVM: ArtifactViewModel
    @ObservedObject var viewModel: Codeface
}
