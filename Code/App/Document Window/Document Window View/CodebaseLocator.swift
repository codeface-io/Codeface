import SwiftUI
import SwiftLSP
import SwiftyToolz

struct CodebaseLocator: View
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
                
                TextField("Code File Endings", text: $fileEndingsInput)
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
                .disabled(languageName.isEmpty || fileEndingsInput.isEmpty)
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
                        
                        let fileEndings = fileEndings(fromInput: fileEndingsInput)
                        
                        log("Detected \(fileEndings.count) file endings in user input: \(fileEndings.joined(separator: ", "))")
                        
                        let config = LSP.CodebaseLocation(folder: firstURL,
                                                          languageName: languageName,
                                                          codeFileEndings: fileEndings)
                        
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
    @State private var fileEndingsInput: String = ""
    @State private var isPresentingFileImporter = false
}

private func fileEndings(fromInput input: String) -> [String]
{
    input
        .components(separatedBy: .whitespaces.union(.punctuationCharacters))
        .filter { !$0.isEmpty }
}
