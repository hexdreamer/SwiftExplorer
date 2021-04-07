//
//  ClampingDragGesture.swift
//  SwiftExplorer
//
//  Created by Zach Young on 4/6/21.
//  Copyright © 2021 Kenny Leung. All rights reserved.
//

import SwiftUI
import hexdreamsCocoa

class ImageAndRegion: ObservableObject {
    @Published var regionOfInterest = CGRect(x: 20, y: 20, width: 50, height: 50)
    let image = UIImage(named: "ChannelImageDefault")!

    var boundsX:CGFloat { image.size.width }
    var boundsY:CGFloat { image.size.height }

    func moveTo(target: CGRect) {
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

    func resizeTo(target: CGRect) {
        let minX = (target.minX < 0)       ? 0       : target.minX
        let minY = (target.minY < 0)       ? 0       : target.minY
        let maxX = (target.maxX > boundsX) ? boundsX : target.maxX
        let maxY = (target.maxY > boundsY) ? boundsY : target.maxY

        let clampedTarget = CGRect(x: minX, y: minY, width: maxX-minX, height: maxY-minY)
        self.regionOfInterest = clampedTarget
        print("resizeTo >> regionOfInterest: \(self.regionOfInterest)")
    }
}

struct ClampingDragGesture: View {
    let iAndR = ImageAndRegion()

    var body: some View {
        let image = self.iAndR.image
        VStack {
            GeometryReader { geoReader in
                let frame = geoReader.frame(in: .local)
                let tFitImage = tFitSizeInFrame(innerSize: image.size, outerRect: frame)
                let imageFrame = CGRect(size: image.size).applying(tFitImage)

                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .position(x: imageFrame.midX, y: imageFrame.midY)
                    .frame(width: imageFrame.width, height: imageFrame.height)

                AdjustableRegion(iAndR: iAndR, tRegion: tFitImage)
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

struct AdjustableRegion: View {
    @ObservedObject var iAndR:ImageAndRegion
    let tRegion:CGAffineTransform

    @State var originalRegion = CGRect.zero

    var body: some View {
        let region = iAndR.regionOfInterest.applying(tRegion)
        let longPress = LongPressGesture(minimumDuration: 0.0)
            .onEnded { _ in
                self.originalRegion = region
            }

        // Top left - resize
        Group {
            Rectangle()
                .fill(Color.blue.opacity(0.125))
                .shadow(color: .white, radius: 5)
                .position(x: region.minX+5, y: region.minY+5)
                .frame(width: 20, height: 20)

        Image(systemName: "chevron.left")
            .font(.system(size: 50))
            .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
            .shadow(color: .white, radius: 5)
            .rotationEffect(.init(degrees: 45))
            .position(x: region.minX, y: region.minY)
        }
            .gesture(
                longPress.sequenced(
                    before: DragGesture(minimumDistance: 0, coordinateSpace: .local)
                        .onChanged { gesture in
                            let o = originalRegion
                            let tx = gesture.translation.width
                            let ty = gesture.translation.height
                            let new = CGRect(x: o.minX+tx, y: o.minY+ty, width: o.width+(tx * -1), height: o.height+(ty * -1))
                            iAndR.resizeTo(target: new.applying(tRegion.inverted()))
                        }
                        .onEnded { _ in
                            self.originalRegion = CGRect.zero
                        }
                ))

        Rectangle()
            .stroke(Color.blue, lineWidth: 4)
            .shadow(color: .white, radius: 5)
            .position(x: region.midX, y: region.midY)
            .frame(width: region.width, height: region.height)


        // Center - move
        Group {
            Rectangle()
                .fill(Color.blue.opacity(0.125))
                .shadow(color: .white, radius: 5)
                .rotationEffect(.init(degrees: 45))
                .position(x: region.midX, y: region.midY)
                .frame(width: 30, height: 30)
            ForEach(0..<4) { idx in
                Image(systemName: "chevron.up")
                    .font(.system(size: 20, weight: .heavy))
                    .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                    .shadow(color: .white, radius: 5)
                    .offset(y:-25)
                    .rotationEffect(.init(degrees: 90 * Double(idx)))
                    .position(x: region.midX, y: region.midY)
            }
        }
        .gesture(
            longPress.sequenced(
                before: DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onChanged { gesture in
                        let o = originalRegion
                        let tx = gesture.translation.width
                        let ty = gesture.translation.height
                        let new = CGRect(x: o.minX+tx, y: o.minY+ty, width: o.width, height: o.height)
                        iAndR.moveTo(target: new.applying(tRegion.inverted()))
                    }
                    .onEnded { _ in
                        self.originalRegion = CGRect.zero
                    }
            ))

        // Bottom right - resize
        Group {
            Rectangle()
                .fill(Color.blue.opacity(0.125))
                .shadow(color: .white, radius: 5)
                .position(x: region.maxX-5, y: region.maxY-5)
                .frame(width: 20, height: 20)

            Image(systemName: "chevron.right")
                .font(.system(size: 50))
                .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                .shadow(color: .white, radius: 5)
                .rotationEffect(.init(degrees: 45))
                .position(x: region.maxX, y: region.maxY)
        }
        .gesture(
            longPress.sequenced(
                before: DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onChanged { gesture in
                        let o = originalRegion
                        let tx = gesture.translation.width
                        let ty = gesture.translation.height
                        let new = CGRect(x: o.minX, y: o.minY, width: o.width+tx, height: o.height+ty)
                        iAndR.resizeTo(target: new.applying(tRegion.inverted()))
                    }
                    .onEnded { _ in
                        self.originalRegion = CGRect.zero
                    }
            ))


    }
}

struct ClampingDragGesture_Previews: PreviewProvider {
    static var previews: some View {
        ClampingDragGesture()
    }
}
