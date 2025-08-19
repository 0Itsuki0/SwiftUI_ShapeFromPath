

import SwiftUI

// Basic Implementation
struct ShapeFromPath: Shape {
    var path: Path
    var style: StrokeStyle
    var pathFitType: PathFitType
    
    nonisolated
    enum PathFitType: Equatable, Hashable {
        // dis-respect shape reference rectangle
        case asItIs
        // keep the relative position of the path, but resize it to fit in the reference rect
        case scaleFit
        // keep the size of the path, but align the bounding rect with the reference rect
        case align(Alignment)
        // scaleFit + align
        case scaleAndAlign(Alignment)
    }
    
    nonisolated
    enum Alignment: Equatable, Hashable {
        case bottom, bottomTrailing, bottomLeading
        case top, topTrailing, topLeading
        case trailing
        case leading
        case center
    }
    
    func path(in rect: CGRect) -> Path {
        let stroked =  path.strokedPath(style)
       
        switch self.pathFitType {
        case .asItIs:
            return stroked
            
        case .scaleFit:
            return self.resizePath(original: stroked, referenceRect: rect)
            
        case .align(let alignment):
            return self.shiftPath(original: stroked, alignment: alignment, referenceRect: rect)
            
        case .scaleAndAlign(let alignment):
            let scaled = self.resizePath(original: stroked, referenceRect: rect)
            return self.shiftPath(original: scaled, alignment: alignment, referenceRect: rect)
            
        }
        
    }
    
    private func resizePath(original: Path, referenceRect: CGRect) -> Path {
        let boundingRect = original.boundingRect
        let scaleX = referenceRect.width / boundingRect.width
        let scaleY = referenceRect.height / boundingRect.height
        let min = min(scaleX, scaleY)
        
        // scale with respect to origin
        let scaled = original.applying(
            .init(scaleX: min, y: min)
        )
        // shift the center back
        let shifted = scaled.offsetBy(dx: -scaled.boundingRect.midX + boundingRect.midX, dy: -scaled.boundingRect.midY + boundingRect.midY)

        return shifted
    }
    
    private func shiftPath(original: Path, alignment: Alignment, referenceRect: CGRect) -> Path {
        let boundingRect = original.boundingRect

        switch alignment {
        case .bottom:
            return original.offsetBy(dx: 0, dy: referenceRect.maxY - boundingRect.maxY)
            
        case .bottomTrailing:
            return original.offsetBy(dx: referenceRect.maxX - boundingRect.maxX, dy: referenceRect.maxY - boundingRect.maxY)
            
        case .bottomLeading:
            return original.offsetBy(dx: referenceRect.minX - boundingRect.minX, dy: referenceRect.maxY - boundingRect.maxY)
            
        case .top:
            return original.offsetBy(dx: 0, dy: referenceRect.minY - boundingRect.minY)
            
        case .topTrailing:
            return original.offsetBy(dx: referenceRect.maxX - boundingRect.maxX, dy: referenceRect.minY - boundingRect.minY)
            
        case .topLeading:
            return original.offsetBy(dx: referenceRect.minX - boundingRect.minX, dy: referenceRect.minY - boundingRect.minY)
            
        case .trailing:
            return original.offsetBy(dx: referenceRect.maxX - boundingRect.maxX, dy: 0)
            
        case .leading:
            return original.offsetBy(dx: referenceRect.minX - boundingRect.minX, dy: 0)
            
        case .center:
            return original.offsetBy(dx: referenceRect.midX - boundingRect.midX, dy: referenceRect.midY - boundingRect.midY)
        }
    }

}


// Demo View
struct PathToShape: View {
    @State private var fitType: ShapeFromPath.PathFitType = .asItIs
    
    private var path: Path {
        var path = Path()
        path.move(to: .init(x: 50, y: 150))
        path.addCurve(to: .init(x: 350, y: 150), control1: .init(x: 150, y: 250), control2: .init(x: 250, y: 50))
        return path
    }
    
    var body: some View {
        let strokeStyle: StrokeStyle = .init(lineWidth: 24, lineCap: .round)
        NavigationStack {
            VStack {
                VStack {
                    Text("Original Path + StrokeStyle")
                    path
                        .stroke(.red, style: strokeStyle)
                        .offset(y: -100)
                }
                .frame(height: 200)

                VStack {
                    Text("Shape From Path + clipShape")
                    Rectangle()
                        .fill(LinearGradient(colors: [.red, .yellow, .green], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .clipShape(
                            ShapeFromPath(path: path, style: strokeStyle, pathFitType: self.fitType)
                        )
                }
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.yellow.opacity(0.1))
            .navigationTitle("Shape From Path")
            .toolbar(content: {
                Picker(selection: $fitType, content: {
                    Text("As it is")
                        .tag(ShapeFromPath.PathFitType.asItIs)
                    
                    Text("Scale Fit")
                        .tag(ShapeFromPath.PathFitType.scaleFit)
                    
                    Text("Align Top")
                        .tag(ShapeFromPath.PathFitType.align(.top))
                    
                    Text("Align Center")
                        .tag(ShapeFromPath.PathFitType.align(.center))
                    
                    Text("Scale + Align Top")
                        .tag(ShapeFromPath.PathFitType.scaleAndAlign(.top))
                    
                    Text("Scale + Align Center")
                        .tag(ShapeFromPath.PathFitType.scaleAndAlign(.center))
                }, label: {})
                .labelsHidden()

            })

        }
    }
    
    
}


#Preview {
    PathToShape()
}

