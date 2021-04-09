//
//  ClampingDragGesture.swift
//  SwiftExplorer
//
//  Created by Zach Young on 4/6/21.
//  Copyright © 2021 Kenny Leung. All rights reserved.
//

import SwiftUI
import hexdreamsCocoa


class Page: ObservableObject {
    let name:String
    let image:UIImage
    @Published var regions:[CGRect]

    var subImage:UIImage {
        let drawImage = image.cgImage!.cropping(to: self.regions[0])
        return UIImage(cgImage: drawImage!)
    }

    init(_ name:String, _ region:CGRect?) {
        if let region = region {
            self.regions = [region]
        } else {
            self.regions = [CGRect(x: 20, y: 20, width: 50, height: 50)]
        }

        self.name = name
        self.image = UIImage(named: name)!
    }

    var boundsX:CGFloat { image.size.width }
    var boundsY:CGFloat { image.size.height }

    // Use target size and adjust the origin
    func moveTo(target: CGRect) {
        let x:CGFloat
        let y:CGFloat
        let width = target.width
        let height = target.height

        if (target.minX < 0) {
            x = 0
        } else if (target.maxX > boundsX) {
            x = boundsX - width
        } else {
            x = target.minX
        }

        if (target.minY < 0) {
            y = 0
        } else if (target.maxY > boundsY) {
            y = boundsY - height
        } else {
            y = target.minY
        }

        let clampedTarget = CGRect(x: x, y: y, width: width, height: height)
        self.regions[0] = clampedTarget
        print("moveTo >> regionOfInterest: \(self.regions[0])")
    }

    // Adjust any point
    func resizeTo(target: CGRect) {
        let minX = (target.minX < 0)       ? 0       : target.minX
        let minY = (target.minY < 0)       ? 0       : target.minY
        let maxX = (target.maxX > boundsX) ? boundsX : target.maxX
        let maxY = (target.maxY > boundsY) ? boundsY : target.maxY

        let clampedTarget = CGRect(x: minX, y: minY, width: maxX-minX, height: maxY-minY)
        self.regions[0] = clampedTarget
        print("resizeTo >> regionOfInterest: \(self.regions[0])")
    }
}

extension Page: Equatable {
    static func == (lhs: Page, rhs: Page) -> Bool {
        return lhs.name == rhs.name
    }
}

class Controller: ObservableObject {
    let pages = [
        Page(
            "Comic3",
            CGRect(x: 1927.32, y: 1582.24, width: 612.38, height: 485.25)
        ),
        Page(
            "Middle Earth",
            CGRect(x: 2327.01, y: 2189.8, width: 609.67, height: 410.5)
        )
    ]

    @Published var selected:Page

    init() {
        self.selected = self.pages[0]
    }
}

struct ClampingDragGesture: View {
    @ObservedObject var controller = Controller()

    var body: some View {
        NavigationView {
            List(controller.pages, id: \.name) { page in
                HStack {
                    Button("\(page.name)") {
                        controller.selected = page
                    }
                    if (page == controller.selected) {
                        Image(systemName: "checkmark.circle")
                    }
                }
            }
            .listStyle(SidebarListStyle())
            .navigationTitle("Images")

            DetailView(page: controller.selected)
        }
    }
}

struct DetailView: View {
    @ObservedObject var page:Page

