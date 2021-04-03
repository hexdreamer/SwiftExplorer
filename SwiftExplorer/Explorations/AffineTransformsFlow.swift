//
//  AffineTransformsFlow.swift
//  SwiftExplorer
//
//  Created by Zach Young on 4/2/21.
//  Copyright © 2021 Kenny Leung. All rights reserved.
//

import SwiftUI
import hexdreamsCocoa

extension String.StringInterpolation {
    mutating func appendInterpolation(_ r: CGRect) {
        func round(_ x:CGFloat) -> CGFloat { CGFloat(Int(x*100))/100.0 }
        let x = round(r.minX)
        let y = round(r.minY)
        let w = round(r.width)
        let h = round(r.height)
        appendInterpolation("x: \(x), y: \(y), w: \(w), h: \(h)")
    }
}

/// Manage the transformation of coordinate space (*space*) data from an Image's Source-of-Truth forwards to the Derived value in the Image's View,
/// and vice-versa.
///
/// This Exploration starts with a rectangular *region* centered on a specific landmark / feature of a map that is the Image.  The region is defined in the Image's space.
/// The Image is rendered in the View, and will be scaled-down and moved to fit (centered) in the View's space.
///
/// The scaling and translation values will be computed and combined into a transform that takes data *forward*, from the Image space to the View space (SOT → Derived).
/// As we interact with the transformed region and manipulate it in the UI, we'll need to take that data *back* to the Image's space and update the underlying
/// source region.  This backwards flow is achieved by inverting the forwards-flowing transform.
///
/// **Note:** The UI for the region is created by overlaying it on the View which puts it directly into the View's space—no other transform is explicitly needed. A different
/// design would have the UI for the region composed in a ZStack, Geometry Reader, or Path, and that will require explicitly aligning or transforming it.

struct AffineTransformsFlow: View {
    let image = UIImage(named: "Middle Earth")!                             // a Wikimedia-Commons map of Middle Earth
    let startingRegion = CGRect(x: 2361, y: 2220, width: 556, height: 333)  // a region centered on the lands of Rohan, in Image space
    let viewSize = CGSize(width: 750, height: 750)                          // our View space for the Image, predefined size for now

    // Forwards: Image space -> View space
    var tImageToView:CGAffineTransform {
        let imageSize = self.image.size, viewSize = self.viewSize

        // Mimic SwiftUI fitting Image into View, and derive transform values
        let innerRect = CGRect(size: imageSize)
        let outerRect = CGRect(size: viewSize)
        let fittedRect = innerRect.fit(rect: outerRect)
        let scaleFactor = fittedRect.width/innerRect.width
        let translatedPt = CGPoint(x: fittedRect.minX, y: fittedRect.minY)

        // When concatenating, scale **then** translate
        let t = CGAffineTransform.identity
            .concatenating(CGAffineTransform(scaleX: scaleFactor, y: scaleFactor))
            .concatenating(CGAffineTransform(translationX: translatedPt.x, y: translatedPt.y))
        //print("tImageToView >>")
        //t.print()
        return t
    }

    // Backwards: View space -> Image space
    var tViewToImage:CGAffineTransform {
        //print("tViewToImage >>")
        //tImageToView.inverted().print()
        return tImageToView.inverted()
    }

    // UI parameters of region in View space
    @State var tl = CGPoint.zero  // (x: 0, y: 0)
    @State var br = CGPoint.zero  // (x: 100, y: 100)
    var regionInView:CGRect { CGRect(x: tl.x, y: tl.y, width: br.x - tl.x, height: br.y - tl.y).standardized }
    var regionInImage:CGRect { regionInView.applying(tViewToImage) }
    var subImage:UIImage? {
        print(regionInImage)
        if let cgImage = image.cgImage, let croppedImage = cgImage.cropping(to: regionInImage) {
            return UIImage(cgImage: croppedImage)
        }
        return nil
    }

    var body: some View {
        VStack {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: viewSize.width, height: viewSize.height)
                .border(Color.red, width: 2)
                .overlay(
                    RegionMarkerCorners(topLeft: $tl, bottomRight: $br, bounds: viewSize)
                )


            Spacer()
            Image(uiImage: subImage ?? UIImage(named: "ChannelImageDefault")!)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: viewSize.width + 100)
                .border(Color.blue, width: 2)
                .overlay(CrossHairs(tickSize: 100))
            Spacer()

            Group {
                VStack {
                    Text("ImageView Region: \(regionInView)" as String)
                    Text("Image Region: \(regionInImage)" as String)
                }
            }
        }
        .background(Color.gray)
        .border(Color.purple, width: 2)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {  // Wait for capybara
                let tl = ┌startingRegion.applying(tImageToView)
                let br = ┘startingRegion.applying(tImageToView)
                self.tl = tl
                self.br = br
            }
        }
    }
}

struct CrossHairs: View {
    let tickSize:CGFloat

    var body: some View {
        GeometryReader { geoReader in
            let origin = CGPoint(x: geoReader.size.width/2, y: geoReader.size.height/2)
            let minX = origin.x-tickSize, maxX = origin.x+tickSize
            let minY = origin.y-tickSize, maxY = origin.y+tickSize
            Path { path in
                path.move(to: CGPoint(x: minX, y: origin.y))
                path.addLine(to: CGPoint(x:maxX, y: origin.y))
                path.move(to: CGPoint(x: origin.x, y: minY))
                path.addLine(to: CGPoint(x: origin.x, y: maxY))
            }
            .stroke(Color.yellow, lineWidth: 1)
        }
    }
}

struct AffineTransformsFlow_Previews: PreviewProvider {
    static var previews: some View {
        AffineTransformsFlow()
    }
}
