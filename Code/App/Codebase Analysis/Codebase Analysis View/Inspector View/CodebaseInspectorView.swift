import SwiftUI

struct CodebaseInspectorView: View
{
    var body: some View
    {
        if let selectedArtifact = processor.selectedArtifact
        {
            CodebaseInspectorContentView(selectedArtifact: selectedArtifact)
        }
        else
        {
            Text("Select a code artifact in the Navigator.")
        }
    }
    
    @ObservedObject var processor: CodebaseProcessor
}
