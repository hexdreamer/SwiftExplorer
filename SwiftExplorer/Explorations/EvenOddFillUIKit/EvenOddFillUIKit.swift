import SwiftUI
import UIKit
import hexdreamsCocoa

struct EvenOddFillUIKit : View {
    
    
    public var body: some View {
        VStack {
            Text("Even Odd Fill")
            EvenOddFillUIKitVCRepresentable(fillRule:.evenOdd, reverseWinding:false)
        }
        VStack {
            Text("Even Odd Fill Reverse Winding")
            EvenOddFillUIKitVCRepresentable(fillRule:.evenOdd, reverseWinding:true)
        }
        VStack {
            Text("Winding Rule Fill")
            EvenOddFillUIKitVCRepresentable(fillRule:.winding, reverseWinding:false)
        }
        VStack {
            Text("Winding Rule Fill Reverse Winding")
            EvenOddFillUIKitVCRepresentable(fillRule:.winding, reverseWinding:true)
        }
    }
    
}

struct EvenOddFillUIKitVCRepresentable: UIViewControllerRepresentable {
    typealias UIViewControllerType = EvenOddFillViewController
        
    let fillRule:CGPathFillRule?
    let reverseWinding:Bool
        
    func makeUIViewController(context: Context) -> EvenOddFillViewController {
        let controller = EvenOddFillViewController()
        controller.fillRule = self.fillRule
        controller.reverseWinding = self.reverseWinding
        return controller
    }
    
    func updateUIViewController(_ uiViewController: EvenOddFillViewController, context: Context) {
        // do nothing
    }
}

class EvenOddFillViewController : UIViewController {
    
    var fillRule:CGPathFillRule?
    var reverseWinding:Bool = false
        
    override func loadView() {
        let view = EvenOddFillUIKitView();
        view.fillRule = self.fillRule
        view.reverseWinding = self.reverseWinding
        self.view = view
    }
    
}

class EvenOddFillUIKitView : UIView {
    
    var fillRule:CGPathFillRule?
    var reverseWinding:Bool = false
        
    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else {
            return
        }
        
        self.addRectCounterClockwise(ctx:ctx, rect:self.bounds)
        if ( !self.reverseWinding ) {
            self.addRectCounterClockwise(ctx:ctx, rect:self.bounds.insetBy(dx:50, dy:50))
        } else {
            self.addRectClockwise(ctx:ctx, rect:self.bounds.insetBy(dx:50, dy:50))
        }
        ctx.setFillColor(CGColor(red:1, green:0.5, blue:0.5, alpha:1.0))
        if let fillRule = self.fillRule {
            ctx.fillPath(using:fillRule)
        } else {
            ctx.fillPath()
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

}
