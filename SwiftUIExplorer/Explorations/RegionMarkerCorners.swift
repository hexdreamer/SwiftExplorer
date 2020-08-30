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
        return CGRect(x: topLeft.x, y: topLeft.y, width: bottomRight.x - topLeft.x, height: bottomRight.y - topLeft.y)
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder()
                .frame(width: self.region.width, height: self.region.height, alignment:.center)
                .position(x: self.region.midX, y: self.region.midY)
            
            Circle()
                .fill(Color.red)
                .frame(width: 15, height: 15, alignment: .center)
                .position(x: self.topLeft.x, y: self.topLeft.y)
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            self.topLeft = gesture.location
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
                            var halfW = self.region.width/2
                            var halfH = self.region.height/2
                            
                            // If topLeft is ever not top or not left of bottomRight
                            if self.topLeft.x > self.bottomRight.x {
                                halfW *= -1
                            }
                            if self.topLeft.y > self.bottomRight.y {
                                halfH *= -1
                            }
                            
                            self.topLeft.x = gesture.location.x - halfW
                            self.topLeft.y = gesture.location.y - halfH
                            self.bottomRight.x = gesture.location.x + halfW
                            self.bottomRight.y = gesture.location.y + halfH
                    }
            )
            
            Circle()
                .fill(Color.green)
                .frame(width: 15, height: 15, alignment: .center)
                .position(x: self.bottomRight.x, y: self.bottomRight.y)
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            self.bottomRight = gesture.location
                        }
                )
        } // Zstack
        .background(Color.gray)
    }
    
}

struct RegionMarkerCorners_Previews: PreviewProvider {
    static var previews: some View {
        RegionMarkerCorners()
    }
}
