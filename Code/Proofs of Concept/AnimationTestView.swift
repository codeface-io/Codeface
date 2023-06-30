import SwiftUI

/// tests animations by showing a text that changes its position when the user clicks on it
struct AnimationTestView: View {
    var body: some View {
        DoubleSidebarView(showLeftSidebar: .constant(false),
                          showRightSidebar: .constant(false)) {
            VStack {
                HStack {
                    Spacer()
                    
                    Button("Animate") { animate() }
                        .padding()
                }
                
                GeometryReader { geo in
                    VStack {
                        HStack {
                            ArtifactIconView(icon: .forFile(named: "something.swift"))
                            Text("Code Artifact Dummy")
                                .font(.system(size: 16,
                                              weight: .medium,
                                              design: .default))
                            Spacer()
                        }
                        .padding()
                        
                        Spacer()
                    }
                    .frame(width: artifactWidth, height: artifactHeight)
                    .background(Color.init(hue: 0, saturation: 0, brightness: 0.4))
                    .position(CGPoint(x: geo.size.width * relativeX,
                                      y:  geo.size.height * relativeY))
                    .onTapGesture {
                        animate()
                    }
                    .opacity(isVisible ? 1 : 0)
                    .onChange(of: geo.size) { _ in animate() }
                }
                .clipped()
            }
        } leftSidebar: {
            
        } rightSidebar: {
            
        }
    }
    
    private func animate() {
        withAnimation(.easeInOut(duration: 1)) {
            relativeX = .random(in: 0 ... 1)
            relativeY = .random(in: 0 ... 1)
            
            artifactWidth = .random(in: 150 ... 600)
            artifactHeight = .random(in: 20 ... 200)
            
            isVisible.toggle()
        }
    }
    
    @State private var relativeX = 0.5
    @State private var relativeY = 0.5
    
    @State private var artifactWidth: Double = 300
    @State private var artifactHeight: Double = 100
    
    @State private var isVisible = true
}
