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
        
        observe(CodeFileAnalyticsStore.shared).select(.didModifyData)
        {
            [weak self] in self?.reloadData()
        }
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    deinit { stopObserving() }
    
    // MARK: - Content
    
    func numberOfRows(in tableView: NSTableView) -> Int
    {
        return CodeFileAnalyticsStore.shared.elements.count
    }
    
    func tableView(_ tableView: NSTableView,
                   viewFor tableColumn: NSTableColumn?,
                   row: Int) -> NSView?
    {
        guard let column = tableColumn else { return nil }
        
        let analytics = CodeFileAnalyticsStore.shared.elements[row]
        
        switch column.identifier
        {
        case fileColumnID:
            return Label(text: analytics.file.relativePath)
            
        case linesColumnID:
            let loc = analytics.linesOfCode
            let label = Label(text: "\(loc)")
            
            label.font = NSFont.monospacedDigitSystemFont(ofSize: 12,
                                                          weight: .regular)
            label.alignment = .right
            label.textColor = warningColor(for: loc).nsColor
            
            return label
            
        default: return nil
        }
    }
    
    func tableView(_ tableView: NSTableView,
                   sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor])
    {
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
                let store = CodeFileAnalyticsStore.shared
                
                switch key
                {
                case linesColumnID.rawValue:
                    store.sort(by: .linesOfCode, ascending: new.ascending)
                case fileColumnID.rawValue:
                    store.sort(by: .filePath, ascending: new.ascending)
                default: break
                }
            }
        }
    }
    
    private let fileColumnID = UIItemID(rawValue: "File")
    private let linesColumnID = UIItemID(rawValue: "Lines of Code")
}
