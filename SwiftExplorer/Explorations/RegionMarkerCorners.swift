// RegionMarkerCorners.swift
//
// This is an improved version which uses the top left aand bottom right corners as the state.
// There is a lot less math to do. "Choose the correct data structure, and that is the solution to your problem."

import Foundation
import SwiftUI

struct RegionMarkerCorners : View {
        
    @State var topLeft = CGPoint(x: 100, y: 100)
    @State var bottomRight = CGPoint(x: 200, y: 200)

    var region:CGRect {
        return CGRect(x: topLeft.x, y: topLeft.y, width: bottomRight.x - topLeft.x, height: bottomRight.y - topLeft.y).standardized
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
                            let loc = gesture.location
                            self.topLeft = CGPoint(x: loc.x, y: loc.y)
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
                            let loc = gesture.location
                            let minX = loc.x-halfW
                            let minY = loc.y-halfH
                            let maxX = loc.x+halfW
                            let maxY = loc.y+halfH
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
                            let loc = gesture.location
                            self.bottomRight = CGPoint(x: loc.x, y: loc.y)
                        }
                )
        } // ZStack
        .border(Color.green, width: 2)
        .background(Color.gray)
    }
    
}

//struct RegionMarkerCorners_Previews: PreviewProvider {
//    static var previews: some View {
//        RegionMarkerCorners()
//    }
//}
