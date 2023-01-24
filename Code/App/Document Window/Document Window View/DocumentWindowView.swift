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
        CodebaseProcessorView(codebaseProcessor: documentWindow.codebaseProcessor)
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
                    if let analysis, !analysis.search.term.isEmpty
                    {
                        ToolbarFilterIndicator(analysis: analysis)
                    }
                }
                
                ToolbarItemGroup(placement: .primaryAction)
                {
                    Spacer()
                    
                    Button(systemImageName: "magnifyingglass")
                    {
                        withAnimation(.easeInOut(duration: Search.toggleAnimationDuration))
                        {
                            analysis?.toggleSearchBar()
                        }
                    }
                    .help("Toggle the Search Filter (⇧⌘F)")
                    .disabled(analysis == nil)
                    
                    DisplayModePicker(displayMode: .init(get: {
                        analysis?.displayMode ?? .treeMap
                    }, set: { newDisplayMode in
                        analysis?.displayMode = newDisplayMode
                    }))
                    .disabled(analysis == nil)
                    
                    Button(systemImageName: "sidebar.right")
                    {
                        withAnimation
                        {
                            analysis?.showsRightSidebar.toggle()
                        }
                    }
                    .help("Toggle Inspector (⌥⌘0)")
                    .disabled(analysis == nil)
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
    
    private var analysis: CodebaseAnalysis?
    {
        documentWindow.codebaseProcessor.state.analysis
    }
    
    @Binding var codebaseFile: CodebaseFileDocument
    @StateObject private var documentWindow: DocumentWindow
}
