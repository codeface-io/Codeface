import SwiftUIToolzOLD
import SwiftUI
import CodefaceCore
import LSPServiceKit
import SwiftLSP
import SwiftyToolz

@main
struct CodefaceApp: App
{
    init()
    {
        ReadableError.readableMessageForError = { $0.localizedDescription }
    }
    
    var body: some Scene
    {
        DocumentGroup(newDocument: CodebaseFileDocument())
        {
            _ in
            
            
            
            ProofOfConceptView()
            
//            CodefaceDocumentView(codebaseFile: $0.$document,
//                                 columnVisibility: $columnVisibility,
//                                 showsInspector: $showsInspector)
//                .sheet(isPresented: $isPresentingCodebaseLocator)
//                {
//                    CodebaseLocatorView(isBeingPresented: $isPresentingCodebaseLocator)
//                    {
//                        focusedDocument?.loadNewProcessor(forCodebaseFrom: $0)
//                    }
//                    .padding()
//                }
        }
        .commands
        {
            SidebarCommands()

            CommandGroup(replacing: .sidebar)
            {
                Button("Switch Display Mode")
                {
                    focusedDocument?.switchDisplayMode()
                }
                .disabled(focusedDocument?.projectProcessorVM == nil)
                .keyboardShortcut(.space, modifiers: .shift)
                
                Divider()

                Button("\(columnVisibility == .all ? "Hide" : "Show") Navigator")
                {
                    withAnimation
                    {
                        if columnVisibility == .all
                        {
                            columnVisibility = .detailOnly
                        }
                        else
                        {
                            columnVisibility = .all
                        }
                    }
                }
                .keyboardShortcut("0", modifiers: .command)
                
                // FIXME: the following commands are only available when there is a projectProcessorVM, i.e. when some artifact is selected, but apparently focusedDocument as a @FocusedValue is not being observed! so the button disabling does not work.
                
                Button("\(showsInspector ? "Hide" : "Show") Inspector")
                {
                    withAnimation
                    {
                        showsInspector.toggle()
                    }
                }
//                .disabled(focusedDocument?.projectProcessorVM == nil)
                .keyboardShortcut("0", modifiers: [.option, .command])
                
                Button("Find and filter")
                {
                    withAnimation(.easeInOut(duration: SearchVM.visibilityToggleAnimationDuration))
                    {
                        focusedDocument?.projectProcessorVM?.userWantsToFindAndFilter()
                    }
                }
//                .disabled(focusedDocument?.projectProcessorVM == nil)
                .keyboardShortcut("f", modifiers: .command)
                
                Divider()
            }
            
            CommandGroup(replacing: .help)
            {
                HelpLink.lspService
                
                HelpLink.documentation
            }
            
            CommandGroup(replacing: .newItem)
            {
                Button("New Empty Codebase File") {
                    NSDocumentController.shared.newDocument(nil)
                }
                .keyboardShortcut("n")
                
                Button("Open a Codebase File ...") {
                    NSDocumentController.shared.openDocument(nil)
                }
                
                // TODO: Bring back menu item "Open Recent" programmatically!
            }
            
            CommandGroup(before: .undoRedo)
            {
                Button("Import Code Folder...")
                {
                    isPresentingCodebaseLocator = true
                }
                .disabled(focusedDocument == nil)
                
                Button("Import Swift Package Folder...")
                {
                    isPresentingFolderImporter = true
                }
                .disabled(focusedDocument == nil)
                .fileImporter(isPresented: $isPresentingFolderImporter,
                              allowedContentTypes: [.directory],
                              allowsMultipleSelection: false)
                {
                    guard let folderURL = (try? $0.get())?.first else
                    {
                        return log(error: "Could not select code folder")
                    }
                    
                    focusedDocument?.loadProcessorForSwiftPackage(from: folderURL)
                }
                
                Button("Import \(lastFolderName) Again")
                {
                    focusedDocument?.loadProcessorForLastCodebase()
                }
                .keyboardShortcut("r")
                .disabled(focusedDocument == nil || !CodebaseLocationPersister.hasPersistedLastCodebaseLocation)
                
//                #if DEBUG
//                Button("Test XPC Service With Last Codebase")
//                {
//                    ProcessServiceTest.run()
////                    XPCExecutable.testForCodeface()
//                }
//                .keyboardShortcut("t")
//                #endif

                Divider()
            }
        }
    }
    
    private var lastFolderName: String
    {
        CodebaseLocationPersister.cachedLocation?.folder.lastPathComponent ?? "Last Folder"
    }
    
    // MARK: - Load Codebase from Folder
    
    @State private var isPresentingCodebaseLocator = false
    @State private var isPresentingFolderImporter = false
    
    // MARK: - Basics
    
    @State var columnVisibility = NavigationSplitViewVisibility.all
    @State var showsInspector = false
    
    @FocusedValue(\.document) var focusedDocument: CodefaceDocument?
}
