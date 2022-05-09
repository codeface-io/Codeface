import SwiftUI
import SwiftyToolz

@main
struct CodefaceApp: App {
    
    // TODO: after launch: try Project.loadLastOpenFolder()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }.commands {
            CommandGroup(replacing: .newItem) {
                Button("Load Swift Package...") {
                    isPresented = true
                }
                .keyboardShortcut("l")
                .fileImporter(isPresented: $isPresented,
                              allowedContentTypes: [.directory],
                              allowsMultipleSelection: false,
                              onCompletion: { result in
                    isPresented = false
                    switch result {
                        
                    case .success(let urls):
                        urls.first.forSome
                        {
                            let description = Project.Description(rootFolder: $0,
                                                                  language: "swift",
                                                                  codeFileEndings: ["swift"])
                            
                            do
                            {
                                try Project.loadNewProject(description: description)
                            }
                            catch
                            {
                                log(error)
                            }
                        }
                    case .failure(let error):
                        log(error)
                    }
                    
                })
                
                Button("Reload Swift Package") {
                    do
                    {
                        try Project.loadLastProject(language: "swift",
                                                    codeFileEndings: ["swift"])
                    }
                    catch { log(error) }
                }
                .keyboardShortcut("r")
            }
        }
    }
    
    @State var isPresented = false
}
