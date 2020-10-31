import SwiftUI
import UIKit
import hexdreamsCocoa

struct SEEvenOddFillUIKit : View {
    
    public var body: some View {
        VStack {
            Text("Even Odd Fill")
            HXCoreGraphicsViewRepresentable { (ctx,rect) in
                addRectCounterClockwise(ctx:ctx, rect:rect)
                addRectCounterClockwise(ctx:ctx, rect:rect.insetBy(dx:50, dy:50))
                ctx.setFillColor(CGColor(red:1, green:0.5, blue:0.5, alpha:1.0))
                ctx.fillPath(using:.evenOdd)
            }
        }
        
        VStack {
            Text("Even Odd Fill Reverse Winding")
            HXCoreGraphicsViewRepresentable { (ctx,rect) in
                addRectCounterClockwise(ctx:ctx, rect:rect)
                addRectClockwise(ctx:ctx, rect:rect.insetBy(dx:50, dy:50))
                ctx.setFillColor(CGColor(red:1, green:0.5, blue:0.5, alpha:1.0))
                ctx.fillPath(using:.evenOdd)
            }
        }

        VStack {
            Text("Winding Rule Fill")
            HXCoreGraphicsViewRepresentable { (ctx,rect) in
                addRectCounterClockwise(ctx:ctx, rect:rect)
                addRectCounterClockwise(ctx:ctx, rect:rect.insetBy(dx:50, dy:50))
                ctx.setFillColor(CGColor(red:1, green:0.5, blue:0.5, alpha:1.0))
                ctx.fillPath(using:.winding)
            }
        }

        VStack {
            Text("Winding Rule Fill Reverse Winding")
            HXCoreGraphicsViewRepresentable { (ctx,rect) in
                addRectCounterClockwise(ctx:ctx, rect:rect)
                addRectClockwise(ctx:ctx, rect:rect.insetBy(dx:50, dy:50))
                ctx.setFillColor(CGColor(red:1, green:0.5, blue:0.5, alpha:1.0))
                ctx.fillPath(using:.winding)
            }
        }
    }
    
}

// ┌  ┬  ┐
//
// ├  ┼  ┤
//
// └  ┴  ┘
func addRectClockwise(ctx:CGContext, rect:CGRect) {
    ctx.move(to:┌rect)
    ctx.addLine(to:┐rect)
    ctx.addLine(to:┘rect)
    ctx.addLine(to:└rect)
    ctx.closePath()
}

func addRectCounterClockwise(ctx:CGContext, rect:CGRect) {
    ctx.move(to:┌rect)
    ctx.addLine(to:└rect)
    ctx.addLine(to:┘rect)
    ctx.addLine(to:┐rect)
    ctx.closePath()
}
