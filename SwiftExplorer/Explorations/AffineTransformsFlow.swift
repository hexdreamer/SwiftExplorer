//
//  AffineTransformsFlow.swift
//  SwiftExplorer
//
//  Created by Zach Young on 4/2/21.
//  Copyright © 2021 Kenny Leung. All rights reserved.
//

/// Explore how to use a transform both ways to move data "up" from image space into a view, and
/// send view data back "down" to alter something in image space.
///
/// An image is transformed from its native image space and rendered *on screen* in a view. The
/// image has an Area of Interest (AOI), a sub image, represented by a simple rectangle. The
/// rectangle for the AOI is shown on screen as an Adjustable Region.
///
/// If we want to adjust the AOI, we interact with the Adjustable Region and the adjustments are
/// sent directly to the AOI's rectangle through the inverse transform (converting view space back
/// to image space).  The Adjustable Region is then re-rendered from the modified AOI (the
/// *source of truth*).

import hexdreamsCocoa
import SwiftUI

let MIN_REGION = CGSize(width: 50, height: 50)

struct AffineTransformsFlow: View {
    let image = UIImage(named: "Middle Earth")!  // about 5000px square

    @State var areaOfInterest = CGRect(x: 500, y: 500, width: 250, height: 250)

    @State var transform = CGAffineTransform.identity  // how the image was fit in the View, set in image's onAppear

    @State var originalRegion = CGRect.zero  // temp copy to reference during adjustments

    // View's size for sub image
    let subImageSize = CGSize(width: 600, height: 400)

    var subImage:UIImage {
        let drawImage = image.cgImage!.cropping(to: areaOfInterest)
        return UIImage(cgImage: drawImage!)
    }

    var body: some View {
        VStack {
            Spacer()
            // Big picture
            GeometryReader { geoReader in
                let tImageFit = CGRect(size: image.size).tFitIn(outerRect: geoReader.frame(in: CoordinateSpace.local))
                let imageFrame = CGRect(size: image.size).applying(tImageFit)

                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: imageFrame.width, height: imageFrame .height)
                    .position(x: imageFrame.midX, y: imageFrame.midY)
                    .background(Color.gray.opacity(0.5))
                    .border(Color.red, width: 1)

                // Adjustable Region
                drawAdjustableRegion(transform: tImageFit)
            }
            Spacer()
            // Sub image
            Image(uiImage: subImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: subImageSize.width, height: subImageSize.height)
                .background(Color.gray.opacity(0.5))  // gray background to see borders of sub-image
                .border(Color.blue, width: 2)
                .overlay(CrossHairs())
            Spacer()
        }
    }

    /// There is no bounds checking/clamping; dragging the region completely off the image will crash the app!
    func drawAdjustableRegion(transform:CGAffineTransform) -> some View {
        var adjustableRegion:CGRect { areaOfInterest.applying(transform) }

        // LongPress ends when motion (dragging) begins
        let longPress = LongPressGesture(minimumDuration: 0.0)
            .onEnded { _ in
                originalRegion = adjustableRegion
            }

        let move = DragGesture()
            .onChanged { gesture in
                let o  = originalRegion
                let tx = gesture.translation.width
                let ty = gesture.translation.height

                let newRegion = CGRect(x: o.minX+tx, y: o.minY+ty, width: o.width, height: o.height)
                self.areaOfInterest = newRegion.applying(transform.inverted())
            }
            .onEnded { _ in
                self.originalRegion = CGRect.zero
            }

        // From bottom-right corner
        let resize = DragGesture()
            .onChanged { gesture in
                let o  = originalRegion
                let tx = gesture.translation.width
                let ty = gesture.translation.height
                let w  = (o.width+tx  < MIN_REGION.width)  ? MIN_REGION.width : o.width+tx
                let h  = (o.height+ty < MIN_REGION.height) ? MIN_REGION.height: o.height+ty

                let newRegion = CGRect(x: o.minX, y: o.minY, width: w, height: h)
                self.areaOfInterest = newRegion.applying(transform.inverted())
            }
            .onEnded { _ in
                self.originalRegion = CGRect.zero
            }

        return Group {
            // Click anywhere in Rectangle to drag-move
            Rectangle()
                .fill(Color.blue.opacity(0.06))
                .border(Color.blue, width: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/)
                .frame(width: adjustableRegion.width, height: adjustableRegion.height)
                .position(x: adjustableRegion.midX, y: adjustableRegion.midY)
                .gesture(longPress.sequenced(before:move)
                )

            // Click on to drag-resize
            Circle()
                .fill(Color.blue)
                .frame(width: 15, height: 15)
                .position(x: adjustableRegion.maxX, y: adjustableRegion.maxY)
                .gesture(longPress.sequenced(before: resize))
        }
    }
}

struct CrossHairs: View {
    var body: some View {
        GeometryReader { geoReader in
            let origin = CGPoint(x: geoReader.size.width/2, y: geoReader.size.height/2)
            drawTickMark("br", origin, size: 100)
                .stroke(Color.yellow, lineWidth: 2)
            drawTickMark("tl", origin, size: 100)
                .stroke(Color.yellow, lineWidth: 2)
        }
    }
}

struct AffineTransformsFlow_Previews: PreviewProvider {
    static var previews: some View {
        AffineTransformsFlow()
    }
}
