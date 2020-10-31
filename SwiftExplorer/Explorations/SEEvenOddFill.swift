//
//  SEEvenOddFill.swift
//  SwiftExplorer
//
//  Created by Kenny Leung on 10/31/20.
//  Copyright © 2020 Kenny Leung. All rights reserved.
//

import Foundation

import SwiftUI
import UIKit
import hexdreamsCocoa

struct SEEvenOddFill : View {
    
    let insetWidth:CGFloat = 30
    
    public var body: some View {
        VStack {
            Text("Even Odd Fill")
            GeometryReader { geom in
                Path { path in
                    addRectCounterClockwise(path:&path, rect:CGRect(size:geom.size))
                    addRectCounterClockwise(path:&path, rect:CGRect(size:geom.size).insetBy(dx:insetWidth, dy:insetWidth))
                }
                .fill(Color(.displayP3, red:1, green:0.5, blue:0.5, opacity:0.5),
                      style:FillStyle(eoFill:true, antialiased:false))
            }
        }
        
        VStack {
            Text("Even Odd Fill Reverse Winding")
            GeometryReader { geom in
                Path { path in
                    addRectCounterClockwise(path:&path, rect:CGRect(size:geom.size))
                    addRectClockwise(path:&path, rect:CGRect(size:geom.size).insetBy(dx:insetWidth, dy:insetWidth))
                }
                .fill(Color(.displayP3, red:1, green:0.5, blue:0.5, opacity:0.5),
                      style:FillStyle(eoFill:true, antialiased:false))
            }
        }
        
        VStack {
            Text("Winding Rule Fill")
            GeometryReader { geom in
                Path { path in
                    addRectCounterClockwise(path:&path, rect:CGRect(size:geom.size))
                    addRectCounterClockwise(path:&path, rect:CGRect(size:geom.size).insetBy(dx:insetWidth, dy:insetWidth))
                }
                .fill(Color(.displayP3, red:1, green:0.5, blue:0.5, opacity:0.5),
                      style:FillStyle(eoFill:false, antialiased:false))
            }
        }
        
        VStack {
            Text("Winding Rule Fill Reverse Winding")
            GeometryReader { geom in
                Path { path in
                    addRectCounterClockwise(path:&path, rect:CGRect(size:geom.size))
                    addRectClockwise(path:&path, rect:CGRect(size:geom.size).insetBy(dx:insetWidth, dy:insetWidth))
                }
                .fill(Color(.displayP3, red:1, green:0.5, blue:0.5, opacity:0.5),
                      style:FillStyle(eoFill:false, antialiased:false))
            }
        }
    }
    
}

// ┌  ┬  ┐
//
// ├  ┼  ┤
//
// └  ┴  ┘
private func addRectClockwise(path:inout Path, rect:CGRect) {
    path.move(to:┌rect)
    path.addLine(to:┐rect)
    path.addLine(to:┘rect)
    path.addLine(to:└rect)
    path.closeSubpath()
}

private func addRectCounterClockwise(path:inout Path, rect:CGRect) {
    path.move(to:┌rect)
    path.addLine(to:└rect)
    path.addLine(to:┘rect)
    path.addLine(to:┐rect)
    path.closeSubpath()
}
