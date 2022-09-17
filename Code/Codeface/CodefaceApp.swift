import SwiftUIToolz
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
        DocumentGroup(newDocument: CodebaseFileDocument(codebase: CodeFolder()))
        {
            documentConfiguration in
            
            CodefaceView(viewModel: codeface)
                .onChange(of: scenePhase)
            {
                switch $0
                {
                case .background: break
                case .active:
                    #if DEBUG
                    codeface.loadProcessorForLastCodebaseIfNoneIsLoaded()
                    #else
                    break
                    #endif
                case .inactive: break
                @unknown default: break
                }
            }
            .sheet(isPresented: $isPresentingCodebaseLocator)
            {
                CodebaseLocatorView(isBeingPresented: $isPresentingCodebaseLocator)
                {
                    codeface.loadNewProcessor(forCodebaseFrom: $0)
                }
                .padding()
            }
        }
        .commands
        {
            SidebarCommands()
            
            CommandGroup(before: .sidebar)
            {
                Button("Switch View Mode")
                {
                    if let processorVM = codeface.projectProcessorVM
                    {
                        switch processorVM.displayMode
                        {
                        case .code: processorVM.displayMode = .treeMap
                        case .treeMap: processorVM.displayMode = .code
                        }
                    }
                }
                .keyboardShortcut(.space, modifiers: .shift)
                
                Divider()
            }
            
            CommandGroup(replacing: .help)
            {
                if serverManager.serverIsWorking
                {
                    Link("Open LSPService info page",
                         destination: lspServicePage)
                }
                else
                {
                    Link("Learn how to see symbols and dependencies",
                         destination: lspServicePage)
                }
            }
            
            CommandGroup(replacing: .newItem)
            {
                Button("Load Codebase...")
                {
                    isPresentingCodebaseLocator = true
                }
                .keyboardShortcut("n")
                
                Button("Load Swift Package...")
                {
                    isPresentingFolderImporter = true
                }
                .fileImporter(isPresented: $isPresentingFolderImporter,
                              allowedContentTypes: [.directory],
                              allowsMultipleSelection: false)
                {
                    guard let folderURL = (try? $0.get())?.first else
                    {
                        return log(error: "Could not select codebase folder")
                    }
                    
                    codeface.loadProcessorForSwiftPackage(from: folderURL)
                }
                
                Button("Reload Last Codebase")
                {
                    codeface.loadProcessorForLastCodebase()
                }
                .keyboardShortcut("r")
                .disabled(!CodebaseLocationPersister.hasPersistedLastCodebaseLocation)
                
                Divider()
                
                Button("Import Codebase From File...")
                {
                    isPresentingFileImporter = true
                }
                .keyboardShortcut("i")
                .fileImporter(isPresented: $isPresentingFileImporter,
                              allowedContentTypes: [.codebase],
                              allowsMultipleSelection: false)
                {
                    guard let fileURL = (try? $0.get())?.first else
                    {
                        return log(error: "Couldn't select codebase file")
                    }
                    
                    codeface.loadProcessor(forCodebaseFrom: fileURL)
                }
                
                Button("Export Codebase to File...")
                {
                    isPresentingFileExporter = true
                }
                .keyboardShortcut("e")
                .disabled(codeface.codebase == nil)
                .fileExporter(isPresented: $isPresentingFileExporter,
                              document: makeCodebaseFileDocument(),
                              contentType: .codebase,
                              defaultFilename: codeface.defaultProjectFileName)
                {
                    if case .failure(let error) = $0
                    {
                        log(error)
                    }
                }
            }
        }
    }
    
    // MARK: - Import / Export Codebase File
    
    private func makeCodebaseFileDocument() -> CodebaseFileDocument?
    {
        guard let codebase = codeface.codebase else { return nil }
        return CodebaseFileDocument(codebase: codebase)
    }
    
    @State private var isPresentingFileExporter = false
    @State private var isPresentingFileImporter = false
    
    // MARK: - Load Codebase from Folder
    
    @State private var isPresentingCodebaseLocator = false
    @State private var isPresentingFolderImporter = false
    
    // MARK: - Basics
    
    @Environment(\.scenePhase) private var scenePhase
    @NSApplicationDelegateAdaptor(CodefaceAppDelegate.self) private var appDelegate
    
    @ObservedObject private var serverManager = LSP.ServerManager.shared
    @StateObject private var codeface = Codeface()
}
