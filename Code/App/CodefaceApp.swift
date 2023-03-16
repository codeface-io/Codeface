import SwiftUIToolzOLD
import SwiftUI
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
        Window("Tester Dashboard", id: "debug-log")
        {
            Button("Log App Store Transactions History")
            {
                AppStoreClient.shared.debugLogAllTransactions()
            }.padding()
            
            List(logViewModel.logEntries.indices, id: \.self)
            {
                Text(logViewModel.logEntries[$0].message)
            }
        }
        
        DocumentGroup(newDocument: CodebaseFileDocument())
        {
            DocumentWindowView(codebaseFile: $0.$document)
        }
        .commands
        {
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
                if let focusedDocumentWindow
                {
                    ViewButtons(codebaseProcessor: focusedDocumentWindow.codebaseProcessor)
                    
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
    
    // MARK: - Basics
    
    private var analysis: ArchitectureAnalysis?
    {
        focusedDocumentWindow?.codebaseProcessor.state.analysis
    }
    
    @FocusedObject private var focusedDocumentWindow: DocumentWindow?
    
    @StateObject private var logViewModel = LogViewModel()
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
    }
    
    private var analysis: ArchitectureAnalysis?
    {
        codebaseProcessor.state.analysis
    }
    
    @ObservedObject var codebaseProcessor: CodebaseProcessor
}

class LogViewModel: LogObserver, ObservableObject
{
    init()
    {
        Log.shared.add(observer: self)
    }
    
    func receive(_ entry: Log.Entry)
    {
        logEntries.append(entry)
    }
    
    @Published var logEntries = [Log.Entry]()
}
