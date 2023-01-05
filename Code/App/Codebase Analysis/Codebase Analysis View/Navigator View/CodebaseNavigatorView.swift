import SwiftUI
import SwiftyToolz

struct CodebaseNavigatorView: View
{
    init(analysis: CodebaseAnalysis,
         showsLinesOfCode: Binding<Bool>)
    {
        self.analysis = analysis
        _showsLinesOfCode = showsLinesOfCode
        _selectedArtifactID = State(wrappedValue: analysis.rootArtifact.id)
    }
    
    var body: some View
    {
        List([analysis.rootArtifact],
             children: \.children,
             selection: $selectedArtifactID)
        {
            artifact in

            NavigationLink(value: artifact.id)
            {
                SidebarLabel(artifact: artifact,
                             showsLinesOfCode: $showsLinesOfCode)
//                    .listRowBackground(nil)
            }
            .onChange(of: selectedArtifactID)
            {
                if $0 == artifact.id
                {
                    analysis.selectedArtifact = artifact
                }
            }
        }
    }
    
    let analysis: CodebaseAnalysis
    
    // we hold this separately, so we don't have to hold analysis as an ObservedObject since that would fuck up the list UI
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
