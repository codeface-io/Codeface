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
                Button("Switch View Mode")
                {
                    focusedDocument?.switchDisplayMode()
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
            
            CommandGroup(after: .newItem)
            {
                Button("Import Codebase Folder...")
                {
                    isPresentingCodebaseLocator = true
                }
                .disabled(focusedDocument == nil || focusedDocument?.codebase != nil)
                
                Button("Import Swift Package...")
                {
                    isPresentingFolderImporter = true
                }
                .disabled(focusedDocument == nil || focusedDocument?.codebase != nil)
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

                Divider()
            }
        }
    }
    
    // MARK: - Load Codebase from Folder
    
    @State private var isPresentingCodebaseLocator = false
    @State private var isPresentingFolderImporter = false
    
    // MARK: - Basics
    
    @FocusedValue(\.document) var focusedDocument: CodefaceDocument?
    @ObservedObject private var serverManager = LSP.ServerManager.shared
}
