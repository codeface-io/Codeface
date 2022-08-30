import SwiftUI
import CodefaceCore

struct SidebarArtifactList: View
{
    var body: some View
    {
        List([rootArtifact],
             children: \.children,
             selection: $analysisVM.selectedArtifact)
        {
            SidebarRow(artifactVM: $0, viewModel: analysisVM)
        }
        .listStyle(.sidebar)
        .onChange(of: isSearching)
        {
            [isSearching] isSearchingNow in
            
            guard isSearching != isSearchingNow else { return }
            
            analysisVM.isTypingSearch = isSearchingNow
        }
        .onReceive(analysisVM.$isTypingSearch)
        {
            if !$0 { dismissSearch() }
        }
    }
    
    @Environment(\.isSearching) private var isSearching
    @Environment(\.dismissSearch) private var dismissSearch
    
    @ObservedObject var analysisVM: ProjectAnalysisViewModel
    let rootArtifact: ArtifactViewModel
}

private extension ArtifactViewModel
{
    var children: [ArtifactViewModel]?
    {
        parts.isEmpty ? nil : parts
    }
}
