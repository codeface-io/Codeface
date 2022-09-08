import SwiftUI
import CodefaceCore
import LSPServiceKit
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
                    viewModel.loadNewActiveAnalysis(for: $0)
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
                    if let projectAnalysis = viewModel.projectAnalysis
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
                              allowsMultipleSelection: false,
                              onCompletion:
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
                        
                        let project = ProjectLocation(folder: firstURL,
                                                            language: "Swift",
                                                            codeFileEndings: ["swift"])
                        
                        viewModel.loadNewActiveAnalysis(for: project)
                    }
                    catch { log(error) }
                })
                
                Button("Reload Last Project")
                {
                    viewModel.loadLastActiveProject()
                }
                .keyboardShortcut("r")
                .disabled(!ProjectLocationPersister.hasPersistedLastProject)
            }
        }
        
    }
    
    @ObservedObject private var serverManager = LSPServerManager.shared
    
    @State var isPresentingProjectSelector = false
    @State var isPresentingFileImporter = false
    @Environment(\.scenePhase) var scenePhase
    
    private let viewModel = CodefaceViewModel()
    
    @NSApplicationDelegateAdaptor(CodefaceAppDelegate.self) private var appDelegate
}
