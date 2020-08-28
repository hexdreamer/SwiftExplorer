//
//  RegionMarker.swift
//  SUIExplorer
//
//  Created by Kenny Leung on 8/28/20.
//

import Foundation
import SwiftUI

struct RegionMarker : View {
        
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

struct RegionMarker_Previews: PreviewProvider {
    static var previews: some View {
        RegionMarker()
    }
}
