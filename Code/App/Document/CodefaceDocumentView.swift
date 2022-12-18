import SwiftUI
import CodefaceCore
import SwiftLSP
import SwiftyToolz

struct CodefaceDocumentView: View
{
    var body: some View
    {
        CodefaceDocumentContentView(codefaceDocument: codefaceDocument,
                                    sidebarViewModel: sidebarViewModel)
        .focusedObject(codefaceDocument)
        .fileImporter(isPresented: $codefaceDocument.isPresentingFolderImporter,
                      allowedContentTypes: [.directory],
                      allowsMultipleSelection: false)
        {
            guard let folderURL = (try? $0.get())?.first else
            {
                return log(error: "Could not select code folder")
            }

            codefaceDocument.loadProcessorForSwiftPackage(from: folderURL)
        }
        .sheet(isPresented: $codefaceDocument.isPresentingCodebaseLocator)
        {
            CodebaseLocatorView(isBeingPresented: $codefaceDocument.isPresentingCodebaseLocator)
            {
                codefaceDocument.loadNewProcessor(forCodebaseFrom: $0)
            }
            .padding()
        }
        .toolbar
        {
            ToolbarItemGroup(placement: .secondaryAction)
            {
                if let processorVM = codefaceDocument.projectProcessorVM
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
                        codefaceDocument.projectProcessorVM?.toggleSearchBar()
                    }
                }
                .help("Toggle the Search Filter (⇧⌘F)")
                .disabled(codefaceDocument.projectProcessorVM == nil)
                
                DisplayModePicker(displayMode: $displayOptions.displayMode)
                    .disabled(codefaceDocument.projectProcessorVM == nil)
                
                Button(systemImageName: "sidebar.right")
                {
                    withAnimation
                    {
                        sidebarViewModel.showsRightSidebar.toggle()
                    }
                }
                .help("Toggle Inspector (⌥⌘0)")
                .disabled(codefaceDocument.projectProcessorVM == nil)
            }
        }
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
    
    @Binding var codebaseFile: CodebaseFileDocument
    let sidebarViewModel: DoubleSidebarViewModel
    
    @StateObject private var codefaceDocument = CodefaceDocument()
    @ObservedObject private var displayOptions = DisplayOptions.shared
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
