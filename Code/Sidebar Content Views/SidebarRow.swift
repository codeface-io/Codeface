import SwiftUI
import CodefaceCore

struct SidebarRow: View
{
    var body: some View
    {
        NavigationLink(tag: selectedArtifactVM, selection: $viewModel.selectedArtifact)
        {
            Group
            {
                switch viewModel.displayMode
                {
                case .treeMap: TreeMap(rootArtifactVM: selectedArtifactVM, viewModel: viewModel)
                case .code: CodeView(artifact: selectedArtifactVM)
                }
            }
            .navigationTitle(selectedArtifactVM.codeArtifact.name)
            .navigationSubtitle(selectedArtifactVM.codeArtifact.kindName)
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
            SidebarLabel(artifact: selectedArtifactVM,
                         isSelected: selectedArtifactVM === viewModel.selectedArtifact)
        }
    }
    
    let selectedArtifactVM: ArtifactViewModel
    @ObservedObject var viewModel: ProjectAnalysisViewModel
}
