import SwiftUI
import SwiftLSP
import SwiftyToolz

struct DocumentWindowView: View
{
    var body: some View
    {
        CodebaseProcessorView(documentWindow: documentWindow,
                              codebaseProcessor: documentWindow.codebaseProcessor)
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
                    if !documentWindow.codebaseProcessor.search.term.isEmpty
                    {
                        ToolbarFilterIndicator(processorVM: documentWindow.codebaseProcessor)
                    }
                }
                
                ToolbarItemGroup(placement: .primaryAction)
                {
                    Spacer()
                    
                    Button(systemImageName: "magnifyingglass")
                    {
                        withAnimation(.easeInOut(duration: Search.toggleAnimationDuration))
                        {
                            documentWindow.codebaseProcessor.toggleSearchBar()
                        }
                    }
                    .help("Toggle the Search Filter (⇧⌘F)")
//                    .disabled(!documentWindow.projectProcessorVM.activeProcessor.isEmpty)
                    
                    DisplayModePicker(displayMode: $documentWindow.displayMode)
                    
                    Button(systemImageName: "sidebar.right")
                    {
                        withAnimation
                        {
                            documentWindow.showsRightSidebar.toggle()
                        }
                    }
                    .help("Toggle Inspector (⌥⌘0)")
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
    
    @Binding var codebaseFile: CodebaseFileDocument
    @StateObject private var documentWindow = DocumentWindow()
}
