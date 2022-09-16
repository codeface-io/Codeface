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
        WindowGroup
        {
            CodefaceView(viewModel: codeface)
                .onChange(of: scenePhase)
            {
                switch $0
                {
                case .background: break
                case .active:
                    #if DEBUG
                    codeface.loadLastProjectIfNoneIsActive()
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
                    codeface.loadNewActiveprocessor(for: $0)
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
                Button("Load Code Base ...")
                {
                    isPresentingProjectSelector = true
                }
                .keyboardShortcut("n")
                
                Button("Load Swift Package ...")
                {
                    isPresentingFolderImporter = true
                }
                .fileImporter(isPresented: $isPresentingFolderImporter,
                              allowedContentTypes: [.directory],
                              allowsMultipleSelection: false)
                {
                    result in
                    
                    isPresentingFolderImporter = false
                    
                    do
                    {
                        let urls = try result.get()
                        
                        guard let firstURL = urls.first else
                        {
                            throw "Empty array of URLs"
                        }
                        
                        let project = LSP.ProjectLocation(folder: firstURL,
                                                          language: "Swift",
                                                          codeFileEndings: ["swift"])
                        
                        codeface.loadNewActiveprocessor(for: project)
                    }
                    catch { log(error) }
                }
                
                Button("Reload Last Project")
                {
                    codeface.loadLastProject()
                }
                .keyboardShortcut("r")
                .disabled(!ProjectLocationPersister.hasPersistedLastProjectLocation)
                
                Button("Load project data from file ...")
                {
                    isPresentingFileImporter = true
                }
                .fileImporter(isPresented: $isPresentingFileImporter,
                              allowedContentTypes: [.data],
                              allowsMultipleSelection: false)
                {
                    result in
                    
                    guard let fileURLs = try? result.get(),
                          let fileURL = fileURLs.first
                    else
                    {
                        log(error: "Couldn't select project data file")
                        return
                    }
                    
                    guard let fileData = Data(from: fileURL) else
                    {
                        log(error: "Couldn't read project data file")
                        return
                    }
                    
                    guard let projectData = CodeFolder(fileData) else
                    {
                        log(error: "Couldn't decode project data")
                        return
                    }
                    
                    
                }
                
                Button("Save project data ...")
                {
                    isPresentingFileExporter = true
                }
                .fileExporter(isPresented: $isPresentingFileExporter,
                              document: makeProjectDataFileDocument(),
                              contentType: .data,
                              defaultFilename: codeface.defaultProjectFileName)
                {
                    result in
                    
                    
                }
                .disabled(codeface.projectData == nil)
            }
        }
    }
    
    // MARK: - Import / Export Files
    
    private func makeProjectDataFileDocument() -> DataFileDocument?
    {
        guard let encodedProjectData = codeface.projectData?.encodeForFileStorage() else
        {
            return nil
        }
        
        return DataFileDocument(data: encodedProjectData)
    }
    
    @State private var isPresentingFileExporter = false
    @State private var isPresentingFileImporter = false
    
    // MARK: - Loading a Project
    
    @State private var isPresentingProjectSelector = false
    @State private var isPresentingFolderImporter = false
    
    // MARK: - Basics
    
    @Environment(\.scenePhase) private var scenePhase
    @NSApplicationDelegateAdaptor(CodefaceAppDelegate.self) private var appDelegate
    
    @ObservedObject private var serverManager = LSP.ServerManager.shared
    @StateObject private var codeface = Codeface()
}
