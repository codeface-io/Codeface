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
            CodebaseWindowView(codebaseFile: $0.$document)
        }
        .commands
        {
            CommandGroup(replacing: .appInfo)
            {
                Button("About Codeface")
                {
                    openWindow(id: AboutPanel.id)
                }
            }
            
            CommandGroup(after: .appInfo)
            {
                if let focusedDocumentWindow
                {
                    PurchaseMenu(displayOptions: focusedDocumentWindow.displayOptions)
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
            
            CommandGroup(replacing: .undoRedo) {} // hides this

            CommandGroup(replacing: .sidebar)
            {
                if let documentWindow = focusedDocumentWindow
                {
                    ViewButtons(codebaseProcessor: documentWindow.codebaseProcessor,
                                displayOptions: documentWindow.displayOptions)
                    
                    Divider()
                }
                
                Toggle("Use Consistent Animations (Slower)",
                       isOn: $settings.useCorrectAnimations)
                    .help("Animating layout changes with visual consistency is slower in scopes that contain many lines of code. You might need to deactive this at higher levels of large codebases.")
                    .keyboardShortcut("a", modifiers: [.control])
                
                Button("Toggle Fullscreen")
                {
                    Task { NSApp.toggleFullscreen() }
                }
                .keyboardShortcut("f", modifiers: [.control, .command])
            }

            CommandGroup(replacing: .help)
            {
                DocumentLink.lspService

                DocumentLink.documentation
                
                Divider()
                
                Button("Show Testing Dashboard")
                {
                    openWindow(id: TestingDashboard.id)
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
            
                Divider()
                
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
        
        TestingDashboard()
        
        AboutPanel(privacyPolicyURL: .privacyPolicy,
                   licenseAgreementURL: .licenseAgreement)
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
    
    @ObservedObject private var settings = GlobalSettings.shared
    @FocusedObject private var focusedDocumentWindow: CodebaseWindow?
    @Environment(\.openWindow) var openWindow
    @NSApplicationDelegateAdaptor(CodefaceAppDelegate.self) var appDelegate
}
