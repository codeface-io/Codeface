import SwiftUI

class CodefaceView: NSHostingView<ContentView>
{
    init() { super.init(rootView: ContentView()) }
    
    required init(rootView: ContentView) { super.init(rootView: rootView) }
    
    @objc required dynamic init?(coder aDecoder: NSCoder) { nil }
}

struct Preview: PreviewProvider
{
    static var previews: some View
    {
        ContentView().previewDisplayName("ContentView")
    }
}

struct ContentView: View
{
    var body: some View
    {
        NavigationView {
            List([data], children: \.children) { item in
                Text(item.description)
            }.listStyle(SidebarListStyle())
            Text("Huhu")
        }
    }
}

struct FileItem: Hashable, Identifiable, CustomStringConvertible {
    var id: Self { self }
    var name: String
    var children: [FileItem]? = nil
    var description: String {
        switch children {
        case nil:
            return "📄 \(name)"
        case .some(let children):
            return children.isEmpty ? "📂 \(name)" : "📁 \(name)"
        }
    }
}

let data =
  FileItem(name: "users", children:
    [FileItem(name: "user1234", children:
      [FileItem(name: "Photos", children:
        [FileItem(name: "photo001.jpg"),
         FileItem(name: "photo002.jpg")]),
       FileItem(name: "Movies", children:
         [FileItem(name: "movie001.mp4")]),
          FileItem(name: "Documents", children: [])
      ]),
     FileItem(name: "newuser", children:
       [FileItem(name: "Documents", children: [])
       ])
    ])
