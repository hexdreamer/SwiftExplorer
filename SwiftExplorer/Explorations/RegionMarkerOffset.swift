// RegionMarkerCorners.swift
//
// This is an improved version which uses the top left aand bottom right corners as the state.
// There is a lot less math to do. "Choose the correct data structure, and that is the solution to your problem."

import Foundation
import SwiftUI

struct RegionMarkerOffset : View {
        
    @State var tlOfst = CGSize(width: -50, height: -50)
    @State var brOfst = CGSize(width:  50, height:  50)
    
    @State var tlDrag = CGSize.zero
    @State var brDrag = CGSize.zero
            
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder()
                .frame(width :abs((self.tlOfst.width  + self.tlDrag.width ) - (self.brOfst.width  + self.brDrag.width )),
                       height:abs((self.tlOfst.height + self.tlDrag.height) - (self.brOfst.height + self.brDrag.height)),
                       alignment:.center)
                .offset(x:(self.tlOfst.width  + self.tlDrag.width  + self.brOfst.width  + self.brDrag.width ) / 2,
                        y:(self.tlOfst.height + self.tlDrag.height + self.brOfst.height + self.brDrag.height) / 2)
            
            Circle()
                .fill(Color.red)
                .frame(width: 15, height: 15, alignment: .center)
                .offset(x: self.tlOfst.width + self.tlDrag.width, y: self.tlOfst.height + self.tlDrag.height)
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            self.tlDrag = gesture.translation
                            
                    }.onEnded { gesture in
                        self.tlOfst.width  += gesture.translation.width
                        self.tlOfst.height += gesture.translation.height
                        self.tlDrag = CGSize.zero
                    }
            )
            
            Circle()
                .fill(Color.green)
                .frame(width: 15, height: 15, alignment: .center)
                .offset(x: self.brOfst.width + self.brDrag.width, y: self.brOfst.height + self.brDrag.height)
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            self.brDrag = gesture.translation
                    }.onEnded { gesture in
                        self.brOfst.width  += gesture.translation.width
                        self.brOfst.height += gesture.translation.height
                        self.brDrag = CGSize.zero
                    }
            )
        } // Zstack
            .background(Color.gray)
    }
    
}
