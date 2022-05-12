import SwiftUI
import AppKit
import SwiftObserver
import SwiftLSP

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
        NavigationView
        {
            List(viewModel.artifacts,
                 children: \.parts,
                 selection: $selectedArtifact)
            {
                artifact in
                
                NavigationLink(tag: artifact,
                               selection: $selectedArtifact)
                {
                    Group
                    {
                        ArtifactContentView(artifact: artifact)
                            .padding(.top)
                        
//                        switch artifact.kind
//                        {
//                        case .file(let codeFile):
//                            TextEditor(text: .constant(codeFile.content))
//                                .font(.system(.body, design: .monospaced))
//                        default:
//                            Text(artifact.displayName)
//                        }
                    }
                    .navigationTitle(artifact.displayName)
                }
                label:
                {
                    Image(systemName: systemImageName(for: artifact.kind))
                        .foregroundColor(iconColor(for: artifact.kind))
                    
                    Text(artifact.displayName)
                        .fixedSize()
                        .font(.system(.title3, design: .for(artifact)))
                    
                    Spacer()
                    
                    if let loc = artifact.metrics?.linesOfCode
                    {
                        Text("\(loc)")
                            .fixedSize()
                            .foregroundColor(locColor(for: artifact))
                            .font(.system(.title3, design: .monospaced))
                    }
                }
            }
            .listStyle(.sidebar)
            
            TestView()
        }
    }
    
    private func locColor(for artifact: CodeArtifact) -> Color {
        switch artifact.kind {
        case .file:
            return warningColor(for: artifact.metrics?.linesOfCode ?? 0)
        default:
            return Color(NSColor.systemGray)
        }
    }
    
    @StateObject private var viewModel = ContentViewModel()
    @State var selectedArtifact: CodeArtifact?
}

extension Font.Design {
    static func `for`(_ artifact: CodeArtifact) -> Font.Design {
        switch artifact.kind {
        case .symbol: return .monospaced
        default: return .default
        }
    }
}

/// how to draw an arrow: https://stackoverflow.com/questions/48625763/how-to-draw-a-directional-arrow-head
struct TestView: View {
    var body: some View {
        GeometryReader { geo in
            
            ZStack {
                Line(start: .init(x: geo.size.width * point1.x,
                                  y: geo.size.height * point1.y),
                     end: .init(x: geo.size.width * point2.x,
                                y: geo.size.height * point2.y))
                .stroke(lineWidth: 2)
                .foregroundColor(isHovering ? .red : Color(NSColor.darkGray))
                
                Text("Click On Me!")
                    .padding()
                    .background(isHovering ? .red : Color(NSColor.darkGray))
                    .onHover { sth in
                        isHovering = sth
                    }
                    .position(x: geo.size.width * point1.x,
                              y: geo.size.height * point1.y)
                    .onTapGesture {
                        point1.x = .random(in: 0 ... 1)
                        point1.y = .random(in: 0 ... 1)
                    }
                
                Text("Click On Me!")
                    .padding()
                    .background(isHovering ? .red : Color(NSColor.darkGray))
                    .onHover { sth in
                        isHovering = sth
                    }
                    .position(x: geo.size.width * point2.x,
                              y: geo.size.height * point2.y)
                    .onTapGesture {
                        point2.x = .random(in: 0 ... 1)
                        point2.y = .random(in: 0 ... 1)
                    }
            }
            .frame(width: geo.size.width,
                   height: geo.size.height)
            .animation(.easeInOut, value: point1)
            .animation(.easeInOut, value: point2)
            .drawingGroup()
        }
    }
    
    @State var point1 = CGPoint(x: 0.33, y: 0.5)
    @State var point2 = CGPoint(x: 0.66, y: 0.25)
    
    @State var isHovering = false
}

extension Line {
    var animatableData: AnimatablePair<CGPoint.AnimatableData, CGPoint.AnimatableData> {
        get { AnimatablePair(start.animatableData, end.animatableData) }
        set { (start.animatableData, end.animatableData) = (newValue.first, newValue.second) }
    }
}

struct Line: Shape {

    func path(in rect: CGRect) -> Path {
        Path { p in
            p.move(to: start)
            p.addLine(to: end)
        }
    }
    
    var start, end: CGPoint
}
