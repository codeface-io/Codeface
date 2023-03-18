import SwiftUI
import SwiftyToolz

struct LogView: View
{
    var body: some View
    {
        VStack(alignment: .leading, spacing: 0)
        {
            ZStack
            {
                List
                {
                    Text("Internal Logs")
                        .font(.title2)
                    
                    ForEach(logViewModel.logEntries)
                    {
                        entry in
                        
                        Label
                        {
                            VStack(alignment: .leading)
                            {
                                Text(entry.message)
                                
                                Text(entry.context)
                                    .foregroundColor(.secondary)
                            }
                        } icon: {
                            Image(systemName: Self.systemImageName(for: entry))
                                .foregroundColor(Self.imageColor(for: entry))
                        }
                    }
                }
                
                VStack
                {
                    Spacer()
                    
                    HStack
                    {
                        Spacer()
                        
                        Button {
                            logViewModel.clear()
                        } label: {
                            Label("Clear", systemImage: "trash")
                        }
                        .padding()
                    }
                }
            }
        }
    }
    
    private static func systemImageName(for entry: Log.Entry) -> String
    {
        switch entry.level
        {
        case .error: return "xmark.octagon.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .info: return "info.circle.fill"
        case .verbose: return "info.circle"
        }
    }
    
    private static func imageColor(for entry: Log.Entry) -> SwiftUI.Color
    {
        switch entry.level
        {
        case .error: return .red
        case .warning: return .yellow
        case .info: return .green
        case .verbose: return .secondary
        }
    }
    
    @ObservedObject private var logViewModel = LogViewModel.shared
}

@MainActor
class LogViewModel: ObservableObject
{
    static let shared = LogViewModel()
    
    /// just a way to create the instance so we can start the observation on app launch
    func startObservingLog() {}
    
    private init()
    {
        Log.shared.add(observer: self)
        {
            [weak self] entry in
            
            Task
            {
                @MainActor in // ensure view updates are triggered from main actor
                
                self?.logEntries.insertSorted(entry)
            }
        }
    }
    
    func clear()
    {
        logEntries.removeAll()
    }
    
    @Published var logEntries = [Log.Entry]()
}
