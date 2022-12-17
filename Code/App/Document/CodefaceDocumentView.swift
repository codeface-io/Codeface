import SwiftUI
import CodefaceCore
import SwiftLSP

struct CodefaceDocumentView: View
{
    var body: some View
    {
        CodefaceDocumentContentView(codefaceDocument: codefaceDocument,
                                    sidebarViewModel: sidebarViewModel)
            .focusedSceneValue(\.document, codefaceDocument)
            .onReceive(codefaceDocument.$codebase)
            {
                if let updatedCodebase = $0
                {
                    codebaseFile.codebase = updatedCodebase
                }
            }
            .onAppear
            {
                if let codebase = codebaseFile.codebase
                {
                    codefaceDocument.loadProcessor(for: codebase)
                }
            }
    }
    
    @StateObject private var codefaceDocument = CodefaceDocument()
    @Binding var codebaseFile: CodebaseFileDocument
    let sidebarViewModel: DoubleSidebarViewModel
}

struct CodefaceDocumentContentView: View
{
    var body: some View
    {
        if let processorVM = codefaceDocument.projectProcessorVM
        {
            CodebaseProcessingView(codefaceDocument: codefaceDocument,
                                   processorVM: processorVM,
                                   sidebarViewModel: sidebarViewModel)
        }
        else // no processor in the document
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
    let sidebarViewModel: DoubleSidebarViewModel
    
    @ObservedObject private var serverManager = LSP.ServerManager.shared
}
