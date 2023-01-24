import SwiftUIToolzOLD
import SwiftUI
import LSPServiceKit
import SwiftLSP
import SwiftyToolz

@main
struct CodefaceApp: App
{
    init()
    {
        /// we provide our own menu option for fullscreen because the one from SwiftUI disappears as soon as we interact with any views ... 🤮
        UserDefaults.standard.set(false, forKey: "NSFullScreenMenuItemEverywhere")
    }
    
//    var body: some Scene
//    {
//        WindowGroup {
//            ConcurrencyPOCView()
//        }
//    }
    
    //*
    var body: some Scene
    {
        DocumentGroup(newDocument: CodebaseFileDocument())
        {
            DocumentWindowView(codebaseFile: $0.$document)
        }
        .commands
        {
            CommandGroup(after: .toolbar)
            {
                Button("Find and filter")
                {
                    withAnimation(.easeInOut(duration: Search.toggleAnimationDuration))
                    {
                        analysis?.startTypingSearchTerm()
                    }
                }
                .disabled(analysis == nil)
                .keyboardShortcut("f")

                Button("Toggle the Search Filter")
                {
                    withAnimation(.easeInOut(duration: Search.toggleAnimationDuration))
                    {
                        analysis?.toggleSearchBar()
                    }
                }
                .disabled(analysis == nil)
                .keyboardShortcut("f", modifiers: [.shift, .command])
            }
            
            ToolbarCommands()

            CommandGroup(replacing: .sidebar)
            {
                Button("\((analysis?.showLoC ?? false) ? "Hide" : "Show") Lines of Code in Navigator")
                {
                    analysis?.showLoC.toggle()
                }
                .keyboardShortcut("l", modifiers: .command)
                .disabled(analysis == nil)
                
                Button("\((analysis?.showsLeftSidebar ?? false) ? "Hide" : "Show") the Navigator")
                {
                    withAnimation
                    {
                        analysis?.showsLeftSidebar.toggle()
                    }
                }
                .keyboardShortcut("0", modifiers: .command)
                .disabled(analysis == nil)

                Button("\((analysis?.showsRightSidebar ?? false) ? "Hide" : "Show") the Inspector")
                {
                    withAnimation
                    {
                        analysis?.showsRightSidebar.toggle()
                    }
                }
                .keyboardShortcut("0", modifiers: [.option, .command])
                .disabled(analysis == nil)
                
                Divider()
                
                Button("Switch to Next Display Mode")
                {
                    analysis?.switchDisplayMode()
                }
                .keyboardShortcut(.rightArrow, modifiers: .command)
                .disabled(analysis == nil)

                Button("Switch to Previous Display Mode")
                {
                    analysis?.switchDisplayMode()
                }
                .keyboardShortcut(.leftArrow, modifiers: .command)
                .disabled(analysis == nil)

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
                    focusedDocumentWindow?.isPresentingCodebaseLocator = true
                }
                .disabled(focusedDocumentWindow == nil)

                Button("Import Swift Package Folder...")
                {
                    focusedDocumentWindow?.isPresentingFolderImporter = true
                }
                .disabled(focusedDocumentWindow == nil)

                Button("Import \(lastFolderName) Again")
                {
                    focusedDocumentWindow?.runProcessorWithLastCodebase()
                }
                .keyboardShortcut("r")
                .disabled(focusedDocumentWindow == nil || !CodebaseLocationPersister.hasPersistedLastCodebaseLocation)

                Divider()
            }

//            #if DEBUG
//            CommandMenu("Develop")
//            {
//                Button("Clear Selection")
//                {
//                    focusedDocumentWindow?.selectedArtifact = nil
//                }
//
//                Button("Test XPC Service With Last Codebase")
//                {
////                    ProcessServiceTest.run()
////                    XPCExecutable.testForCodeface()
//                }
//                .keyboardShortcut("t")
//                .disabled(true)
//            }
//            #endif
        }
    }
    // */
    
    private var lastFolderName: String
    {
        if let lastFolder = focusedDocumentWindow?.lastLocation?.folder
        {
            return "\"" + lastFolder.lastPathComponent + "\""
        }
        else
        {
            return "Last Folder"
        }
    }
    
    // MARK: - Basics
    
    private var analysis: CodebaseAnalysis?
    {
        focusedDocumentWindow?.codebaseProcessor.state.analysis
    }
    
    @FocusedObject private var focusedDocumentWindow: DocumentWindow?
}
