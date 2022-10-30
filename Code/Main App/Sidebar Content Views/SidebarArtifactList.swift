import SwiftUI
import SwiftyToolz
import CodefaceCore

struct SidebarArtifactList: View
{
    var body: some View
    {
        List([rootArtifact],
             children: \.children,
             selection: $selectedArtifact)
        {
            SidebarRow(artifactVM: $0,
                       viewModel: analysisVM,
                       selectedArtifact: $selectedArtifact)
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
        .onAppear
        {
            selectedArtifact = rootArtifact
            listIsInFocus = true
        }
        .focused($listIsInFocus)
    }
    
    @Environment(\.isSearching) private var isSearching
    @Environment(\.dismissSearch) private var dismissSearch
    
    @ObservedObject var analysisVM: ProjectProcessorViewModel
    let rootArtifact: ArtifactViewModel
    @Binding var selectedArtifact: ArtifactViewModel?
    
    @FocusState private var listIsInFocus
}

private extension ArtifactViewModel
{
    var children: [ArtifactViewModel]?
    {
        parts.isEmpty ? nil : parts
    }
}
