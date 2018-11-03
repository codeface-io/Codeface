import AppKit
import UIToolz
import GetLaid
import SwiftObserver
import SwiftyToolz

class Table: NSTableView, NSTableViewDataSource, NSTableViewDelegate, Observer
{
    // MARK: - Life Cycle
    
    override init(frame frameRect: NSRect)
    {
        super.init(frame: frameRect)
        
        usesAlternatingRowBackgroundColors = true
        
        addColumn(fileColumnID, minWidth: 300)
        addColumn(linesColumnID)
        
        dataSource = self
        delegate = self
        
        observe(Store.shared)
        {
            [weak self] event in
            
            if event == Store.Event.didModifyData
            {
                self?.reloadData()
            }
        }
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    deinit { stopAllObserving() }
    
    // MARK: - Content
    
    func numberOfRows(in tableView: NSTableView) -> Int
    {
        return Store.shared.analytics.count
    }
    
    func tableView(_ tableView: NSTableView,
                   viewFor tableColumn: NSTableColumn?,
                   row: Int) -> NSView?
    {
        guard let column = tableColumn else { return nil }
        
        let analytics = Store.shared.analytics[row]
        
        switch column.identifier
        {
        case fileColumnID:
            return Label(text: analytics.file.pathInCodeFolder)
        case linesColumnID:
            let label = Label(text: "\(analytics.linesOfCode)")
            label.alignment = .right
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
                let store = Store.shared
                
                switch key
                {
                case linesColumnID.rawValue:
                    store.analytics.sortByLinesOfCode(ascending: new.ascending)
                case fileColumnID.rawValue:
                    store.analytics.sortByFilePath(ascending: new.ascending)
                default: break
                }
            }
        }
    }
    
    private let fileColumnID = UIItemID(rawValue: "File")
    private let linesColumnID = UIItemID(rawValue: "Lines of Code")
}

// MARK: - Framework Candidates

class ScrollTable<T: NSTableView>: NSScrollView
{
    override init(frame frameRect: NSRect)
    {
        super.init(frame: frameRect)
        
        documentView = table
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    let table = T()
}

extension NSTableView
{
    @discardableResult
    func addColumn(_ id: UIItemID,
                   sortable: Bool = true,
                   minWidth: CGFloat = 100) -> NSTableColumn
    {
        let column = NSTableColumn(identifier: id)
        column.resizingMask = .userResizingMask
        column.minWidth = minWidth
        column.title = id.rawValue
        
        if sortable
        {
            column.sortDescriptorPrototype = NSSortDescriptor(key: id.rawValue,
                                                              ascending: true)
        }
        
        addTableColumn(column)
        
        return column
    }
}

typealias UIItemID = NSUserInterfaceItemIdentifier
