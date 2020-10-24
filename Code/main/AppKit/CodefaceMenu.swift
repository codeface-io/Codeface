import AppKit
import UIToolz
import SwiftyToolz

class CodefaceMenu: MainMenu
{
    override init()
    {
        super.init()
        appMenu.insert(topItems, at: 0)
    }
    
    required init(coder decoder: NSCoder) { fatalError() }
    
    override func validateItem(with id: String) -> Bool
    {
        return id != reloadID || Loading.lastFolder != nil
    }
    
    private lazy var topItems: [NSMenuItem] =
    [
        makeItem("Reload", key: "r", id: reloadID)
        {
            do { try Loading.loadLastOpenFolder() }
            catch { log(error) }
        },
        makeItem("Load Code Folder...", key: "l")
        {
            FileSelectionPanel().selectFolder
            {
                do { try Loading.load(newFolder: $0) }
                catch { log(error) }
            }
        },
        makeItem("Launch Swift Language Server ...")
        {
//            FileSelectionPanel().selectFile
//            {
//                file in
//
//                SwiftLanguageServerController.instance.start(sourcekitLSPExecutable: file)
//            }
        },
        .separator()
    ]
    
    private let reloadID = "reload"
}
