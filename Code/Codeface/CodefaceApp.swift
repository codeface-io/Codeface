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
        DocumentGroup(newDocument: CodebaseFileDocument())
        {
            CodefaceDocumentView(codebaseFile: $0.$document)
                .sheet(isPresented: $isPresentingCodebaseLocator) {
                    CodebaseLocatorView(isBeingPresented: $isPresentingCodebaseLocator)
                    {
                        focusedDocument?.loadNewProcessor(forCodebaseFrom: $0)
                    }
                    .padding()
                }
        }
        .commands
        {
            SidebarCommands()

            CommandGroup(before: .sidebar)
            {
                Button("Switch Display Mode")
                {
                    focusedDocument?.switchDisplayMode()
                }
                .disabled(focusedDocument?.projectProcessorVM == nil)
                .keyboardShortcut(.space, modifiers: .shift)

                Divider()
            }
            
            CommandGroup(replacing: .help)
            {
                HelpLink.lspService
                
                HelpLink.documentation
            }
            
            CommandGroup(replacing: .newItem)
            {
                Button("New Empty Codebase File") {
                    NSDocumentController.shared.newDocument(nil)
                }
                .keyboardShortcut("n")
                
                Button("Open a Codebase File ...") {
                    NSDocumentController.shared.openDocument(nil)
                }
                
                // TODO: Bring back menu item "Open Recent" programmatically!
            }
            
            CommandGroup(before: .undoRedo)
            {
                Button("Import Code Folder...")
                {
                    isPresentingCodebaseLocator = true
                }
                .disabled(focusedDocument == nil)
                
                Button("Import Swift Package Folder...")
                {
                    isPresentingFolderImporter = true
                }
                .disabled(focusedDocument == nil)
                .fileImporter(isPresented: $isPresentingFolderImporter,
                              allowedContentTypes: [.directory],
                              allowsMultipleSelection: false)
                {
                    guard let folderURL = (try? $0.get())?.first else
                    {
                        return log(error: "Could not select code folder")
                    }
                    
                    focusedDocument?.loadProcessorForSwiftPackage(from: folderURL)
                }
                
                Button("Import \(lastFolderName) Again")
                {
                    focusedDocument?.loadProcessorForLastCodebase()
                }
                .keyboardShortcut("r")
                .disabled(focusedDocument == nil || !CodebaseLocationPersister.hasPersistedLastCodebaseLocation)
                
                #if DEBUG
                Button("Test XPC Service With Last Codebase")
                {
                    do
                    {
                        let lastLoaction = try CodebaseLocationPersister.loadCodebaseLocation()
                        try createAndTestService(with: lastLoaction)
                    }
                    catch
                    {
                        log(error.readable)
                    }
                }
                .keyboardShortcut("t")
                #endif

                Divider()
            }
        }
    }
    
    private var lastFolderName: String
    {
        CodebaseLocationPersister.cachedLocation?.folder.lastPathComponent ?? "Last Folder"
    }
    
    // MARK: - Load Codebase from Folder
    
    @State private var isPresentingCodebaseLocator = false
    @State private var isPresentingFolderImporter = false
    
    // MARK: - Basics
    
    @FocusedValue(\.document) var focusedDocument: CodefaceDocument?
}

private func createAndTestService(with location: LSP.CodebaseLocation) throws
{
    let client = try XPCExecutable.Client(serviceBundleID: "com.flowtoolz.codeface.XPCExecutable")
    
    let serviceProxy = client.serviceProxy
    
    serviceProxy.launchExecutable(with: .init(path: "/usr/bin/xcrun", arguments: ["sourcekit-lsp"]))
    {
        error in
        
        if let error
        {
            log(error: "🛑 service failed to launch executable: " + error.readable.message)
            return
        }
            
        serviceProxy.getProcessID
        {
            processID in
            
            let initializeRequest = LSP.Message.request(.initialize(folder: location.folder,
                                                                    clientProcessID: processID))
            
            do
            {
                let packetData = try LSP.Packet(initializeRequest).data
                
                serviceProxy.writeExecutableStdIn(packetData)
                {
                    error in
                    
                    log(error?.readable.message ?? "✅")
                }
            }
            catch
            {
                log(error.readable)
            }
        }
    }
}
