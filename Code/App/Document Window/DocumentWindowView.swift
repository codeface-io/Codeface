import SwiftUI
import CodefaceCore
import SwiftLSP
import SwiftyToolz

struct DocumentWindowView: View
{
    var body: some View
    {
        DocumentWindowContentView(codefaceDocument: documentWindow)
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
                    if let processorVM = documentWindow.projectProcessorVM
                    {
                        ToolbarFilterIndicator(processorVM: processorVM)
                    }
                }
                
                ToolbarItemGroup(placement: .primaryAction)
                {
                    Spacer()
                    
                    Button(systemImageName: "magnifyingglass")
                    {
                        withAnimation(.easeInOut(duration: SearchVM.toggleAnimationDuration))
                        {
                            documentWindow.projectProcessorVM?.toggleSearchBar()
                        }
                    }
                    .help("Toggle the Search Filter (⇧⌘F)")
                    .disabled(documentWindow.projectProcessorVM == nil)
                    
                    DisplayModePicker(displayMode: $documentWindow.displayMode)
                        .disabled(documentWindow.projectProcessorVM == nil)
                    
                    Button(systemImageName: "sidebar.right")
                    {
                        withAnimation
                        {
                            documentWindow.showsRightSidebar.toggle()
                        }
                    }
                    .help("Toggle Inspector (⌥⌘0)")
                    .disabled(documentWindow.projectProcessorVM == nil)
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

struct DocumentWindowContentView: View
{
    var body: some View
    {
        if let processorVM = codefaceDocument.projectProcessorVM
        {
            CodebaseProcessingView(codefaceDocument: codefaceDocument,
                                   processorVM: processorVM)
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
    
    @ObservedObject var codefaceDocument: DocumentWindow
    @ObservedObject private var serverManager = LSP.ServerManager.shared
}
