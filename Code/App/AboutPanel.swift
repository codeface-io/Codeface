import SwiftUI
import Foundation
import SwiftyToolz

@MainActor
enum AboutPanel
{
    static func show(sender: Any? = nil)
    {
        shared.makeKeyAndOrderFront(sender)
    }
    
    static let shared: NSPanel =
    {
        let panel = NSPanel(contentViewController: NSHostingController(rootView: AboutView()))
        panel.title = "About \(Bundle.main.name ?? "This App")"
        return panel
    }()
}

struct AboutView: View
{
    var body: some View
    {
        Center
        {
            VStack(spacing: 10)
            {
                AppIcon()
                    .frame(minWidth: 100, minHeight: 100)
                
                if let name = Bundle.main.name
                {
                    Text(name)
                        .font(.title)
                        .fixedSize()
                }
                
                if let version = Bundle.main.version,
                   let buildNumber = Bundle.main.buildNumber
                {
                    Text("Version \(version) (\(buildNumber))")
                        .fixedSize()
                }
                
                if let copyright = Bundle.main.copyright
                {
                    Text(copyright)
                        .fixedSize()
                }
            }
            .padding()
        }
    }
}
