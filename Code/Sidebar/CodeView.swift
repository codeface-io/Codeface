import SwiftUI

struct CodeView: View
{
    var body: some View
    {
        if let code = artifact.codeArtifact.code
        {
            TextEditor(text: .constant(code))
                .font(.system(.body, design: .monospaced))
        }
        else
        {
            VStack
            {
                Label {
                    Text(artifact.codeArtifact.name)
                } icon: {
                    ArtifactIcon(artifact: artifact, isSelected: false)
                }
                .font(.system(.title))
                
                Text("Select a contained file or symbol to show their code.")
                    .padding(.top)
            }
            .foregroundColor(.secondary)
            .padding()
        }
    }
    
    let artifact: ArtifactViewModel
}
