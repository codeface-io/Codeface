import SwiftUI
import SwiftLSP
import SwiftyToolz

struct DocumentWindowView: View
{
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
                
                documentWindow.loadProcessorForSwiftPackage(from: folderURL)
            }
            .sheet(isPresented: $documentWindow.isPresentingCodebaseLocator)
            {
                CodebaseLocator(isBeingPresented: $documentWindow.isPresentingCodebaseLocator)
                {
                    documentWindow.loadNewProcessor(forCodebaseFrom: $0)
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
            .onReceive(documentWindow.$codebase)
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
                    documentWindow.loadProcessor(for: codebase)
                }
            }
    }
    
    private var analysis: CodebaseAnalysis?
    {
        documentWindow.codebaseProcessor.state.analysis
    }
    
    @Binding var codebaseFile: CodebaseFileDocument
    @StateObject private var documentWindow = DocumentWindow()
}
