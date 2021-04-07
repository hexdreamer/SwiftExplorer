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
    @Published var regionOfInterest = CGRect(x: 20, y: 20, width: 50, height: 50)
    let image = UIImage(named: "ChannelImageDefault")!

    func moveTo(target: CGRect) {
        let boundsX = image.size.width
        let boundsY = image.size.height

        var minX = target.minX
        var minY = target.minY
        var maxX = target.maxX
        var maxY = target.maxY

        if (minX < 0) {
            minX = 0
            maxX = target.width
        }

        if (maxX > boundsX) {
            minX = boundsX - target.width
            maxX = boundsX
        }

        if (minY < 0) {
            minY = 0
            maxY = target.height
        }

        if (maxY > boundsY) {
            minY = boundsY - target.height
            maxY = boundsY
        }

        let clampedTarget = CGRect(x: minX, y: minY, width: maxX-minX, height: maxY-minY)
        self.regionOfInterest = clampedTarget
        print("moveTo >> regionOfInterest: \(self.regionOfInterest)")
    }
}

struct ClampingDragGesture: View {
    @ObservedObject var c = Controller()
    @State var originalRegion = CGRect.zero
    @State var dragging = false
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
                        DragGesture(minimumDistance: 0, coordinateSpace: .local)
                            .onChanged { gesture in
                                if (!self.dragging) {
                                    self.dragging = true
                                    self.originalRegion = region
                                }
                                let oX = originalRegion.minX
                                let oY = originalRegion.minY
                                let oW = originalRegion.width
                                let oH = originalRegion.height
                                let tx = gesture.translation.width
                                let ty = gesture.translation.height
                                let proposed = CGRect(x: oX+tx, y: oY+ty, width: oW, height: oH)
                                c.moveTo(target: proposed.applying(tFitImage.inverted()))
                            }
                            .onEnded { _ in
                                self.dragging = false
                                self.originalRegion = CGRect.zero
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
