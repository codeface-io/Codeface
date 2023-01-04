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
        ReadableError.readableMessageForError = { $0.localizedDescription }
        
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
                        focusedDocumentWindow?.codebaseProcessor.startTypingSearchTerm()
                    }
                }
                .disabled(focusedDocumentWindow?.codebaseProcessor == nil)
                .keyboardShortcut("f")

                Button("Toggle the Search Filter")
                {
                    withAnimation(.easeInOut(duration: Search.toggleAnimationDuration))
                    {
                        focusedDocumentWindow?.codebaseProcessor.toggleSearchBar()
                    }
                }
                .disabled(focusedDocumentWindow?.codebaseProcessor == nil)
                .keyboardShortcut("f", modifiers: [.shift, .command])
            }
            
            ToolbarCommands()

            CommandGroup(replacing: .sidebar)
            {
                Button("\((focusedDocumentWindow?.codebaseProcessor.showLoC ?? false) ? "Hide" : "Show") Lines of Code in Navigator")
                {
                    focusedDocumentWindow?.codebaseProcessor.showLoC.toggle()
                }
                .keyboardShortcut("l", modifiers: .command)
                .disabled(focusedDocumentWindow?.codebaseProcessor == nil)
                
                Button("\((focusedDocumentWindow?.showsLeftSidebar ?? false) ? "Hide" : "Show") the Navigator")
                {
                    withAnimation
                    {
                        focusedDocumentWindow?.showsLeftSidebar.toggle()
                    }
                }
                .keyboardShortcut("0", modifiers: .command)
                .disabled(focusedDocumentWindow?.codebaseProcessor == nil)

                Button("\((focusedDocumentWindow?.showsRightSidebar ?? false) ? "Hide" : "Show") the Inspector")
                {
                    withAnimation
                    {
                        focusedDocumentWindow?.showsRightSidebar.toggle()
                    }
                }
                .keyboardShortcut("0", modifiers: [.option, .command])
                .disabled(focusedDocumentWindow?.codebaseProcessor == nil)
                
                Divider()
                
                Button("Switch to Next Display Mode")
                {
                    focusedDocumentWindow?.switchDisplayMode()
                }
                .keyboardShortcut(.rightArrow, modifiers: .command)
                .disabled(focusedDocumentWindow?.codebaseProcessor == nil)

                Button("Switch to Previous Display Mode")
                {
                    focusedDocumentWindow?.switchDisplayMode()
                }
                .keyboardShortcut(.leftArrow, modifiers: .command)
                .disabled(focusedDocumentWindow?.codebaseProcessor == nil)

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
                    focusedDocumentWindow?.loadProcessorForLastCodebase()
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
    
    @FocusedObject private var focusedDocumentWindow: DocumentWindow?
}
