// RegionMarkerCorners.swift
//
// This is an improved version which uses the top left aand bottom right corners as the state.
// There is a lot less math to do. "Choose the correct data structure, and that is the solution to your problem."

import Foundation
import SwiftUI

struct RegionMarkerCorners : View {
        
    @Binding var topLeft:CGPoint      //= CGPoint(x: 100, y: 100)
    @Binding var bottomRight:CGPoint  // = CGPoint(x: 200, y: 200)
    let bounds:CGSize
    
    var region:CGRect {
        return CGRect(x: topLeft.x, y: topLeft.y, width: bottomRight.x - topLeft.x, height: bottomRight.y - topLeft.y).standardized
    }

    func clampX(_ x:CGFloat) -> CGFloat {
        var myX = x
        print("clampX >> before \(myX)")
        if (x < 0)              { myX = 0 }
        if (x > bounds.width)   { myX = bounds.width }
        print("clampX >> after \(myX)")
        return myX
    }

    func clampY(_ y:CGFloat) -> CGFloat {
        if (y < 0)              { return 0}
        if (y > bounds.height)  { return bounds.height}

        return y
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(Color.blue, lineWidth: 2)
                .frame(width: self.region.width, height: self.region.height, alignment:.center)
                .position(x: self.region.midX, y: self.region.midY)
            
            Circle()
                .fill(Color.red)
                .frame(width: 15, height: 15, alignment: .center)
                .position(x: self.topLeft.x, y: self.topLeft.y)
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            let x = clampX(gesture.location.x)
                            let y = clampY(gesture.location.y)
                            self.topLeft = CGPoint(x: x, y: y)
                        }
                )
            
            // Move handle
            Circle()
                .fill(Color.blue)
                .frame(width: 15, height: 15, alignment: .center)
                .position(x: self.region.midX, y: self.region.midY)
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            let width = abs(self.region.width)
                            let height = abs(self.region.height)
                            let halfW = width/2
                            let halfH = height/2
                            let minX = gesture.location.x-halfW
                            let minY = gesture.location.y-halfH
                            var maxX = gesture.location.x+halfW
                            var maxY = gesture.location.y+halfH

                            // We can drag so far to the left and up that the max values fall below the lower clamp threshold of 0
                            // and get returned as 0
                            maxX = (maxX < halfW) ? halfW : maxX
                            maxY = (maxY < halfH) ? halfH : maxY

                            var clampedMinX = clampX(minX)
                            var clampedMinY = clampY(minY)
                            var clampedMaxX = clampX(maxX)
                            var clampedMaxY = clampX(maxY)


                            // dragging ➡️ against rightmost bound
                            clampedMinX = (clampedMaxX == maxX) ? clampedMinX : clampedMaxX - width
                            // dragging ⬅️ against lefmost bound
                            clampedMaxX = (clampedMinX == minX) ? clampedMaxX : clampedMinX + width
                            // dragging ⬇️ against bottom bound
                            clampedMinY = (clampedMaxY == maxY) ? clampedMinY : clampedMaxY - height
                            // dragging ⬆️ against upper bound
                            clampedMaxY = (clampedMinY == minY) ? clampedMaxY : clampedMinY + height

                            self.topLeft =      CGPoint(x: clampedMinX, y: clampedMinY)
                            self.bottomRight =  CGPoint(x: clampedMaxX, y: clampedMaxY)
                        }
                )
            
            Circle()
                .fill(Color.green)
                .frame(width: 15, height: 15, alignment: .center)
                .position(x: self.bottomRight.x, y: self.bottomRight.y)
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            let x = clampX(gesture.location.x)
                            let y = clampY(gesture.location.y)
                            self.bottomRight = CGPoint(x: x, y: y)
                        }
                )
        } // ZStack
//        .border(Color.green, width: 2)
//        .background(Color.gray)
    }
    
}

//struct RegionMarkerCorners_Previews: PreviewProvider {
//    static var previews: some View {
//        RegionMarkerCorners()
//    }
//}
