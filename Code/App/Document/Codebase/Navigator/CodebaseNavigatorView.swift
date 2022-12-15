import SwiftUI
import CodefaceCore
import SwiftyToolz

struct CodebaseNavigatorView: View
{
    init(rootArtifact: ArtifactViewModel,
         codefaceDocument: CodefaceDocument)
    {
        self.rootArtifact = rootArtifact
        self.codefaceDocument = codefaceDocument
        
        _selectedArtifactID = State(wrappedValue: rootArtifact.id)
    }
    
    var body: some View
    {
        NavigationStack
        {
            List([rootArtifact],
                 children: \.children,
                 selection: $selectedArtifactID)
            {
                artifactVM in

                NavigationLink(value: artifactVM.id)
                {
                    SidebarLabel(artifact: artifactVM)
                }
            }
        }
        .onChange(of: selectedArtifactID)
        {
            guard let selectedArtifactVM = ArtifactViewModel.byID[$0]?.object else { return }
            codefaceDocument.selectedArtifact = selectedArtifactVM
        }
    }
    
    let rootArtifact: ArtifactViewModel
    
    // TODO: directly bind our selection to a non-optional selection in the CodefaceDocument or some other view model. there should always be a selection in the context of the whole codebase analysis view since the data always has a root artifact!
    var codefaceDocument: CodefaceDocument
    
    // FIXME: as soon as we use anything other than the plain String ID as selection type, the list UI fucks up and rows cannot be selected anymore after a while ... we can't even wrap the id in a struct that only contains the id and is hashable by the id ... WTF apple ... this means we can only retrieve the actual selected artifact by hashing it via its ID, which then requires cache invalidation and weak references ... 🤮
    @State private var selectedArtifactID: CodeArtifact.ID
}

private extension ArtifactViewModel
{
    var children: [ArtifactViewModel]?
    {
        parts.isEmpty ? nil : parts
    }
}
