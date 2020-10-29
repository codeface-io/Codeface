import AppKit
import UIToolz
import GetLaid
import SwiftObserver
import SwiftyToolz

class AnalyticsTable: NSTableView, NSTableViewDataSource, NSTableViewDelegate, Observer
{
    // MARK: - Life Cycle
    
    override init(frame frameRect: NSRect)
    {
        super.init(frame: frameRect)
        
        usesAlternatingRowBackgroundColors = true
        
        addColumn(linesColumnID)
        addColumn(fileColumnID, minWidth: 300)
        
        dataSource = self
        delegate = self
        
        observeProjectClassMessenger()
        observeAnalyticsStoreIfExisting()
    }
    
    required init?(coder: NSCoder) { nil }
    
    // MARK: - Content
    
    func numberOfRows(in tableView: NSTableView) -> Int
    {
        return Project.active?.analyticsStore.elements.count ?? 0
    }
    
    func tableView(_ tableView: NSTableView,
                   viewFor tableColumn: NSTableColumn?,
                   row: Int) -> NSView?
    {
        guard
            let column = tableColumn,
            let analytics = Project.active?.analyticsStore.elements[row]
        else
        {
            return nil
        }
        
        switch column.identifier
        {
        case fileColumnID:
            return Label(text: analytics.file.name)
            
        case linesColumnID:
            let loc = analytics.linesOfCode
            let label = Label(text: "\(loc)")
            
            label.font = NSFont.monospacedDigitSystemFont(ofSize: 12,
                                                          weight: .regular)
            label.alignment = .right
            label.textColor = warningColor(for: loc).nsColor
            
            return label
            
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: NSTableView,
                   sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor])
    {
        guard let analyticsStore = Project.active?.analyticsStore else { return }
        
        for new in sortDescriptors
        {
            guard let key = new.key else
            {
                log(warning: "Sort descriptor has no key.")
                continue
            }
            
            let old = oldDescriptors.first { $0.key == key }
            
            if old == nil || old?.ascending != new.ascending
            {
                switch key
                {
                case linesColumnID.rawValue:
                    analyticsStore.sort(by: .linesOfCode, ascending: new.ascending)
                case fileColumnID.rawValue:
                    analyticsStore.sort(by: .filePath, ascending: new.ascending)
                default: break
                }
            }
        }
    }
    
    private let fileColumnID = UIItemID(rawValue: "File")
    private let linesColumnID = UIItemID(rawValue: "Lines of Code")
    
    // MARK: - Observe Project
    
    private func observeProjectClassMessenger()
    {
        observe(Project.messenger)
        {
            if case .didSetActiveProject = $0
            {
                self.observeAnalyticsStoreIfExisting()
                self.reloadData()
            }
        }
    }
    
    private func observeAnalyticsStoreIfExisting()
    {
        (Project.active?.analyticsStore).forSome { observe(analyticsStore: $0) }
    }
    
    private func observe(analyticsStore store: CodeFileAnalyticsStore)
    {
        observe(store).select(.didModifyData)
        {
            [weak self] in self?.reloadData()
        }
    }
    
    let receiver = Receiver()
}
