import SwiftUI
import CodefaceCore

struct CodeView: View
{
    var body: some View
    {
        if let code = artifact.codeArtifact.code
        {
            TextEditor(text: .constant(code))
                .font(.system(.body, design: .monospaced))
                .scrollContentBackground(.hidden) // must be hidden to see background
                .background(colorScheme == .dark ? .black : .white) 
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
    
    @Environment(\.colorScheme) private var colorScheme
}
