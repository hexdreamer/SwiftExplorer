//
//  Utility.swift
//  SwiftExplorer
//
//  Created by Zach Young on 6/23/21.
//  Copyright © 2021 Kenny Leung. All rights reserved.
//

import Foundation
import CoreGraphics
import SwiftUI


func drawTickMark(_ corner:String, _ origin:CGPoint, size:Int=20) -> Path {
    let primeX:CGFloat
    let primeY:CGFloat

    let size = CGFloat(size)
    switch corner {
    case "tl":
        primeX = origin.x + size
        primeY = origin.y + size

    case "br":
        primeX = origin.x - size
        primeY = origin.y - size

    default:
        primeX = origin.x
        primeY = origin.y
    }

    let extentX = CGPoint(x: primeX, y: origin.y)
    let extentY = CGPoint(x: origin.x, y: primeY)

    var path = Path()
    path.move(to: origin)
    path.addLine(to: extentX)
    path.move(to: origin)
    path.addLine(to: extentY)

    return path
}
