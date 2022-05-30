import Foundation

struct CodeFolder: Equatable
{
    init(url: URL,
         files: [CodeFile],
         subfolders: [CodeFolder])
    {
        self.url = url
        self.files = files
        self.subfolders = subfolders
    }
    
    let url: URL
    let files: [CodeFile]
    let subfolders: [CodeFolder]
}
