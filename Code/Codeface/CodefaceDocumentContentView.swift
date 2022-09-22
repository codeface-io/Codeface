import SwiftUI
import CodefaceCore

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
                Spacer()
                HStack
                {
                    Spacer()
                    Text("Import a codebase folder via the File menu.")
                        .multilineTextAlignment(.center)
                        .font(.title)
                        .foregroundColor(.secondary)
                        .padding()
                    Spacer()
                }
                Spacer()
            }
        }
    }
    
    @ObservedObject var codefaceDocument: CodefaceDocument
}
