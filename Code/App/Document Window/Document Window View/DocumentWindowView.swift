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
                    SecondaryToolbarButtons(codebaseProcessor: documentWindow.codebaseProcessor)
                }
                
                ToolbarItemGroup(placement: .primaryAction)
                {
                    Spacer()
                    
                    PrimaryToolbarButtons(codebaseProcessor: documentWindow.codebaseProcessor)
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

struct SecondaryToolbarButtons: View
{
    var body: some View
    {
        if let analysis, !analysis.search.term.isEmpty
        {
            ToolbarFilterIndicator(analysis: analysis)
        }
    }
    
    private var analysis: CodebaseAnalysis?
    {
        codebaseProcessor.state.analysis
    }
    
    @ObservedObject var codebaseProcessor: CodebaseProcessor
}

struct PrimaryToolbarButtons: View
{
    var body: some View
    {
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
    
    private var analysis: CodebaseAnalysis?
    {
        codebaseProcessor.state.analysis
    }
    
    @ObservedObject var codebaseProcessor: CodebaseProcessor
}
