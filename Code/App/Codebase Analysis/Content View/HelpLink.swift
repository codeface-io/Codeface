import SwiftUI

struct HelpLink: View
{
    static let lspService = HelpLink("How to Setup LSPService",
                                     urlString: "https://codeface.io/lspservice/index.html")
    
    static let documentation = HelpLink("General Codeface Documentation",
                                        urlString: "https://codeface.io/documentation/index.html")
    
    init(_ text: String, urlString: String)
    {
        self.text = text
        self.url = URL(string: urlString)!
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
