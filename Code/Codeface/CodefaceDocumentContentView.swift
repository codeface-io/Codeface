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
                    Text("Import a code folder into this empty file via the Edit menu.")
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
