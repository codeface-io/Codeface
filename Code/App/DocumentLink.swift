import SwiftUI

struct DocumentLink: View
{
    static let lspService = DocumentLink("How to Setup LSPService",
                                         urlString: "https://codeface.io/lspservice/index.html")
    
    static let documentation = DocumentLink("General Codeface Documentation",
                                            urlString: "https://codeface.io/documentation/index.html")
    
    static let privacyPolicy = DocumentLink("Privacy Policy",
                                            urlString: "https://codeface.io/privacy-policy")
    
    static let licenseAgreement = DocumentLink("License Agreement",
                                               urlString: "https://www.apple.com/legal/macapps/stdeula")
    // alternatively: https://www.apple.com/legal/internet-services/itunes/dev/stdeula/
    
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
