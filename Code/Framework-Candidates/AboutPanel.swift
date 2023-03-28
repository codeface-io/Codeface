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
                .ignoresSafeArea()
        }
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
            AppIcon()
                .frame(minWidth: 100, minHeight: 100)
                .padding([.top, .bottom], 44)
                .padding([.leading, .trailing], 36)
            
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
                    Text(copyright.replacingOccurrences(of: ". ",
                                                        with: ".\n"))
                        .lineLimit(nil)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                HStack(spacing: 10)
                {
                    DocumentLink("Privacy Policy",
                                 url: privacyPolicyURL)
                    
                    Spacer()
                    
                    DocumentLink("License Agreement",
                                 url: licenseAgreementURL)
                }
            }
            .padding([.top, .bottom, .trailing])
        }
        .frame(minWidth: 530)
    }
    
    let privacyPolicyURL: URL
    let licenseAgreementURL: URL
}
