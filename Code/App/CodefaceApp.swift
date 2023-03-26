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
        TestingDashboardWindow.make()
        
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
                    SubscriptionButtons(documentWindow: focusedDocumentWindow)
                }
            }
            
            CommandGroup(after: .toolbar)
            {
                if let focusedDocumentWindow
                {
                    FindButtons(codebaseProcessor: focusedDocumentWindow.codebaseProcessor)
                }
            }
            
            ToolbarCommands()

            CommandGroup(replacing: .sidebar)
            {
                if let documentWindow = focusedDocumentWindow
                {
                    ViewButtons(documentWindow: documentWindow)
                    
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
    
    @Environment(\.openWindow) var openWindow
    
    // MARK: - Basics
    
    private var analysis: ArchitectureAnalysis?
    {
        focusedDocumentWindow?.codebaseProcessor.state.analysis
    }
    
    @FocusedObject private var focusedDocumentWindow: DocumentWindow?
}

struct FindButtons: View
{
    var body: some View
    {
        Button("Find and Filter")
        {
            withAnimation(.easeInOut(duration: Search.toggleAnimationDuration))
            {
                analysis?.set(searchBarIsVisible: true)
            }
            
            withAnimation(.easeInOut(duration: Search.layoutAnimationDuration))
            {
                analysis?.set(fieldIsFocused: true)
            }
        }
        .disabled(analysis == nil)
        .keyboardShortcut("f")

        Button("Toggle the Search Filter")
        {
            guard let analysis else
            {
                log(warning: "When there's no analysis, this menu option shouldn't be displayed.")
                return
            }
            
            let searchBarWillBeVisible = !analysis.search.barIsShown
            
            withAnimation(.easeInOut(duration: Search.toggleAnimationDuration))
            {
                analysis.set(searchBarIsVisible: searchBarWillBeVisible)
            }
            
            withAnimation(.easeInOut(duration: Search.layoutAnimationDuration))
            {
                analysis.set(fieldIsFocused: searchBarWillBeVisible)
            }
        }
        .disabled(analysis == nil)
        .keyboardShortcut("f", modifiers: [.shift, .command])
    }
    
    private var analysis: ArchitectureAnalysis?
    {
        codebaseProcessor.state.analysis
    }
    
    @ObservedObject var codebaseProcessor: CodebaseProcessor
}

struct ViewButtons: View
{
    var body: some View
    {
        Button("\(documentWindow.displayOptions.showLoC ? "Hide" : "Show") Lines of Code in Navigator")
        {
            documentWindow.displayOptions.showLoC.toggle()
        }
        .keyboardShortcut("l", modifiers: .command)
        
        Button("\(documentWindow.displayOptions.showsLeftSidebar ? "Hide" : "Show") the Navigator")
        {
            withAnimation
            {
                documentWindow.displayOptions.showsLeftSidebar.toggle()
            }
        }
        .keyboardShortcut("0", modifiers: .command)

        Button("\(documentWindow.displayOptions.showsRightSidebar ? "Hide" : "Show") the Inspector")
        {
            withAnimation
            {
                documentWindow.displayOptions.showsRightSidebar.toggle()
            }
        }
        .keyboardShortcut("0", modifiers: [.option, .command])
        
        Button("\(documentWindow.displayOptions.isShowingSubscriptionPanel ? "Hide" : "Show") the Subscription Panel")
        {
            documentWindow.displayOptions.isShowingSubscriptionPanel.toggle()
        }
        .keyboardShortcut("s", modifiers: [.control, .command])
        
        Divider()
        
        Button("Switch to Next Display Mode")
        {
            analysis?.switchDisplayMode()
        }
        .keyboardShortcut(.rightArrow, modifiers: .command)

        Button("Switch to Previous Display Mode")
        {
            analysis?.switchDisplayMode()
        }
        .keyboardShortcut(.leftArrow, modifiers: .command)
    }
    
    private var analysis: ArchitectureAnalysis?
    {
        documentWindow.codebaseProcessor.state.analysis
    }
    
    @ObservedObject var documentWindow: DocumentWindow
}

struct SubscriptionButtons: View
{
    var body: some View
    {
        Menu("Subscription")
        {
            Button("\(documentWindow.displayOptions.isShowingSubscriptionPanel ? "Hide" : "Show") the Subscription Panel")
            {
                documentWindow.displayOptions.isShowingSubscriptionPanel.toggle()
            }
            
            Divider()
            
            Button("Subscribe ...")
            {
                Task
                {
                    do
                    {
                        try await appStoreClient.purchase(.subscriptionLevel1)
                    }
                    catch
                    {
                        log(error: error.localizedDescription)
                    }
                }
            }
            .disabled(appStoreClient.ownsProducts)
            
            Button("Restore a Subscription ...")
            {
                Task
                {
                    await appStoreClient.forceRestoreOwnedProducts()
                }
            }
            .disabled(appStoreClient.ownsProducts)
            
            Divider()
            
            Button("Vote On New Features (Subscribers Only) ...")
            {
                openURL(URL(string: FeatureVote.urlString)!)
            }
            .disabled(!appStoreClient.ownsProducts)
            
            Button("Refund a Subscription ...")
            {
                Task
                {
                    do
                    {
                        try await appStoreClient.requestRefund(for: .subscriptionLevel1)
                    }
                    catch
                    {
                        log(error: error.localizedDescription)
                    }
                }
            }
            .disabled(!appStoreClient.ownsProducts)
        }
    }
    
    @ObservedObject var documentWindow: DocumentWindow
    @ObservedObject var appStoreClient = AppStoreClient.shared
    @Environment(\.openURL) var openURL
}
