import AppKit
import UIToolz
import GetLaid
import SwiftObserver
import SwiftyToolz

class FileTable: NSTableView, NSTableViewDataSource, NSTableViewDelegate, Observer
{
    override init(frame frameRect: NSRect)
    {
        super.init(frame: frameRect)
        
        addColumn(fileColumnID, minWidth: 200)
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
            return Label(text: analytics.file.path)
        case linesColumnID:
            return Label(text: "\(analytics.linesOfCode)")
        default: return nil
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
    func addColumn(_ id: UIItemID, minWidth: CGFloat = 100)
    {
        let column = NSTableColumn(identifier: id)
        column.resizingMask = .userResizingMask
        column.minWidth = minWidth
        column.title = id.rawValue
        
        addTableColumn(column)
    }
}

typealias UIItemID = NSUserInterfaceItemIdentifier
