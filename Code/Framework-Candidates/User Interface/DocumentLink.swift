import SwiftUI

struct DocumentLink: View
{
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
