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

                DraggableRegion(iAndR: iAndR, tRegion: tFitImage)
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

struct DraggableRegion: View {
    @ObservedObject var iAndR:ImageAndRegion
    let tRegion:CGAffineTransform

    @State var originalRegion = CGRect.zero

    var body: some View {
        let region = iAndR.regionOfInterest.applying(tRegion)
        let longPress = LongPressGesture(minimumDuration: 0.0)
            .onEnded { _ in
                self.originalRegion = region
            }
        let drag = DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .onChanged { gesture in
                let oX = originalRegion.minX
                let oY = originalRegion.minY
                let oW = originalRegion.width
                let oH = originalRegion.height
                let tx = gesture.translation.width
                let ty = gesture.translation.height
                let proposed = CGRect(x: oX+tx, y: oY+ty, width: oW, height: oH)
                iAndR.moveTo(target: proposed.applying(tRegion.inverted()))
            }
            .onEnded { _ in
                self.originalRegion = CGRect.zero
            }
        let combinded = longPress.sequenced(before: drag)

        Image(systemName: "chevron.left")
            .font(.system(size: 50))
            .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
            .shadow(color: .white, radius: 5)
            .rotationEffect(.init(degrees: 45))
            .position(x: region.minX, y: region.minY)

        Rectangle()
            .stroke(Color.blue, lineWidth: 4)
            .shadow(color: .white, radius: 5)
            .position(x: region.midX, y: region.midY)
            .frame(width: region.width, height: region.height)


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
        .gesture(combinded)

        Image(systemName: "chevron.right")
            .font(.system(size: 50))
            .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
            .shadow(color: .white, radius: 5)
            .rotationEffect(.init(degrees: 45))
            .position(x: region.maxX, y: region.maxY)

    }
}

struct ClampingDragGesture_Previews: PreviewProvider {
    static var previews: some View {
        ClampingDragGesture()
    }
}
