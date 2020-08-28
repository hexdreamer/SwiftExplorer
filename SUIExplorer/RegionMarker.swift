//
//  RegionMarker.swift
//  SUIExplorer
//
//  Created by Kenny Leung on 8/28/20.
//

import Foundation
import SwiftUI

struct RegionMarker : View {
        
    @State var region = CGRect(x: 100, y: 100, width: 100, height: 100)
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder()
                .frame(width: self.region.width, height: self.region.height, alignment:.center)
                .position(x: self.region.midX, y: self.region.midY)
            
            Circle()
                .fill(Color.red)
                .frame(width: 15, height: 15, alignment: .center)
                .position(x: self.region.minX, y: self.region.minY)
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            var region = CGRect()
                            region.origin.x = gesture.location.x
                            region.origin.y = gesture.location.y
                            region.size.width = self.region.maxX - region.origin.x
                            region.size.height = self.region.maxY - region.origin.y
                            self.region = region.integral
                        }
                )
            
            Circle()
                .fill(Color.green)
                .frame(width: 15, height: 15, alignment: .center)
                .position(x: self.region.maxX, y: self.region.maxY)
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            var region = self.region
                            region.size.width = gesture.location.x - region.minX
                            region.size.height = gesture.location.y - region.minY
                            self.region = region.integral
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
