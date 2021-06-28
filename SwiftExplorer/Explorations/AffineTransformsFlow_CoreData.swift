//
//  AffineTransformsFlow.swift
//  SwiftExplorer
//
//  Created by Zach Young on 4/2/21.
//  Copyright © 2021 Kenny Leung. All rights reserved.
//

/// Explore how to use a CoreData to persist changes to the AreaOfInterest (AOI).  This is a follow-on on from AffineTransformsFlow exploration.
///
/// In the previous exploration, AOI was an `@State var CGRect` that was declared and managed in the top-level View.  To make it persistent, "Area of Interest" becomes an *entity* with a computed *property* named `rect`.  A CGRect cannot be stored directly in Core Data because it is a struct, not a class, so the actual stored attributes of the entity are the four componets of a CGRect: `x`, `y`, `width`, and `height`.  The `rect` property is a cover method for getting and setting those attributes from and to a CGRect.

import hexdreamsCocoa
import SwiftUI

struct AffineTransformsFlow_CoreData: View {
    @Environment(\.managedObjectContext) private var moc

    let image = UIImage(named: "Middle Earth")!  // about 5000px square

    // @State var areaOfInterest = CGRect(x: 500, y: 500, width: 250, height: 250)
    // source of truth
    @FetchRequest(sortDescriptors: []) var areasOfInterest: FetchedResults<AreaOfInterest>

    // temp copy to reference during adjustments
    @State var originalRegion = CGRect.zero

    let subImageSize = CGSize(width: 600, height: 400)
    var subImage:UIImage {
        if areasOfInterest.count > 0 {
            if let rect    = areasOfInterest[0].rect,
               let cgImg   = image.cgImage,
               let cropped = cgImg.cropping(to: rect) {
                return UIImage(cgImage: cropped)
            }
        }
        print("error trying to crop image!")
        return UIImage(named: "ChannelImageDefault")!
    }

    var body: some View {
        VStack {
            Spacer()
            // Big picture
            GeometryReader { geoReader in
                let tImageFit = CGRect(size: image.size)
                    .tFitIn(outerRect: geoReader.frame(in: CoordinateSpace.local))
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

    let MIN_REGION = CGSize(width: 50, height: 50)

    /// There is no bounds checking/clamping; dragging the region completely off the image will crash the app!
    func drawAdjustableRegion(transform:CGAffineTransform) -> some View {
        if areasOfInterest.count < 1 {
            fatalError("could not find AreaOfInterest")
        }
        let areaOfInterest = areasOfInterest[0]

        // Render on-screen from the source of truth
        var adjustableRegion:CGRect {
            guard let rect = areaOfInterest.rect else {
                print("error: AOI rect was nil")
                return CGRect.zero
            }
            return rect.applying(transform)
        }

        // LongPress ends when motion (dragging) begins
        let longPress = LongPressGesture(minimumDuration: 0.0)
            .onEnded { _ in
                // Make adjustments relative to geometry *before* drag-gesture begins
                originalRegion = adjustableRegion
            }

        let move = DragGesture()
            .onChanged { gesture in
                let o  = originalRegion
                let tx = gesture.translation.width
                let ty = gesture.translation.height
                let newRegion = CGRect(x: o.minX+tx, y: o.minY+ty, width: o.width, height: o.height)
                // Modify source of truth through inverse transform
                areaOfInterest.rect = newRegion.applying(transform.inverted())
            }
            .onEnded { _ in
                PersistenceController.shared.saveContext()

                // Could leave as is, but clearer to reset since it's not being used
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
                areaOfInterest.rect = newRegion.applying(transform.inverted())
            }
            .onEnded { _ in
                PersistenceController.shared.saveContext()
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


struct AffineTransformsFlow_CoreData_Previews: PreviewProvider {
    static var previews: some View {
        AffineTransformsFlow()
    }
}
