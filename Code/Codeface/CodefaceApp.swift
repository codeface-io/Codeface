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
                if serverManager.serverIsWorking
                {
                    Link("Open LSPService info page",
                         destination: lspServicePage)
                }
                else
                {
                    Link("How to See Symbols and Dependencies",
                         destination: lspServicePage)
                }
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
                
                Divider()

                Button("\(Image(systemName: "folder"))\tImport Codebase Folder...")
                {
                    isPresentingCodebaseLocator = true
                }
                .disabled(focusedDocument == nil)
                
                Button("\(Image(systemName: "swift"))\tImport Swift Package Folder...")
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
                        return log(error: "Could not select codebase folder")
                    }
                    
                    focusedDocument?.loadProcessorForSwiftPackage(from: folderURL)
                }
                
                Button("\(Image(systemName: "arrow.clockwise"))\tImport \(lastFolderName) Again...")
                {
                    focusedDocument?.loadProcessorForLastCodebase()
                }
                .keyboardShortcut("r")
                .disabled(focusedDocument == nil || !CodebaseLocationPersister.hasPersistedLastCodebaseLocation)


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
    @ObservedObject private var serverManager = LSP.ServerManager.shared
}
