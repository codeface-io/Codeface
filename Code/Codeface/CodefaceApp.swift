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
            
//            Text("codebase named \(documentConfiguration.document.codebase.name)")
            CodefaceView(viewModel: codeface)
                .onChange(of: scenePhase)
            {
                switch $0
                {
                case .background: break
                case .active:
                    #if DEBUG
                    codeface.loadLastProjectIfNoneIsLoaded()
                    #else
                    break
                    #endif
                case .inactive: break
                @unknown default: break
                }
            }
            .sheet(isPresented: $isPresentingProjectSelector)
            {
                ProjectPickerView(isBeingPresented: $isPresentingProjectSelector)
                {
                    codeface.loadNewProject(from: $0)
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
                    if let projectAnalysis = codeface.projectProcessorVM
                    {
                        switch projectAnalysis.displayMode
                        {
                        case .code: projectAnalysis.displayMode = .treeMap
                        case .treeMap: projectAnalysis.displayMode = .code
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
                    isPresentingProjectSelector = true
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
                        return log(error: "Could not select project folder")
                    }
                    
                    codeface.loadSwiftPackage(from: folderURL)
                }
                
                Button("Reload Last Codebase")
                {
                    codeface.loadLastProject()
                }
                .keyboardShortcut("r")
                .disabled(!ProjectLocationPersister.hasPersistedLastProjectLocation)
                
                Divider()
                
                Button("Import Codebase From File...")
                {
                    isPresentingFileImporter = true
                }
                .keyboardShortcut("i")
                .fileImporter(isPresented: $isPresentingFileImporter,
                              allowedContentTypes: [.data],
                              allowsMultipleSelection: false)
                {
                    guard let fileURL = (try? $0.get())?.first else
                    {
                        return log(error: "Couldn't select project data file")
                    }
                    
                    codeface.loadProject(from: fileURL)
                }
                
                Button("Export Codebase to File...")
                {
                    isPresentingFileExporter = true
                }
                .keyboardShortcut("e")
                .disabled(codeface.projectData == nil)
                .fileExporter(isPresented: $isPresentingFileExporter,
                              document: makeCodebaseFileDocument(),
                              contentType: .data,
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
    
    // MARK: - Import / Export Files
    
    private func makeCodebaseFileDocument() -> CodebaseFileDocument?
    {
        guard let codebase = codeface.projectData else { return nil }
        return CodebaseFileDocument(codebase: codebase)
    }
    
    @State private var isPresentingFileExporter = false
    @State private var isPresentingFileImporter = false
    
    // MARK: - Load a Project
    
    @State private var isPresentingProjectSelector = false
    @State private var isPresentingFolderImporter = false
    
    // MARK: - Basics
    
    @Environment(\.scenePhase) private var scenePhase
    @NSApplicationDelegateAdaptor(CodefaceAppDelegate.self) private var appDelegate
    
    @ObservedObject private var serverManager = LSP.ServerManager.shared
    @StateObject private var codeface = Codeface()
}
