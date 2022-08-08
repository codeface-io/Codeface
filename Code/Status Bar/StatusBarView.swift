import SwiftUI

struct StatusBarView: View
{
    var body: some View
    {
        HStack
        {
            Text(statusBar.displayText)
                .padding()
            Spacer()
        }
        .frame(height: 29)
        .background(colorScheme == .dark ? Color(white: 0.08) : Color(NSColor.controlBackgroundColor))
    }
    
    @ObservedObject var statusBar: StatusBar
    @Environment(\.colorScheme) private var colorScheme
}
