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
        
        /// we provide our own menu option for fullscreen because the one from SwiftUI disappears as soon as we interact with any views ... 🤮
        UserDefaults.standard.set(false, forKey: "NSFullScreenMenuItemEverywhere")
    }
    
//    var body: some Scene
//    {
//        DocumentGroup(newDocument: CodebaseFileDocument()) { _ in
//            ProofOfConceptView()
//                .toolbar(.hidden, for: .windowToolbar)
//        }
//        .windowStyle(.hiddenTitleBar)
//        .windowToolbarStyle(.unified)
//    }
    
    //*
    var body: some Scene
    {
        DocumentGroup(newDocument: CodebaseFileDocument())
        {
            CodefaceDocumentView(codebaseFile: $0.$document,
                                 sidebarViewModel: sidebarViewModel)
                .sheet(isPresented: $isPresentingCodebaseLocator)
                {
                    CodebaseLocatorView(isBeingPresented: $isPresentingCodebaseLocator)
                    {
                        focusedDocument?.loadNewProcessor(forCodebaseFrom: $0)
                    }
                    .padding()
                }
        }
        .commands
        {
            CommandGroup(after: .toolbar)
            {
                Button("Find and filter")
                {
                    withAnimation(.easeInOut(duration: SearchVM.toggleAnimationDuration))
                    {
                        focusedDocument?.projectProcessorVM?.startTypingSearchTerm()
                    }
                }
                .disabled(focusedDocument?.projectProcessorVM == nil)
                .keyboardShortcut("f")

                Button("Toggle the Search Filter")
                {
                    withAnimation(.easeInOut(duration: SearchVM.toggleAnimationDuration))
                    {
                        focusedDocument?.projectProcessorVM?.toggleSearchBar()
                    }
                }
                .disabled(focusedDocument?.projectProcessorVM == nil)
                .keyboardShortcut("f", modifiers: [.shift, .command])
            }
            
            ToolbarCommands()

            CommandGroup(replacing: .sidebar)
            {
                Button("\(displayOptions.showLoC ? "Hide" : "Show") Lines of Code in Navigator")
                {
                    displayOptions.showLoC.toggle()
                }
                .keyboardShortcut("l", modifiers: .command)
                .disabled(focusedDocument?.projectProcessorVM == nil)
                
                Button("\(sidebarViewModel.showsLeftSidebar ? "Hide" : "Show") the Navigator")
                {
                    withAnimation
                    {
                        sidebarViewModel.showsLeftSidebar.toggle()
                    }
                }
                .keyboardShortcut("0", modifiers: .command)
                .disabled(focusedDocument?.projectProcessorVM == nil)

                Button("\(sidebarViewModel.showsRightSidebar ? "Hide" : "Show") the Inspector")
                {
                    withAnimation
                    {
                        sidebarViewModel.showsRightSidebar.toggle()
                    }
                }
                .keyboardShortcut("0", modifiers: [.option, .command])
                .disabled(focusedDocument?.projectProcessorVM == nil)
                
                Divider()
                
                Button("Switch to Next Display Mode")
                {
                    displayOptions.switchDisplayMode()
                }
                .keyboardShortcut(.rightArrow, modifiers: .command)
                .disabled(focusedDocument?.projectProcessorVM == nil)

                Button("Switch to Previous Display Mode")
                {
                    displayOptions.switchDisplayMode()
                }
                .keyboardShortcut(.leftArrow, modifiers: .command)
                .disabled(focusedDocument?.projectProcessorVM == nil)

                Divider()
                
                Button("Toggle Fullscreen")
                {
                    Task { NSApp.toggleFullscreen() }
                }
                .keyboardShortcut("f", modifiers: [.control, .command])
            }

            CommandGroup(replacing: .help)
            {
                HelpLink.lspService

                HelpLink.documentation
            }

            CommandGroup(replacing: .newItem)
            {
                Button("New Empty Codebase File")
                {
                    NSDocumentController.shared.newDocument(nil)
                }
                .keyboardShortcut("n")

                Button("Open a Codebase File ...")
                {
                    NSDocumentController.shared.openDocument(nil)
                }
                .keyboardShortcut("o")

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

                Divider()
            }

            #if DEBUG
            CommandMenu("Develop")
            {
                Button("Clear Selection")
                {
                    focusedDocument?.selectedArtifact = nil
                }

                Button("Test XPC Service With Last Codebase")
                {
//                    ProcessServiceTest.run()
//                    XPCExecutable.testForCodeface()
                }
                .keyboardShortcut("t")
                .disabled(true)
            }
            #endif
        }
    }
    // */
    
    private var lastFolderName: String
    {
        CodebaseLocationPersister.cachedLocation?.folder.lastPathComponent ?? "Last Folder"
    }
    
    // MARK: - Load Codebase from Folder
    
    @State private var isPresentingCodebaseLocator = false
    @State private var isPresentingFolderImporter = false
    
    // MARK: - Basics
    
    @ObservedObject private var displayOptions = DisplayOptions.shared
    @StateObject var sidebarViewModel = DoubleSidebarViewModel()
    @FocusedObject var focusedDocument: CodefaceDocument?
}
