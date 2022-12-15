import SwiftUI
import CodefaceCore
import SwiftyToolz

struct CodebaseNavigatorView: View
{
    init(rootArtifact: ArtifactViewModel, codefaceDocument: CodefaceDocument) {
        self.rootArtifact = rootArtifact
        self.codefaceDocument = codefaceDocument
        
        _selectedArtifact = State(wrappedValue: rootArtifact)
    }
    
    var body: some View
    {
        NavigationStack
        {
            List([rootArtifact],
                 children: \.children,
                 selection: $selectedArtifact)
            {
                artifactVM in

                NavigationLink(value: artifactVM)
                {
                    SidebarLabel(artifact: artifactVM,
                                 isSelected: artifactVM == codefaceDocument.selectedArtifact)
                }
            }
        }.onChange(of: codefaceDocument.selectedArtifact) { newSelection in
            guard newSelection != selectedArtifact else { return }
            
            if let newSelection {
                log("CodefaceDocument.selectedArtifact was programmatically set to \(newSelection.codeArtifact.name)")
                selectedArtifact = newSelection
            } else {
                log(warning: "CodefaceDocument.selectedArtifact was programmatically set nil. This should not happen.")
            }
        }.onAppear {
            codefaceDocument.selectedArtifact = selectedArtifact
        }.onChange(of: selectedArtifact) {
            log("Navigator selection was interactively set to \($0.codeArtifact.name)")
            codefaceDocument.selectedArtifact = $0
        }
    }
    
    let rootArtifact: ArtifactViewModel
    
    // TODO: directly bind our selection to a non-optional selection in the CodefaceDocument or some other view model. there should always be a selection in the context of the whole codebase analysis view since the data always has a root artifact!
    @ObservedObject var codefaceDocument: CodefaceDocument
    
    @State private var selectedArtifact: ArtifactViewModel
}


private extension ArtifactViewModel
{
    var children: [ArtifactViewModel]?
    {
        parts.isEmpty ? nil : parts
    }
}
