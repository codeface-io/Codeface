import SwiftUI
import CodefaceCore

struct CodeView: View
{
    var body: some View
    {
        if let code = artifact.codeArtifact.code
        {
            TextEditor(text: .constant("\n" + code))
                .font(.system(size: 15, weight: nil, design: .monospaced))
                .scrollContentBackground(.hidden) // must be hidden to see background
                .padding(.leading)
                .background(colorScheme == .dark ? .black : .white) 
        }
        else
        {
            VStack
            {
                Spacer ()
                
                Label {
                    Text(artifact.codeArtifact.name)
                } icon: {
                    Image(systemName: artifact.iconSystemImageName)
                        .foregroundColor(.init(artifact.iconFillColor))
                }
                .font(.title)
                
                Text("Select a contained file or symbol to show their code.")
                    .font(.title3)
                    .padding(.top)
                
                Spacer()
            }
            .foregroundColor(.secondary)
            .padding()
        }
    }
    
    let artifact: ArtifactViewModel
    
    @Environment(\.colorScheme) private var colorScheme
}
