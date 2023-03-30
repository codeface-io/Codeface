import SwiftUI
import Foundation
import SwiftyToolz

@MainActor
struct AboutPanel: Scene
{
    var body: some Scene
    {
        Window("About \(Bundle.main.name ?? "This App")", id: Self.id)
        {
            AboutView(privacyPolicyURL: privacyPolicyURL,
                      licenseAgreementURL: licenseAgreementURL)
        }
        .windowResizability(.contentSize)
        .defaultPosition(.topLeading)
        .windowStyle(.hiddenTitleBar)
    }
    
    let privacyPolicyURL: URL
    let licenseAgreementURL: URL
    
    static let id = "about-panel"
}

struct AboutView: View
{
    var body: some View
    {
        HStack(alignment: .top, spacing: 0)
        {
            Center
            {
                AppIcon()
                    .frame(width: 120, height: 120)
            }
            .ignoresSafeArea()
            .frame(width: 200, height: 180)
            
            VStack(alignment: .leading, spacing: 0)
            {
                if let name = Bundle.main.name
                {
                    Text(name)
                        .font(.system(size: 38))
                        .fixedSize()
                }
                
                if let version = Bundle.main.version,
                   let buildNumber = Bundle.main.buildNumber
                {
                    Text("Version \(version) (\(buildNumber))")
                        .foregroundColor(.secondary)
                        .fontWeight(.light)
                        .fixedSize()
                }
                
                Spacer()
                
                if let copyright = Bundle.main.copyright
                {
                    Text(copyright.replacingOccurrences(of: ". ",
                                                        with: ".\n"))
                        .lineLimit(nil)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .fixedSize()
                }
                
                Spacer()
                
                HStack(spacing: 40)
                {
                    DocumentLink("Privacy Policy",
                                 url: privacyPolicyURL)
                    .fixedSize()
                    
                    DocumentLink("License Agreement",
                                 url: licenseAgreementURL)
                    .fixedSize()
                }
            }
            .padding([.top, .trailing, .bottom])
            .ignoresSafeArea()
            .frame(height: 180)
        }
    }
    
    let privacyPolicyURL: URL
    let licenseAgreementURL: URL
}
