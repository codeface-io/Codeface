import SwiftUI
import CodefaceCore
import LSPServiceKit
import SwiftLSP

struct CodefaceDocumentContentView: View
{
    var body: some View
    {
        if let processorVM = codefaceDocument.projectProcessorVM
        {
            ContentNavigationView(codefaceDocument: codefaceDocument,
                                  processorVM: processorVM)
        }
        else
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
    }
    
    @ObservedObject var codefaceDocument: CodefaceDocument
    @ObservedObject private var serverManager = LSP.ServerManager.shared
}
