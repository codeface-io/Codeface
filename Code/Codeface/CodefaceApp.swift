import SwiftUI
import SwiftyToolz

@main
struct CodefaceApp: App
{
    var body: some Scene
    {
        WindowGroup
        {
            ZStack
            {
                CodefaceView(viewModel: codeface)
                
                if isPresentingLSPServiceHint
                {
                    LSPServiceHint(isBeingPresented: $isPresentingLSPServiceHint)
                }
            }
            .onChange(of: scenePhase)
            {
                switch $0
                {
                case .background: break
                case .active: codeface.didBecomeActive()
                case .inactive: break
                @unknown default: break
                }
            }
            .sheet(isPresented: $isPresentingProjectSelector)
            {
                ProjectSelector(isBeingPresented: $isPresentingProjectSelector)
                {
                    codeface.loadNewActiveProject(with: $0)
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
                    switch codeface.displayMode
                    {
                    case .code: codeface.displayMode = .treeMap
                    case .treeMap: codeface.displayMode = .code
                    }
                }
                .keyboardShortcut(.space, modifiers: .shift)
                
                // TODO: only show when we haven't loaded symbols etc.
                Button("Show Symbols, Dependencies etc. ...")
                {
                    isPresentingLSPServiceHint = true
                }
                
                Divider()
            }
            
            CommandGroup(after: .help)
            {
                Button("How to see Symbols, Dependencies etc. ...")
                {
                    isPresentingLSPServiceHint = true
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
                        
                        let config = Project.Configuration(folder: firstURL,
                                                           language: "Swift",
                                                           codeFileEndings: ["swift"])
                        
                        codeface.loadNewActiveProject(with: config)
                    }
                    catch { log(error) }
                })
                
                Button("Reload Last Project")
                {
                    codeface.loadLastActiveProject()
                }
                .keyboardShortcut("r")
                .disabled(!ProjectConfigPersister.hasPersistedLastProjectConfig)
            }
        }
        
    }
    
    @State var isPresentingLSPServiceHint = false
    @State var isPresentingProjectSelector = false
    @State var isPresentingFileImporter = false
    @Environment(\.scenePhase) var scenePhase
    
    @StateObject private var codeface = Codeface()
}
