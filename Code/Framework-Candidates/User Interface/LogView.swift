import SwiftUI
import SwiftyToolz

struct LogView: View
{
    var body: some View
    {
        VStack(alignment: .leading, spacing: 0)
        {
            List
            {
                Text("Internal Logs")
                    .font(.title2)
                
                ForEach(logViewModel.logEntries.filter({ $0.level >= minimumLogLevel }))
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
                        LogIcon(logLevel: entry.level)
                    }
                }
            }
            .textSelection(.enabled)
            .animation(.default, value: minimumLogLevel)
        }
        .toolbar
        {
            ToolbarItemGroup(placement: .primaryAction)
            {
                Picker("Minimum Log Level", selection: $minimumLogLevel)
                {
                    ForEach(Log.Level.allCases)
                    {
                        Text($0.displayName).tag($0)
                    }
                }
                .lineLimit(1)
                
                Button {
                    logViewModel.clear()
                } label: {
                    Label("Clear", systemImage: "trash")
                }
            }
        }
    }
    
    @State private var minimumLogLevel = Log.Level.info
    @ObservedObject private var logViewModel = LogViewModel.shared
}

struct LogIcon: View
{
    init(logLevel: Log.Level)
    {
        switch logLevel
        {
        case .error:
            imageName = "xmark.octagon.fill"
            color = .red
        case .warning:
            imageName = "exclamationmark.triangle.fill"
            color = .yellow
        case .info:
            imageName = "info.circle.fill"
            color = .green
        case .verbose:
            imageName = "info.circle"
            color = .secondary
        }
    }
    
    var body: some View
    {
        Image(systemName: imageName).foregroundColor(color)
    }
    
    private let imageName: String
    private let color: SwiftUI.Color
}

@MainActor
class LogViewModel: ObservableObject
{
    static let shared = LogViewModel()
    
    /// just a way to create the instance that allows starting the log observation on app launch
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
