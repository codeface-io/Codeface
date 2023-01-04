import SwiftUI
import SwiftyToolz

struct CodebaseNavigatorView: View
{
    init(rootArtifact: ArtifactViewModel,
         selectedArtifact: Binding<ArtifactViewModel?>,
         showsLinesOfCode: Binding<Bool>)
    {
        self.rootArtifact = rootArtifact
        _selectedArtifact = selectedArtifact
        _showsLinesOfCode = showsLinesOfCode
        _selectedArtifactID = State(wrappedValue: rootArtifact.id)
    }
    
    var body: some View
    {
        List([rootArtifact],
             children: \.children,
             selection: $selectedArtifactID)
        {
            artifactVM in

            NavigationLink(value: artifactVM.id)
            {
                SidebarLabel(artifact: artifactVM,
                             showsLinesOfCode: $showsLinesOfCode)
//                    .listRowBackground(nil)
            }
            .onChange(of: selectedArtifactID)
            {
                if $0 == artifactVM.id
                {
                    selectedArtifact = artifactVM
                }
            }
        }
        .onAppear
        {
            // TODO: this should be done much earlier and not here
            selectedArtifact = rootArtifact
        }
    }
    
    let rootArtifact: ArtifactViewModel
    
    // TODO: directly bind our selection to a non-optional selection. there should always be a selection in the context of the whole codebase analysis view since the data always has a root artifact!
    @Binding var selectedArtifact: ArtifactViewModel?
    
    @Binding var showsLinesOfCode: Bool
    
    // FIXME: as soon as we use anything other than the plain String ID as selection type, the list UI fucks up and rows cannot be selected anymore after a while ... we can't even wrap the id in a struct that only contains the id and is hashable by the id ... WTF apple ... this means every row has to observe the selected ID and set its view model as selected in the document when the ID matches ...
    @State private var selectedArtifactID: CodeArtifact.ID
}

private extension ArtifactViewModel
{
    var children: [ArtifactViewModel]?
    {
        parts.isEmpty ? nil : parts
    }
}
