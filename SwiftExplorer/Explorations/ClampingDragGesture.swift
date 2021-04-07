//
//  ClampingDragGesture.swift
//  SwiftExplorer
//
//  Created by Zach Young on 4/6/21.
//  Copyright © 2021 Kenny Leung. All rights reserved.
//

import SwiftUI
import hexdreamsCocoa

class Controller: ObservableObject {
    let image = UIImage(named: "ChannelImageDefault")!

    var minX:CGFloat = 20
    var minY:CGFloat = 20
    var maxX:CGFloat = 80
    var maxY:CGFloat = 80

    var boundsX:CGFloat { image.size.width }
    var boundsY:CGFloat { image.size.height }

    @Published var regionOfInterest = CGRect.zero

    init() {
        self.regionOfInterest = self.makeRegion()
    }

    func changeRegion(target:CGRect) {
        let minX = target.minX
        let minY = target.minY
        let maxX = target.width
        let maxY = target.height

        self.minX = (minX < 0)            ? 0            : minX
        self.maxX = (maxX > self.boundsX) ? self.boundsX : maxX
        self.minY = (minY < 0)            ? 0            : minY
        self.maxY = (minY > self.boundsY) ? self.boundsY : maxY

        self.regionOfInterest = makeRegion()
        print("changeRegion >> regionOfInterest: \(self.regionOfInterest)")
    }

    func makeRegion() -> CGRect {
        return CGRect(x: minX, y: minY, width: minX+maxX, height: minY+maxY)
    }
}

struct ClampingDragGesture: View {
    @ObservedObject var c = Controller()

    var body: some View {
        VStack {
            GeometryReader { geoReader in
                let frame = geoReader.frame(in: .local)
                let tFitImage = tFitSizeInFrame(innerSize: self.c.image.size, outerRect: frame)
                let imageFrame = CGRect(size: self.c.image.size).applying(tFitImage)
                Image(uiImage: c.image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .position(x: imageFrame.midX, y: imageFrame.midY)
                    .frame(width: imageFrame.width, height: imageFrame.height)

                let region = c.regionOfInterest.applying(tFitImage)
                Rectangle()
                    .stroke(Color.blue, lineWidth: 2)
                    .position(x: region.midX, y: region.midY)
                    .frame(width: region.width, height: region.height)

                Image(systemName: "arrow.up.and.down.and.arrow.left.and.right")
                    .font(.system(size: 50))
                    .position(x: region.midX, y: region.midY)
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                let tx = gesture.translation.width
                                let ty = gesture.translation.height
                                print("onChanged >> translation: (tx: \(tx), ty: \(ty)")
                                let x = region.minX + tx
                                let y = region.minY + ty
                                print("onChanged >> origin: (x: \(x), y: \(y))")
                                let width  = region.width  + (tx * -1)
                                let height = region.height + (ty * -1)

                                // The proposed new region in View space
                                var p = CGRect(x: x, y: y, width: width, height: height)
                                // Now in Image space
                                p = p.applying(tFitImage.inverted())
                                // Hand-off region to controller and let it decide what to make of it
                                c.changeRegion(target: p)
                            }
                    )

            }
        }
    }

    /// Return a transform that fits a size (centered and scaled) in a frame
    func tFitSizeInFrame(innerSize:CGSize, outerRect:CGRect) -> CGAffineTransform {
        let innerRect = CGRect(size: innerSize)
        let fittedRect = innerRect.fit(rect: outerRect)
        let scale = (fittedRect.size.width/innerRect.size.width)
        let offset = CGPoint(x:fittedRect.minX, y:fittedRect.minY)
        let t = CGAffineTransform.identity
            .concatenating(CGAffineTransform(scaleX: scale, y: scale))
            .concatenating(CGAffineTransform(translationX: offset.x, y: offset.y))
//        print("tFitSizeInFrame >> t: \(t)")
        return t
    }
}

struct ClampingDragGesture_Previews: PreviewProvider {
    static var previews: some View {
        ClampingDragGesture()
    }
}
