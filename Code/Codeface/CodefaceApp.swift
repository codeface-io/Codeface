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
            CodefaceView(viewModel: viewModel)
                .onChange(of: scenePhase)
            {
                switch $0
                {
                case .background: break
                case .active:
                    #if DEBUG
                    viewModel.loadLastProjectIfNoneIsActive()
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
                    viewModel.loadNewActiveprocessor(for: $0)
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
                    if let projectAnalysis = viewModel.projectProcessorVM
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
                    isPresentingFileImporter = true
                }
                .fileImporter(isPresented: $isPresentingFileImporter,
                              allowedContentTypes: [.directory],
                              allowsMultipleSelection: false)
                {
                    result in
                    
                    isPresentingFileImporter = false
                    
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
                        
                        viewModel.loadNewActiveprocessor(for: project)
                    }
                    catch { log(error) }
                }
                
                Button("Reload Last Project")
                {
                    viewModel.loadLastProject()
                }
                .keyboardShortcut("r")
                .disabled(!ProjectLocationPersister.hasPersistedLastProjectLocation)
                
                Button("Save project data ...")
                {
                    isPresentingFileExporter = true
                }
                .fileExporter(isPresented: $isPresentingFileExporter,
                              document: DataDocument(data: viewModel.projectProcessorVM?.projectData),
                              contentType: .data,
                              defaultFilename: viewModel.projectProcessorVM?.projectName ?? "Codeface_Project.cf")
                {
                    result in
                    
                    
                }
                .disabled(viewModel.projectProcessorVM?.projectData == nil)
            }
        }
    }
    
    @ObservedObject private var serverManager = LSP.ServerManager.shared
    
    @State var isPresentingProjectSelector = false
    @State var isPresentingFileImporter = false
    
    @Environment(\.scenePhase) var scenePhase
    
    @StateObject private var viewModel = Codeface()
    
    @NSApplicationDelegateAdaptor(CodefaceAppDelegate.self) private var appDelegate
    
    @State var isPresentingFileExporter = false
}

import UniformTypeIdentifiers

struct DataDocument: FileDocument
{
    static var readableContentTypes: [UTType] = [.data]
                    
    init?(data: Data?)
    {
        guard let data = data else { return nil }
        self.data = data
    }
    
    init(configuration: ReadConfiguration) throws
    {
        data = try configuration.file.regularFileContents.unwrap()
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper
    {
        .init(regularFileWithContents: data)
    }
    
    let data: Data
}
