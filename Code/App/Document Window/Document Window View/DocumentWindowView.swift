import SwiftUI
import SwiftLSP
import SwiftyToolz

struct DocumentWindowView: View
{
    internal init(codebaseFile: Binding<CodebaseFileDocument>)
    {
        _codebaseFile = codebaseFile
        
        let codebase = codebaseFile.wrappedValue.codebase
        _documentWindow = StateObject(wrappedValue: DocumentWindow(codebase: codebase))
    }
    
    var body: some View
    {
        CodebaseProcessorView(codebaseProcessor: documentWindow.codebaseProcessor,
                              displayOptions: documentWindow.displayOptions)
            .focusedSceneObject(documentWindow)
            .fileImporter(isPresented: $documentWindow.isPresentingFolderImporter,
                          allowedContentTypes: [.directory],
                          allowsMultipleSelection: false)
            {
                guard let folderURL = (try? $0.get())?.first else
                {
                    return log(error: "Could not select code folder")
                }
                
                documentWindow.runProcessorWithSwiftPackageCodebase(at: folderURL)
            }
            .sheet(isPresented: $documentWindow.isPresentingCodebaseLocator)
            {
                CodebaseLocator(isBeingPresented: $documentWindow.isPresentingCodebaseLocator)
                {
                    documentWindow.runProcessor(withCodebaseAtNewLocation: $0)
                }
                .padding()
            }
            .toolbar
            {
                ToolbarItemGroup(placement: .secondaryAction)
                {
                    SecondaryToolbarButtons(codebaseProcessor: documentWindow.codebaseProcessor)
                }
                
                ToolbarItemGroup(placement: .primaryAction)
                {
                    Spacer()
                    
                    PrimaryToolbarButtons(codebaseProcessor: documentWindow.codebaseProcessor,
                                          displayOptions: documentWindow.displayOptions)
                }
            }
            .onReceive(documentWindow.events)
            {
                switch $0
                {
                case .didRetrieveNewCodebase(let codebase):
                    codebaseFile.codebase = codebase
                }
            }
    }
    
    @Binding var codebaseFile: CodebaseFileDocument
    @StateObject private var documentWindow: DocumentWindow
}
