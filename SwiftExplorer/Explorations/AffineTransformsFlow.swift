//
//  AffineTransformsFlow.swift
//  SwiftExplorer
//
//  Created by Zach Young on 4/2/21.
//  Copyright © 2021 Kenny Leung. All rights reserved.
//

import SwiftUI

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

struct AffineTransformsFlow: View {

    let image = UIImage(named: "Middle Earth")!
    let imageViewSize = CGSize(width: 600, height: 600)
    var tImageToView:CGAffineTransform {
        let outerRect = CGRect(size: imageViewSize)
        let innerRect = CGRect(size: image.size)
        let fittedRect = innerRect.fit(rect: outerRect)

        let scaleFactor = fittedRect.width/innerRect.width
        let translatedPt = CGPoint(x: fittedRect.minX, y: fittedRect.minY)

        let t = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
            .concatenating(CGAffineTransform(translationX: translatedPt.x, y: translatedPt.y))
        return t
    }
    var tViewToImage:CGAffineTransform {
        tImageToView.inverted()
    }

    // Img -> tImageToView -> ImgView
    // tViewToImage = tImageToView.inverted()
    // ImgView -> tViewToImage -> Img

    // UI State
    @State var tl = CGPoint(x: 0, y: 0)
    @State var br = CGPoint(x: 100, y: 100)

    var regionInView:CGRect {
        CGRect(x: tl.x, y: tl.y, width: br.x - tl.x, height: br.y - tl.y).standardized
    }

    // Source of truth
    var regionInImage:CGRect {
        regionInView.applying(tViewToImage)
    }

    var subImage:UIImage {
        let drawImage = image.cgImage!.cropping(to: regionInImage)
        return UIImage(cgImage: drawImage!)
    }

    var body: some View {
        VStack {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: imageViewSize.width, height: imageViewSize.height)
                .border(Color.red, width: 2)
                .overlay(
                    RegionMarkerCorners(topLeft: $tl, bottomRight: $br)
                        // Not doing such a good job clamping
                        .onChange(of: regionInView) { [regionInView] newValue in
                            print("onChange >> tl: \(tl) br: \(br)")
                            let oldValue = regionInView
                            if (newValue.minX < 0) {
                                tl.x = 0
                                br.x = oldValue.maxX
                            }
                            if (newValue.minY < 0) {
                                tl.y = 0
                                br.y = oldValue.maxY
                            }
                            if (newValue.maxX > imageViewSize.width) {
                                tl.x = oldValue.minX
                                br.x = imageViewSize.width
                            }
                            if (newValue.maxY > imageViewSize.height) {
                                tl.y = oldValue.minY
                                br.y = imageViewSize.height
                            }
                        }
                )


            Spacer()
            Image(uiImage: subImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .border(Color.blue, width: 2)
                .overlay(CrossHairs())
            Spacer()

            Group {
                VStack {
                    Text("ImageView Region: \(regionInView)" as String)
                    Text("Image Region: \(regionInImage)" as String)
                }
            }
        }
    }
}

struct CrossHairs: View {
    var body: some View {
        GeometryReader { geoReader in
            let origin = CGPoint(x: geoReader.size.width/2, y: geoReader.size.height/2)
            let maxX = origin.x+100
            let minX = origin.x-100
            let maxY = origin.y+100
            let minY = origin.y-100
            Path { path in
                path.move(to: CGPoint(x: minX, y: origin.y))
                path.addLine(to: CGPoint(x:maxX, y: origin.y))
                path.move(to: CGPoint(x: origin.x, y: minY))
                path.addLine(to: CGPoint(x: origin.x, y: maxY))
            }
            .stroke(Color.yellow, lineWidth: 2)
        }
    }
}

struct AffineTransformsFlow_Previews: PreviewProvider {
    static var previews: some View {
        AffineTransformsFlow()
    }
}
