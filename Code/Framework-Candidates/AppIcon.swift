import SwiftUI
import FoundationToolz
import SwiftyToolz

struct AppIcon: View
{
    var body: some View
    {
        let iconName = Bundle.main.iconName ?? "AppIcon"
        
        if let nsImage = NSImage(named: iconName)
        {
            Image(nsImage: nsImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
        else
        {
            let errorMessage = "Found no image named '\(iconName)'"
            Text(errorMessage)
                .onAppear { log(error: errorMessage) }
        }
    }
}
