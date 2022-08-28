import SwiftUI
import CodefaceCore
import LSPServiceKit
import SwiftyToolz

@main
struct CodefaceApp: App
{
    var body: some Scene
    {
        WindowGroup
        {
            ProjectAnalysisView(viewModel: viewModel)
                .onChange(of: scenePhase)
            {
                switch $0
                {
                case .background: break
                case .active:
                    #if DEBUG
                    viewModel.loadLastProjectIfNoneIsActive()
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
                    switch viewModel.displayMode
                    {
                    case .code: viewModel.displayMode = .treeMap
                    case .treeMap: viewModel.displayMode = .code
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
                        
                        let project = LSPProjectDescription(folder: firstURL,
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
                .disabled(!ProjectDescriptionPersister.hasPersistedLastProject)
            }
        }
        
    }
    
    @ObservedObject private var serverManager = LSPServerManager.shared
    
    @State var isPresentingProjectSelector = false
    @State var isPresentingFileImporter = false
    @Environment(\.scenePhase) var scenePhase
    
    @StateObject private var viewModel = ProjectAnalysisViewModel()
    
    @NSApplicationDelegateAdaptor(CodefaceAppDelegate.self) private var appDelegate
}
