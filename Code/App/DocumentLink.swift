import SwiftUI

struct DocumentLink: View
{
    static let lspService = DocumentLink("How to Setup LSPService",
                                         url: .lspService)
    
    static let documentation = DocumentLink("General Codeface Documentation",
                                            url: .documentation)
    
    init(_ text: String, url: URL)
    {
        self.text = text
        self.url = url
    }
    
    var body: some View
    {
        Link(destination: url)
        {
            Label(text, systemImage: "doc.text")
        }
    }
    
    private let text: String
    private let url: URL
}
