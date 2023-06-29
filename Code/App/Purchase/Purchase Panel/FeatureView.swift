import SwiftUI

struct FeatureView: View
{
    init(_ title: String, subtitle: String)
    {
        self.title = title
        self.subtitle = subtitle
    }
    
    var body: some View
    {
        Label
        {
            VStack(alignment: .leading, spacing: 3)
            {
                Text(title)
                    .fontWeight(.medium)
                
                Text(subtitle)
                    .foregroundColor(.secondary)
            }
        } icon: {
            Image(systemName: "checkmark")
                .foregroundColor(Color(.systemGreen))
        }
    }
    
    let title: String
    let subtitle: String
}
