import SwiftUI
import SwiftLSP
import LSPServiceKit

struct EmptyProcesorView: View
{
    var body: some View
    {
        VStack
        {
            if serverManager.serverIsWorking
            {
                Spacer()
            }
            
            HStack
            {
                Spacer()
                Text("This is an empty codebase file.\nImport a code folder via the Edit menu.")
                    .multilineTextAlignment(.center)
                    .font(.title)
                    .foregroundColor(.secondary)
                    .padding()
                Spacer()
            }
            
            if !serverManager.serverIsWorking
            {
                LSPServiceHint()
            }
            else
            {
                Spacer()
            }
        }
        .padding(50)
    }
    
    @ObservedObject private var serverManager = LSP.ServerManager.shared
}
