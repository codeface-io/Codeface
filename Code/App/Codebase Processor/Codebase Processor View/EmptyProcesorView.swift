import SwiftUI
import SwiftLSP
import LSPServiceKit

struct EmptyProcesorView: View
{
    var body: some View
    {
        VStack
        {
            HStack
            {
                Spacer()
                Text("This is an empty codebase file.\nImport a code folder into this file via the File menu.")
                    .multilineTextAlignment(.center)
                    .font(.title)
                    .foregroundColor(.secondary)
                    .padding()
                Spacer()
            }
            
            LSPServiceHint()
        }
        .padding(50)
    }
    
    @ObservedObject private var serverManager = LSP.ServerManager.shared
}
