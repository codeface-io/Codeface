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
    
    static let shared: some NSWindow =
    {
        let panel = NSPanel(contentViewController: NSHostingController(rootView: AboutView()))
        
        panel.styleMask = [
            .closable,
            .miniaturizable,
            .resizable,
            .titled,
        ]
        
        panel.hidesOnDeactivate = false
        panel.titlebarSeparatorStyle = .none
        panel.titleVisibility = .hidden
        
        return panel
    }()
}

struct AboutView: View
{
    var body: some View
    {
        Center
        {
            HStack(alignment: .top, spacing: 0)
            {
                AppIcon()
                    .frame(minWidth: 130, minHeight: 130)
                    .padding(22)
                
                VStack(alignment: .leading, spacing: 0)
                {
                    if let name = Bundle.main.name
                    {
                        Text(name)
                            .font(.system(size: 38))
                    }
                    
                    if let version = Bundle.main.version,
                       let buildNumber = Bundle.main.buildNumber
                    {
                        Text("Version \(version) (\(buildNumber))")
                            .foregroundColor(.secondary)
                            .fontWeight(.light)
                    }
                    
                    Spacer()
                    
                    if let copyright = Bundle.main.copyright
                    {
                        Text(copyright)
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 10)
                    {
                        DocumentLink.privacyPolicy
                        
                        Spacer()
                        
                        DocumentLink.licenseAgreement
                    }
                }
                .padding([.top, .bottom, .trailing])
            }
            .frame(minWidth: 515)
        }
    }
}
