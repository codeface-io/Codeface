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
        
        Task
        {
            // FIXME: this waiting is an ugly workaround. without it it's too early to read the windows. NSApp.windows would still be empty because windows from last session would not have been restored yet
            try await Task.sleep(for: .milliseconds(100))
            Self.openDocumentWindowIfNoneIsOpen()
        }
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
        .onChange(of: scenePhase)
        {
            // since we open a document window if none is open on launch, we know that some window scene is being created and therefore this scenePhase observation fires ...
            
            switch $0
            {
            case .background:
                log("app went to background")

            case .inactive:
                log("app became inactive")

            case .active:
                log("app became active")
                Task { TestingDashboardWindow.closeIfOpen() }

            @unknown default:
                log(warning: "app went to unknow scene phase: \(scenePhase)")
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
    
    // MARK: - Window Management On Launch
    
    private static func openDocumentWindowIfNoneIsOpen()
    {
        if !moreWindowsThanTestingDashboardAreOpen()
        {
            log("🪟 gonna open document window because none is open")
            
            /// we cannot use `newDocument` here because we can't capture `self` in the Task in the initializer ... there is simply no clean way to trigger `newDocument` on app launch 🤮
            NSDocumentController.shared.newDocument(nil)
        }
    }
    
    private static func moreWindowsThanTestingDashboardAreOpen() -> Bool
    {
        if NSApp.windows.count > 1 { return true }
        if NSApp.window(forID: TestingDashboardWindow.id) != nil { return false }
        return NSApp.windows.count == 1
    }

    @Environment(\.scenePhase) var scenePhase
    
    // MARK: - Basics
    
    private var analysis: ArchitectureAnalysis?
    {
        focusedDocumentWindow?.codebaseProcessor.state.analysis
    }
    
    @FocusedObject private var focusedDocumentWindow: DocumentWindow?
    @Environment(\.openWindow) var openWindow
}
