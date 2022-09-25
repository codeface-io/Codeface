import SwiftUI
import LSPServiceKit
import SwiftLSP
import SwiftyToolz

struct CodebaseLocatorView: View
{
    var body: some View
    {
        VStack(alignment: .leading)
        {
            Text("Set codebase language:")
            
            Form
            {
                TextField("Language Name", text: $languageName)
                    .lineLimit(1)
                
                TextField("Code File Endings", text: $fileEndings)
                    .lineLimit(1)
            }
            .frame(minWidth: 300)
            .padding([.bottom, .top])
            
            HStack
            {
                Button("Cancel") { isBeingPresented = false }
                
                Spacer()
                
                Button("Next")
                {
                    isPresentingFileImporter = true
                }
                .buttonStyle(.borderedProminent)
                .disabled(languageName.isEmpty || fileEndings.isEmpty)
                .fileImporter(isPresented: $isPresentingFileImporter,
                              allowedContentTypes: [.directory],
                              allowsMultipleSelection: false,
                              onCompletion:
                                {
                    result in
                    
                    isPresentingFileImporter = false
                    isBeingPresented = false
                    
                    do
                    {
                        let urls = try result.get()
                        
                        guard let firstURL = urls.first else
                        {
                            throw "Empty array of URLs"
                        }
                        
                        let fileEndingArray = fileEndings.components(separatedBy: .whitespaces)
                        
                        let config = LSP.CodebaseLocation(folder: firstURL,
                                                         language: languageName,
                                                         codeFileEndings: fileEndingArray)
                        
                        confirm(config)
                    }
                    catch { log(error.readable) }
                })
            }
        }
    }
    
    @Binding var isBeingPresented: Bool
    let confirm: (LSP.CodebaseLocation) -> Void
    
    @State private var languageName: String = ""
    @State private var fileEndings: String = ""
    @State private var isPresentingFileImporter = false
}
