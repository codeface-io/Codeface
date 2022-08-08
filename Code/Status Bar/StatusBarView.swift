import SwiftUI

struct StatusBarView: View
{
    var body: some View
    {
        HStack
        {
            Text(statusBar.text).padding()
            Spacer()
        }
        .frame(height: 30)
    }
    
    @ObservedObject var statusBar: StatusBar
}
