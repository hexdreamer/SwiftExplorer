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
    let minSize = CGSize(width: 10, height: 10)
    
    var region:CGRect {
        return CGRect(x: topLeft.x, y: topLeft.y, width: bottomRight.x - topLeft.x, height: bottomRight.y - topLeft.y).standardized
    }

    func clampX(_ min:CGFloat, _ max:CGFloat) -> (CGFloat, CGFloat) {
        var minX = min
        var maxX = max
        let regionW = self.region.width
        let leftBound:CGFloat = 0
        let rightBound        = self.bounds.width

        //print("clampX >> before minX: \(minX) max: \(maxX)")
        if (minX <= leftBound) {
            // dragging ⬅️ against lefmost bound
            minX = leftBound
            maxX = leftBound + regionW
        }

        if (maxX >= rightBound) {
            // dragging ➡️ against rightmost bound
            minX = rightBound - regionW
            maxX = rightBound
        }
        //print("clampX >> after minX: \(minX) max: \(maxX)")

        return (minX, maxX)
    }

    func clampY(_ min:CGFloat, _ max:CGFloat) -> (CGFloat, CGFloat) {
        var minY = min
        var maxY = max
        let regionH = self.region.height
        let topBound:CGFloat = 0
        let bottomBound      = self.bounds.height

        if (minY <= topBound) {
            // dragging ⬆️ against topmost bound
            minY = topBound
            maxY = topBound + regionH
        }

        if (maxY >= bottomBound) {
            // dragging ⬇️ against bottommost bound
            minY = bottomBound - regionH
            maxY = bottomBound
        }

        return (minY, maxY)
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
                            let l = gesture.location
                            var minX = l.x
                            var minY = l.y
                            (minX, _) = clampX(minX, 1)
                            (minY, _) = clampY(minY, 1)
                            self.topLeft = CGPoint(x: minX, y: minY)
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
                            let halfW = self.region.width/2
                            let halfH = self.region.height/2

                            let l = gesture.location
                            var minX = l.x-halfW
                            var minY = l.y-halfH
                            var maxX = l.x+halfW
                            var maxY = l.y+halfH

                            (minX, maxX) = clampX(minX, maxX)
                            (minY, maxY) = clampY(minY, maxY)

                            self.topLeft =      CGPoint(x: minX, y: minY)
                            self.bottomRight =  CGPoint(x: maxX, y: maxY)
                        }
                )
            
            Circle()
                .fill(Color.green)
                .frame(width: 15, height: 15, alignment: .center)
                .position(x: self.bottomRight.x, y: self.bottomRight.y)
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            let l = gesture.location
                            var maxX = l.x
                            var maxY = l.y
                            (_, maxX) = clampX(1, maxX)
                            (_, maxY) = clampY(1, maxY)
                            self.bottomRight = CGPoint(x: maxX, y: maxY)
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
