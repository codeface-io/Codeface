import SwiftUI
import CodefaceCore
import SwiftLSP

struct CodefaceDocumentView: View
{
    var body: some View
    {
        CodefaceDocumentContentView(codefaceDocument: codefaceDocument,
                                    columnVisibility: $columnVisibility,
                                    showsInspector: $showsInspector)
            .focusedSceneValue(\.document, codefaceDocument)
            .onReceive(codefaceDocument.$codebase) {
                if let updatedCodebase = $0
                {
                    codebaseFile.codebase = updatedCodebase
                }
            }
            .onAppear {
                if let codebase = codebaseFile.codebase
                {
                    codefaceDocument.loadProcessor(for: codebase)
                }
            }
    }
    
    @StateObject private var codefaceDocument = CodefaceDocument()
    @Binding var codebaseFile: CodebaseFileDocument
    @Binding var columnVisibility: NavigationSplitViewVisibility
    @Binding var showsInspector: Bool
}



struct CodefaceDocumentContentView: View
{
    var body: some View
    {
        if let processorVM = codefaceDocument.projectProcessorVM
        {
            DocumentProcessingView(codefaceDocument: codefaceDocument,
                                   processorVM: processorVM,
                                   columnVisibility: $columnVisibility,
                                   showsInspector: $showsInspector)
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
    @Binding var columnVisibility: NavigationSplitViewVisibility
    @Binding var showsInspector: Bool
    
    @ObservedObject private var serverManager = LSP.ServerManager.shared
}
