import SwiftUI
import SwiftyToolz

/**
 Log something as text **on every view update** (for debugging)
 
 For example, it allows to log the geometry proxy size inside `GeometryReader` to find out what a view's size actually is from the beginning, not just how it changes.
*/
struct LoggingText: View
{
    init(_ text: String)
    {
        log(text)
        self.text = text
    }
    
    var body: some View
    {
        Text("Last Log: " + text)
    }
    
    private let text: String
}
