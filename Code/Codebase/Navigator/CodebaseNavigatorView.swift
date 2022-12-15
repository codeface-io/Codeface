import SwiftUI
import CodefaceCore

struct CodebaseNavigatorView: View
{
    var body: some View
    {
        NavigationStack
        {
            List([rootArtifact],
                 children: \.children,
                 selection: $codefaceDocument.selectedArtifact)
            {
                artifactVM in

                NavigationLink(value: artifactVM)
                {
                    SidebarLabel(artifact: artifactVM,
                                 isSelected: artifactVM == codefaceDocument.selectedArtifact)
                }
            }
        }
        .onAppear
        {
            Task { codefaceDocument.selectedArtifact = rootArtifact }
        }
    }
    
    let rootArtifact: ArtifactViewModel
    @ObservedObject var codefaceDocument: CodefaceDocument
}


private extension ArtifactViewModel
{
    var children: [ArtifactViewModel]?
    {
        parts.isEmpty ? nil : parts
    }
}