    var body: some View {
        let image = self.page.image
        VStack {
            GeometryReader { geoReader in
                let frame = geoReader.frame(in: .local)
                let tFitImage = tFitSizeInFrame(innerSize: image.size, outerRect: frame)
                let imageFrame = CGRect(size: image.size).applying(tFitImage)

                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .border(Color.red, width: 2)
                    .position(x: imageFrame.midX, y: imageFrame.midY)
                    .frame(width: imageFrame.width, height: imageFrame.height)

                AdjustableRegion(page: self.page, tRegion: tFitImage)
            }  // GeometryReader

            Image(uiImage: page.subImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
        }  // VStack
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
    @ObservedObject var page:Page
    let tRegion:CGAffineTransform

    // Copy last UI region before adjustment to reference during adjustment
    @State var originalRegion = CGRect.zero 

    let minRegion = CGSize(width: 70, height: 70)

    var body: some View {
        let region = page.regions[0].applying(tRegion)

        // Region's outline
        Rectangle()
            .stroke(Color.blue, lineWidth: 2)
            .shadow(color: .white, radius: 5)
            .position(x: region.midX, y: region.midY)
            .frame(width: region.width, height: region.height)

        // All interactive/adjustment UI

        drawResizeHandlesFor(region, "tl")
            .gesture(combined(region) { gesture in
                let o = originalRegion
                let tx = gesture.translation.width
                let ty = gesture.translation.height
                let maxX = o.maxX
                let maxY = o.maxY
                var minX = o.minX+tx
                var minY = o.minY+ty
                minX = (maxX-minX < minRegion.width) ? maxX-minRegion.width  : minX
                minY = (maxY-minY < minRegion.width) ? maxY-minRegion.height : minY
                let new = CGRect(x: minX, y: minY, width: maxX-minX, height: maxY-minY)
                page.resizeTo(target: new.applying(tRegion.inverted()))
            })

        drawMoveHandlesFor(region)
            .gesture(combined(region) { gesture in
                let o = originalRegion
                let tx = gesture.translation.width
                let ty = gesture.translation.height
                let new = CGRect(x: o.minX+tx, y: o.minY+ty, width: o.width, height: o.height)
                page.moveTo(target: new.applying(tRegion.inverted()))
            })

        drawResizeHandlesFor(region, "br")
            .gesture(combined(region) { gesture in
                let o = originalRegion
                let tx = gesture.translation.width
                let ty = gesture.translation.height
                let width = (o.width+tx < minRegion.width) ? minRegion.width : o.width+tx
                let height = (o.height+ty < minRegion.height) ? minRegion.height: o.height+ty
                let new = CGRect(x: o.minX, y: o.minY, width: width, height: height)
                page.resizeTo(target: new.applying(tRegion.inverted()))
            })

    }

    // Take the UI region to copy/save before drag, and a closure that adjusts the region's SOT
    func combined(_ region: CGRect, f: @escaping (DragGesture.Value)->Void) -> some Gesture {
        let longPress = LongPressGesture(minimumDuration: 0.0)
            .onEnded { _ in
                self.originalRegion = region
            }

        return longPress.sequenced(
            before: DragGesture(minimumDistance: 0, coordinateSpace: .local)
                .onChanged { gesture in
                    f(gesture)
                }
                .onEnded { _ in
                    self.originalRegion = CGRect.zero
                }
        )
    }

    func drawMoveHandlesFor(_ region: CGRect) -> some View {
        Group {
            Rectangle()
                .fill(Color.blue.opacity(0.125))
//                .shadow(color: .white, radius: 5)
                .rotationEffect(.init(degrees: 45))
                .position(x: region.midX, y: region.midY)
                .frame(width: 30, height: 30)
            ForEach(0..<4) { idx in
                Image(systemName: "chevron.up")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
//                    .shadow(color: .white, radius: 5)
                    .offset(y:-25)
                    .rotationEffect(.init(degrees: 90 * Double(idx)))
                    .position(x: region.midX, y: region.midY)
            }
        }
    }

    func drawResizeHandlesFor(_ region: CGRect, _ corner:String) -> some View {
        let x:CGFloat, y:CGFloat
        let name:String

        switch corner {
        case "tl":
            name = "chevron.left"
            x = region.minX-2
            y = region.minY-2
        case "br":
            name = "chevron.right"
            x = region.maxX+2
            y = region.maxY+2
        default:
            x = 0
            y = 0
            name = ""
        }

        return Group {
            // A mostly transparent Shape to give the user something to tap on
            Rectangle()
                .fill(Color.white.opacity(0.125))
//                .shadow(color: .white, radius: 5)
                .position(x: x, y: y)
                .frame(width: 15, height: 15)

            Image(systemName: name)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
//                .shadow(color: .white, radius: 5)
                .rotationEffect(.init(degrees: 45))
                .position(x: x, y: y)
        }
    }
}

struct ClampingDragGesture_Previews: PreviewProvider {
    static var previews: some View {
        ClampingDragGesture()
    }
}
