import SwiftUIToolzOLD
import SwiftUI
import SwiftLSP
import SwiftyToolz

@main
struct CodefaceApp: App
{
    init()
    {
        LogViewModel.shared.startObservingLog()
        
        Task
        {
            do
            {
                try await AppStoreClient.shared.fetch(product: .subscriptionLevel1)
            }
            catch
            {
                log(error: error.localizedDescription)
            }
        }
        
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
            CommandGroup(after: .appInfo)
            {
                if let focusedDocumentWindow
                {
                    SubscriptionMenu(displayOptions: focusedDocumentWindow.displayOptions)
                }
            }
            
            CommandGroup(after: .toolbar)
            {
                if let focusedDocumentWindow
                {
                    FindAndFilterMenuOptions(codebaseProcessor: focusedDocumentWindow.codebaseProcessor)
                }
            }
            
            ToolbarCommands()

            CommandGroup(replacing: .sidebar)
            {
                if let documentWindow = focusedDocumentWindow
                {
                    ViewButtons(codebaseProcessor: documentWindow.codebaseProcessor,
                                displayOptions: documentWindow.displayOptions)
                    
                    Divider()
                }
                
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
                
                Divider()
                
                Button("Show Testing Dashboard")
                {
                    openWindow(id: TestingDashboardWindow.id)
                }
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
        }
        
        TestingDashboardWindow.make()
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
    
    private var analysis: ArchitectureAnalysis?
    {
        focusedDocumentWindow?.codebaseProcessor.state.analysis
    }
    
    @FocusedObject private var focusedDocumentWindow: DocumentWindow?
    @Environment(\.openWindow) var openWindow
    @NSApplicationDelegateAdaptor(CodefaceAppDelegate.self) var appDelegate
}

/// For Window Management On Launch. We have to use the app delegate, because onChange(of: scenePhase) does not work when no window is being opened on launch in the first place ... 🤮
@MainActor class CodefaceAppDelegate: NSObject, NSApplicationDelegate
{
    func applicationDidBecomeActive(_ notification: Notification)
    {
        log("app did become active")
        Self.openDocumentWindowIfNoneIsOpen()
        TestingDashboardWindow.closeIfOpen()
    }
    
    private static func openDocumentWindowIfNoneIsOpen()
    {
        if !moreWindowsThanTestingDashboardAreOpen()
        {
            log("🪟 gonna open document window because none is open")
            NSDocumentController.shared.newDocument(nil)
        }
    }
    
    private static func moreWindowsThanTestingDashboardAreOpen() -> Bool
    {
        if NSApp.windows.count > 1 { return true }
        if NSApp.window(forID: TestingDashboardWindow.id) != nil { return false }
        return NSApp.windows.count == 1
    }
}
